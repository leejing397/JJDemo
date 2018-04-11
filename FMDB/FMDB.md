FMDB 
##1.FMDB 使用方法

###1.1 类
####1.1.1 三个基本类
* FMDatabase: 代表一个 SQLite 数据库,用于执行 SQLite 语句;
* FMResultSet:表示FMDatabase执行查询后结果集
* FMDatabaseQueue:如果你想在多线程中执行多个查询或更新，你应该使用该类。这是线程安全的。

####1.1.2 其他类
* FMDatabasePool:使用任务池的形式,对多线程的操作提供支持。(官方不推荐使用)
* FMDatabaseAdditions: 扩展`FMDatabase类,新增对查询结果只返回单个值的方法进行简化,对表、列是否存在,版本号,校验SQL等等功能。

---

###1.2 数据库操作
创建`Student `模型

`Student.h`

```
#import <Foundation/Foundation.h>

@interface Student : NSObject

@property (nonatomic,copy)NSString *name;

@property (nonatomic,copy)NSString *sex;

@property (nonatomic,assign) int age;

@property (nonatomic,assign) int studentID;

@end
```

####1.2.1 创建数据库
创建方式如下图：
![](https://ws2.sinaimg.cn/large/006tKfTcgy1fq7keqqwk9j30gt03gwf4.jpg)

> * 以上初始化方法本质上只是给了数据库一个名字，并没有真实创建或者获取数据库，
> * `open`函数才是真正获取到数据库，其本质上也就是调用SQLite的C/C++接口 `– sqlite3_open()`


```
NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    //2.获得数据库
    FMDatabase *db = [FMDatabase databaseWithPath:file];
    
    //3.使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用`close`方法来关闭数据库。在和数据库交互之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
    if ([db open]){
        //4.创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS student (studentID integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
        if (result){
            NSLog(@"创建表成功");
        }else {
            NSLog(@"创建表失败");
        }
    }
```
> 如果创建失败可以调用 `- (NSString*)lastErrorMessage;`和`- (int)lastErrorCode;`查看错误信息

####1.2.2 打开/关闭数据库

**打开数据库**
>
`- (BOOL)open;`
>
`- (BOOL)openWithFlags:(int)flags;`
>
`- (BOOL)openWithFlags:(int)flags vfs:(NSString * _Nullable)vfsName;`

**关闭数据库**

>`- (BOOL)close;`
主要封装了`sqlite_close`函数。
>
主要功能：
>
①清除缓存的prepare语句；
>
②关闭数据库（关闭数据的时候将数据库当中的prepare语句全部清除掉）

####1.2.3 更新数据
使用`- (BOOL)executeUpdate:(NSString*)sql, ...;`
、
`- (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);`、

`- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;`

方法执行更新操作，该方法返回`BOOL`型, 成功返回`YES`, 失败返回`NO`.

**说明:**

>
* 除了`SELECT`外的SQL操作,都被视为更新操作.包括`CREATE`, `UPDATE`, `INSERT`,`ALTER`,`COMMIT`,`BEGIN`,`DETACH`,`DELETE`,`DROP`,`END`, `EXPLAIN`,`VACUUM`, `REPLACE`等;
>
* `- (BOOL)executeUpdate:(NSString*)sql, ...;`使用标准的`SQL`语句,参数用`?`来占位,参数必须是对象类型,不能是`int`,`double``,bool`等基本数据类型;
>
* `- (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);`使用字符串的格式化构建`SQL`语句,参数用`%@`、`%d`等来占位.
 >
* `- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;`
也可以把对应的参数装到数组里面传进去,`SQL`语句中的参数用`?`代替. 
如：

```
NSArray *sqlArr = @[@"静静", @11];

[db executeUpdate:@"INSERT INTO student (name,age) values (?,?)" withArgumentsInArray:sqlArr];
```

```
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
```
**运行如图:**

![](https://ws2.sinaimg.cn/large/006tKfTcgy1fq7lkgx787j30t20addhc.jpg)

还可以使用`- (BOOL)executeStatements:(NSString *)sql;`或者
`- (BOOL)executeStatements:(NSString *)sql withResultBlock:(__attribute__((noescape)) FMDBExecuteStatementsCallbackBlock _Nullable)block;`
将多个`SQL`执行语句写在一个字符串中，并执行。

```
NSString *sql1 = @"CREATE TABLE IF NOT EXISTS school (schoolID text PRIMARY KEY, schoolName text NOT NULL, address text NOT NULL);"
                                "insert into school (schoolID,schoolName,address) values ('1','第一中学','阿里部落');"
                ;
BOOL res1 =  [db executeStatements:sql1];
```

**运行如图：**

![](https://ws1.sinaimg.cn/large/006tKfTcly1fq7lzf9q7cj30pa07u758.jpg)

基本上`- (BOOL)executeStatements:(NSString *)sql;`系列函数最终封装的都是

`- (BOOL)executeStatements:(NSString *)sql withResultBlock:(__attribute__((noescape)) FMDBExecuteStatementsCallbackBlock _Nullable)block;`函数，而此函数又是对`sqlite3_exec`函数的封装。

####1.2.4 查询数据
查询有以下方法：
![](https://ws3.sinaimg.cn/large/006tKfTcgy1fq7l74qzzhj30p4078myp.jpg)

所有查询函数都是对`-(FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;`的简单封装。

`-(FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;`此函数的大致执行步骤请见`XMIND`

```
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
```


####1.2.5 删除数据

```
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

```
---
###1.3 多线程处理

`FMDatabase`这个类是线程不安全的，如果在多个线程中同时使用一个
`FMDatabase`实例，会造成数据混乱等问题。

为了保证线程安全，`FMDB`提供方便快捷的`FMDatabaseQueue`。

**代码如下：**

```
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
```

---
###1.4 事务
**什么是事务**
>说一下事务是什么，比如说我们有一个学生表和一个学生成绩表，而且一个学生对应一个学生成绩。比如小明的成绩是100分，那么我们要写两个`sql`语句对不同的表进行插入数据。但是如果在这个过程中，小明这个学生成功的插入到数据库，而成绩插入时失败了，怎么办？这时事务就突出了它的作用。用事务可以对两个表进行同时插入，一旦一个表插入失败，那么就会进行事务回滚，就是让另一个表也不进行插入数据了。 

>简单的说也就是，事务可以让多个表的数据同时插入，一旦有一个表操作失败，那么其他表也都会失败。当然这种说法是为了理解，不是严谨的。 

>那么对一个表大量插入数据时也可以用事务。比如`sqlite3`。

>数据库中`insert into`语句等操作是比较耗时的，假如我们一次性插入几百几千条数据就
会造成主线程阻塞，以至于UI界面卡住。那么这时候我们就要开启一个事物来进行操作。 

>原因就是它以文件的形式存在磁盘中，每次访问时都要打开一次文件，如果对数据库进行大量的操作，就很慢。可是如果我们用事务的形式提交，开始事务后，进行的大量操作语句都保存在内存中，当提交时才全部写入数据库，此时，数据库文件也只用打开一次。如果操作错误，还可以回滚事务。

####1.4.1 基本使用

```
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
```
####1.4.2 FMDB多线程使用事务

```
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
```

---
### 1.5 加解密

* 使用`SQLCipher`进行加密，改之前的`pod 'FMDB'`为`pod 'FMDB/SQLCipher'`  `# FMDB with SQLCipher` 即可以用`cocoapods`来安装支持`SQLCipher`加密数据库的`FMDB`

* 使用`-[FMDatabase setKey:]`和`-[FMDatabase setKeyWithData:]`
来给数据库设置密码或者清除密码，使用`- [FMDatabase rekey:]`和`- [FMDatabase rekeyWithData:]`输入数据库密码以求验证用户身份。

这两类函数分别对`sqlite3_key`和`sqlite3_rekey`函数进行了封装。

使用方式与原来的方式一样，只需要数据库`open`之后调用`setKey`设置一下秘钥即可
下面摘了一段`FMDatabase`的`open`函数，在`sqlite3_open`成功后调用`setKey`方法设置秘钥

```
- (BOOL)open {
    if (_db) {
        return YES;
    }

    int err = sqlite3_open([self sqlitePath], &_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    } else {
        //数据库open后设置加密key
        [self setKey:encryptKey_];
    }

    if (_maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
    }

    return YES;
}
```


为了不修改`FMDB`的源代码，我们可以继承自`FMDatabase`类重写需要`setKey`的几个方法，这里我继承`FMDatabas`e定义了一个`JJEncryptDatabase`类，提供打开加密文件的功能

**JJEncryptDatabase.h**

```
#import "FMDatabase.h"

@interface JJEncryptDatabase : FMDatabase
+ (instancetype)databaseWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;

- (instancetype)initWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;
@end
```

**JJEncryptDatabase.m**

```
import "JJEncryptDatabase.h"

#import <sqlite3.h>

@interface JJEncryptDatabase (){
    NSString *_encryptKey;
}
@end

@implementation JJEncryptDatabase
+ (instancetype)databaseWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey {
    return [[[self class]alloc]initWithPath:aPath encryptKey:encryptKey];
    
}

- (instancetype)initWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey{
    if (self == [self initWithPath:aPath]) {
        _encryptKey = encryptKey;
    }
    return self;
}

#pragma mark 复写父类方法
- (BOOL)open {
    BOOL res = [super open];
    if (res && _encryptKey) {
        [self setKey:_encryptKey];
    }
    return res;
}

#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags vfs:(NSString *)vfsName {
    BOOL res = [super openWithFlags:flags vfs:vfsName];
    if (res && _encryptKey) {
        //数据库open后设置加密key
        [self setKey:_encryptKey];
    }
    return res;
}
#endif
@end
```

用法与`FMDatabase`一样，只是需要传入`secretKey`

**加密使用**

```
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    BOOL res = [JJEncryptHelper encryptDatabase:file encryptKey:self.encryptKey];
    
    NSString *msg = res ? @"encrypt success" : @"encrypt fail";
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
```

**解密使用**

```
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *file = [doc stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"%@",file);
    
    BOOL res = [JJEncryptHelper unEncryptDatabase:file encryptKey:@"123"];
    
    NSString *msg = res ? @"decrypt success" : @"decrypt fail";
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
```