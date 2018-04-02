Realm
##1.介绍
有需要请查看[Realm官网](https://realm.io/cn/)
###1.1 优点-跨平台、简单易用、可视化
#### 跨平台：现在很多应用都是要兼顾iOS和Android两个平台同时开发。如果两个平台都能使用相同的数据库，那就不用考虑内部数据的架构不同，使用Realm提供的API，可以使数据持久化层在两个平台上无差异化的转换。
#### 简单易用：Core Data 和 SQLite 冗余、繁杂的知识和代码足以吓退绝大多数刚入门的开发者，而换用 Realm，则可以极大地减少学习成本，立即学会本地化存储的方法。毫不吹嘘的说，把官方最新文档完整看一遍，就完全可以上手开发了。
#### 可视化：Realm 还提供了一个轻量级的数据库查看工具，在Mac Appstore 可以下载`Realm Browser`这个工具，开发者可以查看数据库当中的内容，执行简单的插入和删除数据的操作。毕竟，很多时候，开发者使用数据库的理由是因为要提供一些所谓的“知识库”。

###1.2 安装
使用`CocoaPods`安装
在项目的`Podfile`中，添加`pod 'Realm'`，在终端运行`pod install`。
##2.辅助工具安装
###2.1 Realm Studio-用于 Realm 数据库和 Realm 平台的开发者工具
[请点击下载](https://realm.io/products/realm-studio/)

###2.2 插件
用来快速创建model 
插件在压缩包里面
![](https://ws4.sinaimg.cn/large/006tNbRwly1fpuvr4nprmj30js0djmy6.jpg)

##3.Realm的使用
###3.1 Realm中的相关术语

①`RLMRealm`：Realm是框架的核心所在，是我们构建数据库的访问点，就如同Core Data的管理对象上下文（managed object context）一样。出于简单起见，realm提供了一个默认的defaultRealm( )的便利构造器方法。

---
②`RLMObject `:：这是我们自定义的Realm数据模型。创建数据模型的行为对应的就是数据库的结构。要创建一个数据模型，我们只需要继承RLMObject，然后设计我们想要存储的属性即可。

---
③`关系(Relationships)`：通过简单地在数据模型中声明一个RLMObject类型的属性，我们就可以创建一个“一对多”的对象关系。同样地，我们还可以创建“多对一”和“多对多”的关系。

---

④`写操作事务(Write Transactions)`：数据库中的所有操作，比如创建、编辑，或者删除对象，都必须在事务中完成。“事务”是指位于write闭包内的代码段。

---
⑤`查询(Queries)`：要在数据库中检索信息，我们需要用到“检索”操作。检索最简单的形式是对Realm( )数据库发送查询消息。如果需要检索更复杂的数据，那么还可以使用断言（predicates）、复合查询以及结果排序等等操作。

---
⑥`RLMResults`：这个类是执行任何查询请求后所返回的类，其中包含了一系列的RLMObject对象。RLMResults和NSArray类似，我们可以用下标语法来对其进行访问，并且还可以决定它们之间的关系。不仅如此，它还拥有许多更强大的功能，包括排序、查找等等操作。


##4. 简单使用

###4.1 创建模型--创建了Person类

`Person.h`

```
#import <Realm/Realm.h>

@interface Person : RLMObject
@property NSString *name;
@property NSInteger age;
@property NSString *cardID;
@property NSString *weight;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Person *><Person>
RLM_ARRAY_TYPE(Person)
```

`Person.m`

```
#import "Person.h"

@implementation Person

// Specify default values for properties
//主键
+ (NSString *)primaryKey
{
    return @"cardID";
}

//需要添加索引的属性
+ (NSArray *)indexedProperties {
    return @[@"title"];
}

//默认属性值
+ (NSDictionary *)defaultPropertyValues {
    return @{@"weight":@"100"};
}
@end
```

###4.2 存储数据

```
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    Person *person = [[Person alloc]init];
    person.name = @"小明";
    person.cardID = @"120110";
    [realm beginWriteTransaction];
    [realm addObject:person];
    [realm commitWriteTransaction];
```
运行,打开

`RLMRealm defaultRealm`在模拟器存放如下图：
![](https://ws3.sinaimg.cn/large/006tNbRwly1fpuwk333hej30hb09emys.jpg)
打开如下图：
![](https://ws4.sinaimg.cn/large/006tNbRwgy1fpux9z993bj30r00ckmy7.jpg)

###4.3 删除数据

1）删除指定的数据：

`- (void)deleteObject:(RLMObject *)object;`

先来存两个数据

```
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    Person *person = [[Person alloc]init];
    person.name = @"小明";
    person.cardID = @"120110";
    
    Person *person1 = [[Person alloc]init];
    person1.name = @"小红";
    person1.cardID = @"119";
    
    [realm beginWriteTransaction];
    [realm addObject:person];
    [realm addObject:person1];
    [realm commitWriteTransaction];
```

添加成功
![](https://ws2.sinaimg.cn/large/006tNbRwly1fpuxxf3tq1j30nh0cht9l.jpg)

* 删除小红这条数据

```
    RLMRealm *realm = [RLMRealm defaultRealm];
    //根据主键查找
    Person *person = [Person objectForPrimaryKey:@"119"];
    NSLog(@"%@",person.name);
    [realm beginWriteTransaction];
    [realm deleteObject:person];
    [realm commitWriteTransaction];
```

删除成功
![](https://ws2.sinaimg.cn/large/006tNbRwly1fpuy02iwojj30rb0d13zn.jpg)

2）删除一组数据：

`- (void)deleteObjects:(id)array;`

3）删除全部的数据：

`- (void)deleteAllObjects;`

###4.4 修改数据

修改数据如果该条数据不存在则会新建一条数据。

1）针对单个数据进行的修改或新增：

`- (void)addOrUpdateObject:(RLMObject *)object;`

* 例子：把小明的名字改成小小

```
    RLMRealm *realm = [RLMRealm defaultRealm];
    //根据主键查找
    Person *person = [Person objectForPrimaryKey:@"120110"];
    NSLog(@"%@",person.name);
    [realm beginWriteTransaction];
    person.name = @"小小";
    [realm addOrUpdateObject:person];
    [realm commitWriteTransaction];
    NSLog(@"%@",person.name);
```
修改成功

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fpuy5wnrwoj30rs0dx40y.jpg)
数据库
![](https://ws1.sinaimg.cn/large/006tNbRwgy1fpuy81q6lij30od0biwfa.jpg)
2）针对一组数据的修改或新增：

`- (void)addOrUpdateObjectsFromArray:(id)array;`

`说明：对于增加、删除、修改必须要在事务中进行操作。`

###4.5 查询数据
1）查询全部数据

`RLMResults *results = [Person allObjects];`

或指定Realm数据库：

```
NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
NSString *realmPath = [path stringByAppendingPathComponent:@"你数据库的名字.realm"];
RLMRealm *realm = [RLMRealm realmWithPath:realmPath];
RLMResults *results = [Person allObjectsInRealm:realm];

```
2）条件查询

查询`name`中带有`小`的

新加了几条数据
![](https://ws2.sinaimg.cn/large/006tNbRwgy1fpuynfipufj30mn09j0tk.jpg)

查询

```
    RLMResults *results = [Person objectsWhere:@"name contains %@",@"小"];
    for (Person *p in results) {
        NSLog(@"名字==%@",p.name);
    }
```

查询成功
![](https://ws4.sinaimg.cn/large/006tNbRwly1fpuyxke3uhj30rr0dftao.jpg)

也可以使用谓词查询：

```
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name contains %@", @"小"];
    RLMResults *results = [Person objectsWithPredicate:pred];
    for (Person *p in results) {
        NSLog(@"名字==%@",p.name);
    }

```

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fpuz23ewi3j30s00gtjuc.jpg)

3）条件排序

假设要查询所有分组是iOS和作者是zengjing的文章，然后筛选出来的结果按照num字段进行递增排序：

```
    RLMResults *results = [[Person objectsWhere:@"name contains %@",@"小"] sortedResultsUsingKeyPath:@"age" ascending:YES];
    for (Person *p in results) {
        NSLog(@"名字=%@,age=%ld",p.name,(long)p.age);
    }

```
![](https://ws2.sinaimg.cn/large/006tNbRwly1fpuzf9pmddj30r50ewjua.jpg)

4）链式查询(结果过滤)

假设要查询所有所属分组是iOS的文章，然后从中筛选出作者是zengjing的数据：

```
    RLMResults *results1 = [Person objectsWhere:@"name contains %@",@"小"];
    RLMResults *results2 = [results1 objectsWhere:@"age = '11'"];
    for (Person *p in results2) {
        NSLog(@"名字=%@,age=%ld",p.name,(long)p.age);
    }
```
![](https://ws4.sinaimg.cn/large/006tNbRwgy1fpuzivzlw0j30rb0f10vl.jpg)

###4.6 通知
每当一次写事务完成Realm实例都会向其他线程上的实例发出通知，可以通过注册一个block来响应通知

```
self.token = [realm addNotificationBlock:^(NSString *note, RLMRealm * realm) {
    [_listTableView reloadData];
}];
```

只要有任何的引用指向这个返回的notification token，它就会保持激活状态。在这个注册更新的类里，你需要有一个强引用来钳制这个token， 因为一旦notification token被释放，通知也会自动解除注册。

`@property (nonatomic, strong) RLMNotificationToken *token;`

另外可以使用下面的方式解除通知：

`[realm removeNotification:self.token];`

###4.7 数据库迁移
####4.7.1 版本迁移
当你和数据库打交道的时候，时不时的你需要改变数据模型（model），但因为Realm中得数据模型被定义为标准的Objective-C interfaces，要改变模型，就像改变其他Objective-C interface一样轻而易举。举个例子，假设有个数据模型`Person`:
在v1.0中数据模型如下：

```
#import <Realm/Realm.h>

@interface Person : RLMObject
@property NSInteger age;
@property NSString *cardID;
@property NSString *weight;
@property NSString *firstName;
@property NSString *lastName;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Person *><Person>
RLM_ARRAY_TYPE(Person)
```
升级到v2.0之后将`firstName`和`lastName`字段合并为一个字段`fullName`

```
#import <Realm/Realm.h>

@interface Person : RLMObject
@property NSInteger age;
@property NSString *cardID;
@property NSString *weight;
@property NSString *fullName; // new property
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Person *><Person>
RLM_ARRAY_TYPE(Person)
```
保存了两条数据

```
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    Person *person = [[Person alloc]init];
    person.lastName = @"张";
    person.firstName = @"明";
    person.cardID = @"10110";
    person.age = 1;
    
    Person *person1 = [[Person alloc]init];
    person1.lastName = @"昝";
    person1.firstName = @"红";
    person1.cardID = @"19";
    person1.age = 9;
    
    [realm beginWriteTransaction];
    [realm addObject:person];
    [realm addOrUpdateObject:person1];
    [realm commitWriteTransaction];
```
保存成功
![](https://ws1.sinaimg.cn/large/006tKfTcgy1fpy2cw2tlej30qx0dcab9.jpg)

数据迁移代码

```
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
```

迁移后保存示例：

```
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
```
保存成功
![](https://ws4.sinaimg.cn/large/006tKfTcgy1fpy2jlorjvj30qy0bg75c.jpg)

当版本升级到3.0时，添加新的属性`email`

```
// v3.0
@interface Person : RLMObject
@property NSString *fullName;
@property NSString *email;   // new property
@property int age;
@end
```

迁移代码

```
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
```

####4.7.2 在迁移的过程中重命名属性名称

```
RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
config.schemaVersion = 1;
config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
  // We haven’t migrated anything yet, so oldSchemaVersion == 0
  if (oldSchemaVersion < 1) {
    // The renaming operation should be done outside of calls to `enumerateObjects:`.
    [migration renamePropertyForClass:Person.className oldName:@"yearsSinceBirth" newName:@"age"];
  }
};
[RLMRealmConfiguration setDefaultConfiguration:config];
```

####4.8 自定义数据库

```
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

```

####4.9 内存数据库

通常情况下，`Realm`数据库是存储在硬盘中的，但是您能够通过设置`inMemoryIdentifier`而不是设置`RLMRealmConfiguration`中的`fileURL`属性，以创建一个完全在内存中运行的数据库。

```
RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];config.inMemoryIdentifier = @"MyInMemoryRealm";RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:nil];
```

内存数据库在每次程序运行期间都不会保存数据。但是，这不会妨碍到 Realm 的其他功能，包括查询、关系以及线程安全。

如果需要一种灵活的数据读写但又不想储存数据的方式的话，那么可以选择用内存数据库。(关于内存数据库的性能 和 类属性的 性能，还没有测试过，感觉性能不会有太大的差异，所以内存数据库使用场景感觉不多)

使用内存数据库需要注意的是：

①内存数据库会在临时文件夹中创建多个文件，用来协调处理诸如跨进程通知之类的事务。 实际上没有任何的数据会被写入到这些文件当中，除非操作系统由于内存过满需要清除磁盘上的多余空间。

②如果某个内存 Realm 数据库实例没有被引用，那么所有的数据就会被释放。所以必须要在应用的生命周期内保持对Realm内存数据库的强引用，以避免数据丢失。

参考：
https://halfrost.com/realm_ios/