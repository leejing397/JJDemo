//
//  ViewController.m
//  Realm使用说明
//
//  Created by Iris on 2018/3/30.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Dog.h"

#import <Realm.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self creatDataBaseWithName:@"jingjing"];
    [self save];
}

- (void) migration01{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 2;
    config.migrationBlock = ^(RLMMigration * _Nonnull migration, uint64_t oldSchemaVersion) {
        [migration enumerateObjects:Person.className
                              block:^(RLMObject *oldObject, RLMObject *newObject) {
                                  //处理v2.0的更新
                                  if (oldSchemaVersion < 2.0) {
                                      newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@", oldObject[@"firstName"], oldObject[@"lastName"]];
                                  }
                                  //处理v3.0的更新
                                  if(oldSchemaVersion < 3.0) {
                                      newObject[@"email"] = @"";
                                  }
                              }];
    };
}
#pragma mark 数据迁移
- (void)migration {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 1;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        //如果从没迁移过，oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // The enumerateObjects:block: method iterates
            // over every 'Person' object stored in the Realm file
            [migration enumerateObjects:Person.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                                      
                                      // 设置新增属性的值
                                      newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@",
                                                                oldObject[@"firstName"],
                                                                oldObject[@"lastName"]];
                                  }];
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    Person *person = [[Person alloc]init];
    person.fullName = @"张小明";
    
    person.cardID = @"10110";
    person.age = 1;
    
    Person *person1 = [[Person alloc]init];
    person1.fullName = @"昝小红";
    person1.cardID = @"19";
    person1.age = 9;
    
    [realm beginWriteTransaction];
    [realm addObject:person];
    [realm addOrUpdateObject:person1];
    [realm commitWriteTransaction];
}
#pragma mark 链式查询
- (void)chainedQuery {
    RLMResults *results1 = [Person objectsWhere:@"name contains %@",@"小"];
    RLMResults *results2 = [results1 objectsWhere:@"age = %d",11];
    for (Person *p in results2) {
//        NSLog(@"名字=%@,age=%ld",p.firstName,(long)p.age);
    }
}

#pragma mark 排序
- (void)sortedResults {
    RLMResults *results = [[Person objectsWhere:@"name contains %@",@"小"] sortedResultsUsingKeyPath:@"age" ascending:YES];
    for (Person *p in results) {
//        NSLog(@"名字=%@,age=%ld",p.firstName,(long)p.age);
    }
}
#pragma mark 谓词查询
- (void)inquiryPredicate {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name contains %@", @"小"];
    RLMResults *results = [Person objectsWithPredicate:pred];
    for (Person *p in results) {
//        NSLog(@"名字==%@",p.firstName);
    }
}

#pragma mark inquiry
- (void)inquiry{
    RLMResults *results = [Person objectsWhere:@"name contains %@",@"小"];
    for (Person *p in results) {
//        NSLog(@"名字==%@",p.firstName);
    }
}

#pragma mark 保存
- (void)save {
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    Person *person = [[Person alloc]init];
//    person.lastName = @"张";
//    person.firstName = @"明";
    person.cardID = @"10110";
    person.age = 1;
    
    Person *person1 = [[Person alloc]init];
//    person1.lastName = @"昝";
//    person1.firstName = @"红";
    person1.cardID = @"19";
    person1.age = 9;
    
    [realm beginWriteTransaction];
    [realm addObject:person];
    [realm addOrUpdateObject:person1];
    [realm commitWriteTransaction];
}

- (void)creatDataBaseWithName:(NSString *)databaseName {
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [docPath objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:databaseName];
    NSLog(@"数据库目录 = %@",filePath);
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [NSURL URLWithString:filePath];
    config.objectClasses = @[Person.class, Dog.class];
    config.readOnly = NO;
    int currentVersion = 1.0;
    config.schemaVersion = currentVersion;
    
    config.migrationBlock = ^(RLMMigration *migration , uint64_t oldSchemaVersion) {
        // 这里是设置数据迁移的block
        if (oldSchemaVersion < currentVersion) {
        }
    };
    
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
