//
//  ViewController.m
//  FMDBTest
//
//  Created by Iris on 2018/4/10.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ViewController.h"

#import "Student.h"
#import "JJEncryptHelper.h"

#import <FMDB/FMDB.h>
#import <SQLCipher/sqlite3.h>


@interface ViewController ()
@property (nonatomic, copy) NSString *encryptKey;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.encryptKey = @"123";

}

#pragma mark 加密
- (void)key {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    BOOL res = [JJEncryptHelper encryptDatabase:file encryptKey:self.encryptKey];
    
    NSString *msg = res ? @"encrypt success" : @"encrypt fail";
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
}

#pragma mark 解密
- (void)key1 {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    BOOL res = [JJEncryptHelper unEncryptDatabase:file encryptKey:@"123"];
    
    NSString *msg = res ? @"decrypt success" : @"decrypt fail";
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
}


#pragma mark 事务
#pragma mark 多线程使用事务
//多线程事务
- (void)transactionByQueue {
    NSDate *date1 = [NSDate date];
    
    // 创建表
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"student.sqlite"];
    
    //多线程安全FMDatabaseQueue可以替代dataBase
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    //开启事务
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if(![db open]){
            
            return NSLog(@"事务打开失败");
        }
        
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS student (studentID integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];

        if (!result) {
            NSLog(@"error when creating student table");
            
            [db close];
        }
        
        for (int i = 0; i<500; i++) {
            
            NSString *insertSql2= [NSString stringWithFormat:
                                   @"INSERT INTO '%@' ('%@', '%@') VALUES (?, ?)",
                                   @"student", @"name", @"age"];
            
            NSString * name = [NSString stringWithFormat:@"静静 %d", i];
            NSString * age = [NSString stringWithFormat:@"%d", 10+i];
            
            BOOL result = [db executeUpdate:insertSql2, name, age];;
            if ( !result ) {
                //当最后*rollback的值为YES的时候，事务回退，如果最后*rollback为NO，事务提交
                *rollback = YES;
                return;
            }
        }
        
//        [db close];
    }];
    NSDate *date2 = [NSDate date];
    NSTimeInterval a = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
    NSLog(@"FMDatabaseQueue使用事务插入500条数据用时%.3f秒",a);
}

#pragma mark 基本使用事务
-(void)transaction {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    FMDatabase *db = [FMDatabase databaseWithPath:file];
    
    BOOL isSuccess=[db open];
    if (!isSuccess) {
        NSLog(@"打开数据库失败");
    }
    [db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (int i = 0; i<500; i++) {
            NSString *nId = [NSString stringWithFormat:@"%d",i];
            NSString *strName = [[NSString alloc] initWithFormat:@"student_%d",i];
            NSString *sql = @"INSERT INTO student (name,age) VALUES (?,?)";
            BOOL a = [db executeUpdate:sql,strName,nId];
            if (!a) {
                NSLog(@"插入失败1");
            }
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    }
    @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    [db close];
}
#pragma mark 多线程
- (void)queue {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:file];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    
    dispatch_async(q1, ^{
        for (int i = 0; i < 50; ++i) {
            [queue inDatabase:^(FMDatabase *db2) {
                
                if ([db2 open]){
                    BOOL result = [db2 executeUpdate:@"CREATE TABLE IF NOT EXISTS student (studentID integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
                    if (result) {
                        NSString *insertSql1= [NSString stringWithFormat:
                                               @"INSERT INTO '%@' ('%@', '%@') VALUES (?, ?)",
                                               @"student", @"name", @"age"];
                        
                        NSString * name = [NSString stringWithFormat:@"深深 %d", i];
                        NSString * age = [NSString stringWithFormat:@"%d", 10+i];
                        
                        
                        BOOL res = [db2 executeUpdate:insertSql1, name, age];
                        if (!res) {
                            NSLog(@"error to inster data: %@", name);
                        } else {
                            NSLog(@"succ to inster data: %@", name);
                        }
                    }
                }
                
                
            }];
        }
    });
    
    dispatch_async(q2, ^{
        for (int i = 0; i < 50; ++i) {
            [queue inDatabase:^(FMDatabase *db2) {
                if ([db2 open]) {
                    BOOL result = [db2 executeUpdate:@"CREATE TABLE IF NOT EXISTS student (studentID integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
                    
                    if (result) {
                        NSString *insertSql2= [NSString stringWithFormat:
                                               @"INSERT INTO '%@' ('%@', '%@') VALUES (?, ?)",
                                               @"student", @"name", @"age"];
                        
                        NSString * name = [NSString stringWithFormat:@"静静 %d", i];
                        NSString * age = [NSString stringWithFormat:@"%d", 10+i];
                        
                        BOOL res = [db2 executeUpdate:insertSql2, name, age];
                        if (!res) {
                            NSLog(@"error to inster data: %@", name);
                        } else {
                            NSLog(@"succ to inster data: %@", name);
                        }
                    }
                }
                
                
            }];
        }
    });
}

#pragma mark 删除记录
- (void)deleteRecord {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    //2.获得数据库
    FMDatabase *db = [FMDatabase databaseWithPath:file];
    if ([db open]) {
       BOOL res = [db executeUpdate:@"delete from student where studentID = ?;",@(1)];
        if (res) {
            NSLog(@"删除成功");
        }else {
            NSLog(@"删除失败");
        }
    }
}

#pragma mark 查询记录
- (void)queryRecord {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    //2.获得数据库
    FMDatabase *db = [FMDatabase databaseWithPath:file];
    if ([db open]) {
        FMResultSet *results = [db executeQuery:@"SELECT * FROM student"];
    
        // 2.遍历结果
        while ([results next]) {
            int ID = [results intForColumn:@"studentID"];
            NSString *name = [results stringForColumn:@"name"];
            int age = [results intForColumn:@"age"];
            NSLog(@"%d %@ %d", ID, name, age);
        }
    }
}

#pragma mark 创建表
- (void)createDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    //2.获得数据库
    FMDatabase *db = [FMDatabase databaseWithPath:file];
    
    //3.使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用 close 方法来关闭数据库。在和数据库交互 之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
    if ([db open]){
        //4.创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS student (studentID integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
        if (result){
            NSLog(@"创建表成功");
             //            INSERT INTO student (name, age) VALUES (?, ?);
             
             NSString * sql = @"INSERT INTO student (name, age) VALUES(?, ?);";
             NSString * name = @"静静";
             BOOL res = [db executeUpdate:sql, name, @2];
             
             //            BOOL res = [db executeUpdateWithFormat:@"INSERT INTO student (name, age) VALUES (%@, %d);", name, 1];
            
            NSArray *sqlArr = @[@"静静11", @11];
            
            [db executeUpdate:@"INSERT INTO student (name,age) values (?,?)" withArgumentsInArray:sqlArr];
            
            NSString *sql1 = @"CREATE TABLE IF NOT EXISTS school (schoolID text PRIMARY KEY, schoolName text NOT NULL, address text NOT NULL);"
                                "insert into school (schoolID,schoolName,address) values ('1','第一中学','阿里部落');"
                ;
           BOOL res1 =  [db executeStatements:sql1];
            
             if (!res) {
             NSLog(@"插入失败");
             
             } else {
             NSLog(@"插入成功");
             }
             //查看最后一条错误信息
             NSString *errorStr = [db lastErrorMessage];
             NSLog(@"%@",errorStr);
             
             //查看最后一条错误
             NSError *error = [db lastError];
             NSLog(@"%@",error);
             
             [db close];
        }else {
            NSLog(@"创建表失败");
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
