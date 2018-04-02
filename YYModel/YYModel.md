##YYModel使用
![](https://ws4.sinaimg.cn/large/006tKfTcly1fpydapj8s6j314o0aowg0.jpg)

##1.自定义属性映射
`+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;`

例子：

```
//自定义类的属性
@property NSString      *name;
@property NSInteger     page;
@property NSString      *desc;
@property NSString      *bookID;
```

```
//JSON
{
    "n":"Harry Pottery",
    "p": 256,
    "ext" : {
        "desc" : "A book written by J.K.Rowing."
    },
    "id" : 100010
}
```

```
//custom属性，让 json key 映射到 对象的属性。  该方法在自
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name" : @"n",
             @"page" : @"p",
             @"desc" : @"ext.desc",                 //key.path
             @"bookID" : @[@"ID",@"id",@"book_id"]};
    //从 json 过来的key 可以是id，ID，book_id。例子中 key 为 id。
}
```
使用这个方法需要在自定义类里面重写该方法。
##2.自定义容器映射
假如你的对象里面有容器（set，array，dic），你可以指定类型中的对象类型，因为`YYModel`是不知道你容器中储存的类型的。在`dic`中，你指定的是它` value `的类型。

`+ ( NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;`


```
@interface YYAuthor : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSDate *birthday;
@end

@interface User : NSObject
@property UInt64        uid;
@property NSString      *bookname;
@property (nonatomic, strong)   NSMutableArray<YYAuthor *>    *authors;
@end
```

```
//Json数据
{
    "uid":123456,
    "bookname":"Harry",
    "authors":[
               {
               "birthday":"1991-07-31T08:00:00+0800",
               "name":"G.Y.J.jeff"
               },
               {
               "birthday":"1990-07-31T08:00:00+0800",
               "name":"Z.Q.Y,jhon"
               }
               ]
}

```

```
\\相当于泛型说明
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"authors" : [YYAuthor class]};
}
```

##3.根据字典返回类型
这个方法是可以根据字典里面的数据来指定当前对象的类型。
我对这个方法的理解，假如`Person`是父类，其子类是`Man`,`Woman`。这个时候你可以根据`dic["sex"]`中的`value`，比如`value`为`NSString`的`Man`，在重写的方法里 `return Man`.这个时候，你当前的字典转模型的实例就是`Man`的实例对象。

注：这就是多态

`+ (nullable Class)modelCustomClassForDictionary:(NSDictionary*)dictionary;`


```
//.h
@interface Person : NSObject
@property (nonatomic, copy)     NSString        *name;
@property (nonatomic, assign)   NSUInteger      age;
@end

@interface Man : Person
@property (nonatomic, copy)     NSString        *wifeName;
@end

@interface Woman : Person
@property (nonatomic, copy)     NSString        *husbandName;
@end
```

```
//.m
+ (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary {
    if (dictionary[@"sex"] != nil) {
        NSString *runClass = dictionary[@"sex"];
        return NSClassFromString(runClass);
    } else {
        return [self class];
    }
}
```

```
NSData *dataPerson = [self dataWithPath:@"person"];
Person *person = [Person modelWithJSON:dataPerson];
[person modelDescription];
这个时候你会发现，当前person的类实际上是 Man，而不是 Person。
```

##4.白名单，黑名单

```
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist; 黑名单
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;; 白名单
```

```
这两个比较简单。
黑名单，故名思议，黑名单中的属性不会参与字典转模型。
白名单使用比较极端，你用了之后，只有白名单中的属性会参与字典转模型，其他属性都不参与。不推荐使用。
```

##5.更改字典信息
该方法发生在字典转模型之前。 最后对网络字典做一次处理。
```- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;```


```
.h文件
#import <Foundation/Foundation.h>

/*
 {
 "name":"Jeff",
 "age":"26",
 "sex":"Man",
 "wifeName":"ZQY"
 }
 */
@interface Person : NSObject
@property NSString *name;
@property NSString *age;
@property NSString *sex;
@property NSString *wifeName;

@end
```

```
.m文件
#import "Person.h"

#import <YYModel.h>

@implementation Person
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    if ([dic[@"sex"] isEqualToString:@"Man"]) {
        return nil;//这里简单演示下，直接返回 nil。相当于不接受男性信息。
    }
    return dic;//女性则不影响字典转模型。
}
@end

```
测试
//原来json
{
"name":"Jeff",
"age":"26",
"sex":"Man",
"wifeName":"ZQY"
}
```
![](https://ws1.sinaimg.cn/large/006tKfTcly1fpybnqau7vj30rv0gp76k.jpg)

```
//更改后json
{
"name":"Jeff",
"age":"26",
"sex":"Woman",
"wifeName":"ZQY"
}
```
![](https://ws1.sinaimg.cn/large/006tKfTcgy1fpybko85nfj30rs0gpdia.jpg)

##6.字典转模型补充
```- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;  ```

```
#import <Foundation/Foundation.h>
User模型
.h文件
/*
 {
 "uid":123456,
 "bookname":"Harry",
 "created":"1965-07-31T00:00:00+0000",
 "timestamp" : 1445534567
 }
 */
@interface User : NSObject
@property UInt64 uid;
@property NSDate *created;
@property NSDate *createdAt;
@property NSString *bookname;
@end
```
.m文件

```
#import "User.h"

#import <YYModel.h>

@implementation User

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *timestamp = dic[@"timestamp"];
    if (![timestamp isKindOfClass:[NSNumber class]]) return NO;
    _createdAt = [NSDate dateWithTimeIntervalSince1970:timestamp.floatValue];
    return YES;
}

@end
```
实现

```
    User *user = [User yy_modelWithDictionary:@{
                                                @"uid":@123456,
                                                @"bookname":@"Harry",
                                                @"created":@"1965-07-31T00:00:00+0000",
                                                @"timestamp" :@1445534567
                                                }];
    NSLog(@"%@",user);
    
```
![](https://ws1.sinaimg.cn/large/006tKfTcgy1fpycaxpqvqj30ry0hh0vi.jpg)

字典转模型结束后`createdAt`属性应该是空的，因为```timestamp``` 和 ```createdAt``` 不一样。但你在这里赋值，手动把```timestamp```的属性赋值给```_createdAt```.这个有点类似第一点的 自定义属性映射（本篇文章第一条）。
注：此处如果` return NO`,`dic->model`将失败。


##7.模型转字典补充
```- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;```
这个方法和第6条是相对应的关系。这里是`model->json`的补充。
假如自己model 中有_createdAt，那 model 转到 json 中的```timestamp```会被赋值。

注：此处如果 return NO,model->dict将失败。

.m文件

```
//模型转字典补充
-(BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (!_createdAt) return NO;
    dic[@"timestamp"] = @(_createdAt.timeIntervalSince1970);
    return YES;
}
```
测试

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    User *user = [User yy_modelWithDictionary:@{
                                                @"uid":@123456,
                                                @"bookname":@"Harry",
                                                @"created":@"1965-07-31T00:00:00+0000",
                                                @"timestamp" :@1445534567
                                                }];
    NSLog(@"%@",user);
    
    NSString *userStr = [user yy_modelToJSONString];
    NSLog(@"%@",userStr);

}
```
结果如图：
![](https://ws1.sinaimg.cn/large/006tKfTcgy1fpyco433oij30rx0gaq6d.jpg)

##8.字典用法和数组的用法
`+ (nullable NSArray *)yy_modelArrayWithClass:(Class)cls json:(id)json;`
`+ (nullable NSDictionary *)yy_modelDictionaryWithClass:(Class)cls json:(id)json;`

模型

```
#import <Foundation/Foundation.h>

/*
 [{"birthday":"1991-07-31T08:00:00+0800",
 "name":"G.Y.J.jeff"},
 {"birthday":"1990-07-31T08:00:00+0800",
 "name":"Z.Q.Y,jhon"}]
 */
@interface Author : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSString *birthday;
@end
```
实现
```
    NSArray *array = @[@{@"birthday":@"1991-07-31T08:00:00+0800",
        @"name":@"G.Y.J.jeff"},
    @{@"birthday":@"1990-07-31T08:00:00+0800",
      @"name":@"Z.Q.Y,jhon"}];
    NSArray *arrT = [NSArray yy_modelArrayWithClass:[Author class] json:array];
    NSLog(@"arrT = %@",arrT);
```

结果如图：
![](https://ws4.sinaimg.cn/large/006tKfTcgy1fpycz8b6uzj30rt0g0diz.jpg)


##9.长城demo示例
建立模型`GXSNAttaches`

```
@interface GXSNAttaches:NSObject
@property (nonatomic,copy)NSString *attach_url;
@property (nonatomic,copy)NSString *photo_angle;
@end
```

建立模型`SNTouristCollectCircleModel`

```
@interface SNTouristCollectCircleModel : NSObject
@property (nonatomic,copy)NSString *address;
@property (nonatomic,copy)NSString *name;//游客姓名
@property (nonatomic,copy)NSString *phone;//游客手机号码
@property (nonatomic,copy)NSString *recordID;//记录ID
@property (nonatomic,copy)NSString *condition_info;//情况说明
@property (nonatomic,copy)NSString *submit_time;//提交时间
@property (nonatomic,copy)NSString *AFFIRM_NAME;//长城点段

@property (nonatomic,copy)NSString *abnormal_status;//是否正常
@property (nonatomic,copy)NSString *headImageUrl;//头像地址
@property (nonatomic,strong)NSMutableArray <GXSNAttaches*>*gwattachs;
```

示例json

```
{
    "touristRecords":[
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"d373542a-97ad-4ccf-9d8f-1f26956fba0a",
                "gwresource_code":"110117382106170097",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-27 13:20:04",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"本来咯弄库存也许讨论我饿也他太差补new的我窝窝头木讷头目嘟嘟存在特特哦9也特也额快车可也8特鲁测量5242175893",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.297424,
                "latitude":39.94399,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-27 13:25:58",
                "position_info":null,
                "check_status":"0",
                "check_time":null,
                "check_log_id":"2bed0eec-5bb6-4270-a37f-83edfd4c6a63",
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930349,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11320491
                    },
                    "PROVINCENAME":"北京市",
                    "CITYNAME":"北京市",
                    "COUTYNAME":"平谷区",
                    "AFFIRM_CODE":"110117382106170097",
                    "AFFIRM_POSITION":"起点：镇罗营史家台村东南约1250止点：镇罗营乡玻璃台村西约750",
                    "AFFIRM_NAME":"镇罗营玻璃台长城2段（平谷区长城总97段）",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "POLITICS":"110117",
                    "CRCODE":"110117382106170097",
                    "GWTYPE":"382106",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"1",
                    "MATERIAL":"5",
                    "WALLLENGTH":"1346",
                    "PRESERVATION1":"0",
                    "PRESERVATION2":"0",
                    "PRESERVATION3":"0",
                    "PRESERVATION4":"0",
                    "PRESERVATION5":"0",
                    "gwurl":[
                    ],
                    "longitude":117.22872222222223,
                    "latitude":40.31372222222222
                }
            ],
            "gwattachs":[
                {
                    "id":"06c5845b-30f3-4265-92f6-507582381602",
                    "tb_name":"tourist_collect_record",
                    "work_id":"d373542a-97ad-4ccf-9d8f-1f26956fba0a",
                    "attach_column":null,
                    "attach_name":"Screenshot_2018-02-27-10-57-32-78.png",
                    "attach_realname":"1519709157550.png",
                    "attach_url":"/resources/image/1519709157550.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 13:20:30"
                },
                {
                    "id":"56fe1443-9363-4d01-a6d7-29345f68a7e5",
                    "tb_name":"tourist_collect_record",
                    "work_id":"d373542a-97ad-4ccf-9d8f-1f26956fba0a",
                    "attach_column":null,
                    "attach_name":"video_1519708835536.mp4",
                    "attach_realname":"1519709157813.mp4",
                    "attach_url":"/resources/image/1519709157813.mp4",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 13:20:39"
                },
                {
                    "id":"747a1163-8467-41b3-a2cd-2db8f6753bf4",
                    "tb_name":"tourist_collect_record",
                    "work_id":"d373542a-97ad-4ccf-9d8f-1f26956fba0a",
                    "attach_column":null,
                    "attach_name":"img-84c76a6d6964d8395a934e9624b9713d.gif",
                    "attach_realname":"1519709157489.gif",
                    "attach_url":"/resources/image/1519709157489.gif",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 13:20:52"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"6421e3b8-f63d-479c-9adc-61d133a75b70",
                "gwresource_code":"130281382102170005",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-27 11:01:02",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"测试2.27.1啊Dell默默摸摸哦哦默默呃呃呃的得得得得得得的Dell的额DellKKK的KKK咯JJ",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.297646,
                "latitude":39.94403,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-27 11:01:54",
                "position_info":null,
                "check_status":"0",
                "check_time":null,
                "check_log_id":"e563487d-ce5b-45a6-ac46-113d8e65aa72",
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930397,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11335083
                    },
                    "PROVINCENAME":"河北省",
                    "CITYNAME":"唐山市",
                    "COUTYNAME":"遵化市",
                    "AFFIRM_CODE":"130281382102170005",
                    "AFFIRM_POSITION":"东庄自然村西北约1.2千米处",
                    "AFFIRM_NAME":"洪山口长城1段",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"省保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "POLITICS":"130281",
                    "CRCODE":"130281382102170005",
                    "GWTYPE":"382102",
                    "DYNASTY":"17",
                    "LEVEL":"2",
                    "PRESERVATION":"2",
                    "MATERIAL":"2",
                    "WALLLENGTH":"485",
                    "PRESERVATION1":"0",
                    "PRESERVATION2":"268",
                    "PRESERVATION3":"217",
                    "PRESERVATION4":"0",
                    "PRESERVATION5":"0",
                    "gwurl":[
                    ],
                    "longitude":118.1013611111111,
                    "latitude":40.353972222222225
                }
            ],
            "gwattachs":[
                {
                    "id":"0fcc82ba-650e-4604-81db-9d78f6d89de4",
                    "tb_name":"tourist_collect_record",
                    "work_id":"6421e3b8-f63d-479c-9adc-61d133a75b70",
                    "attach_column":null,
                    "attach_name":"video_1519700175474.mp4",
                    "attach_realname":"1519700514155.mp4",
                    "attach_url":"/resources/image/1519700514155.mp4",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 10:56:21"
                },
                {
                    "id":"19dbe350-1b20-48ba-89c6-7b863e96ac7a",
                    "tb_name":"tourist_collect_record",
                    "work_id":"6421e3b8-f63d-479c-9adc-61d133a75b70",
                    "attach_column":null,
                    "attach_name":"Screenshot_2018-02-27-10-43-55-23.png",
                    "attach_realname":"1519700514124.png",
                    "attach_url":"/resources/image/1519700514124.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 10:56:34"
                },
                {
                    "id":"6649abbb-0eae-4e57-b101-a2fc56917d8e",
                    "tb_name":"tourist_collect_record",
                    "work_id":"6421e3b8-f63d-479c-9adc-61d133a75b70",
                    "attach_column":null,
                    "attach_name":"VCG21gic3742093.jpg",
                    "attach_realname":"1519700514064.jpg",
                    "attach_url":"/resources/image/1519700514064.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 10:56:02"
                },
                {
                    "id":"af1a5e0d-9a36-4cd2-8282-0da99f9c1a09",
                    "tb_name":"tourist_collect_record",
                    "work_id":"6421e3b8-f63d-479c-9adc-61d133a75b70",
                    "attach_column":null,
                    "attach_name":"img-5ff0b7b00e79a9c118c79252d865886f.jpg",
                    "attach_realname":"1519700514064.jpg",
                    "attach_url":"/resources/image/1519700514064.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 10:55:53"
                }
            ]
        },
        {
            "tourist":{
                "id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "name":"小熊。。。",
                "sex":1,
                "phone":"17301046265",
                "birth":"2017-10-19 00:00:00",
                "email":"1026002106@qq.com",
                "create_time":null,
                "username":"17301046265",
                "password":null,
                "headImageUrl":"/resources/image/1518229336121.jpg"
            },
            "touristRecord":{
                "id":"a852ac1f-f6b6-47ca-af9c-fa94ffb99a23",
                "gwresource_code":"110116352101170170",
                "tourist_id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "save_time":"2018-02-27 10:54:22",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"测试",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.295296,
                "latitude":39.944397,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-27 10:55:04",
                "position_info":null,
                "check_status":"0",
                "check_time":null,
                "check_log_id":"7321391e-5cab-4726-9a1b-ae52d19e2eaf",
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930348,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11319940
                    },
                    "PROVINCENAME":"北京市",
                    "CITYNAME":"北京市",
                    "COUTYNAME":"怀柔区",
                    "AFFIRM_CODE":"110116352101170170",
                    "AFFIRM_POSITION":"渤海镇庄户村东南1700米",
                    "AFFIRM_NAME":"渤海镇庄户村南170号敌台",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "POLITICS":"110116",
                    "CRCODE":"110116352101170170",
                    "GWTYPE":"352101",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"1",
                    "MATERIAL":"2",
                    "gwurl":[
                        {
                            "_id":{
                                "timestamp":1518234260,
                                "machineIdentifier":12270539,
                                "processIdentifier":29645,
                                "counter":11081524
                            },
                            "AFFIRM_CODE":"110116352101170170",
                            "URL":"/resources/image/1518234260753.jpg",
                            "SHZT":1,
                            "CJSJ":"2018-02-10 11:44:21"
                        }
                    ],
                    "longitude":116.49161111111111,
                    "latitude":40.461444444444446
                }
            ],
            "gwattachs":[
                {
                    "id":"266c1066-a7ba-4f48-b882-5320de602198",
                    "tb_name":"tourist_collect_record",
                    "work_id":"a852ac1f-f6b6-47ca-af9c-fa94ffb99a23",
                    "attach_column":null,
                    "attach_name":"IMG_20180210174801.jpg",
                    "attach_realname":"1519700103685.jpg",
                    "attach_url":"/resources/image/1519700103685.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 10:54:39"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"1206f0fc-1eda-4db3-86ec-2acbb8b39afc",
                "gwresource_code":"150430382102020031",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-27 10:51:34",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"测试2.27",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29778,
                "latitude":39.944008,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-27 10:53:02",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-02-27 11:26:04",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930332,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11316098
                    },
                    "PROVINCENAME":"内蒙古自治区",
                    "CITYNAME":"赤峰市",
                    "COUTYNAME":"敖汉旗",
                    "AFFIRM_CODE":"150430382102020031",
                    "AFFIRM_POSITION":"起点：丰收乡二上营子村西南2.42千米止点：丰收乡格斗营子村东南0.54千米",
                    "AFFIRM_NAME":"格斗营子长城1段",
                    "AFFIRM_DYNASTY":"战国燕",
                    "AFFIRM_LEVEL":"省保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "AFFIRM_LEVEL_OLD":"无",
                    "POLITICS":"150430",
                    "CRCODE":"150430382102020031",
                    "GWTYPE":"382102",
                    "DYNASTY":"02",
                    "LEVEL":"2",
                    "PRESERVATION":"3",
                    "MATERIAL":"2",
                    "WALLLENGTH":"3012",
                    "PRESERVATION1":0,
                    "PRESERVATION2":0,
                    "PRESERVATION3":1882,
                    "PRESERVATION4":1130,
                    "PRESERVATION5":0,
                    "gwurl":[
                    ],
                    "longitude":120.05302777777777,
                    "latitude":42.162305555555555
                }
            ],
            "gwattachs":[
                {
                    "id":"bcb3dea0-a937-40c3-a514-f316ccc7b844",
                    "tb_name":"tourist_collect_record",
                    "work_id":"1206f0fc-1eda-4db3-86ec-2acbb8b39afc",
                    "attach_column":null,
                    "attach_name":"img-289b43a7d2101511ec04d2bed30f3091.jpg",
                    "attach_realname":"1519699981586.jpg",
                    "attach_url":"/resources/image/1519699981586.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 10:52:34"
                },
                {
                    "id":"e7f72786-329e-48c4-9417-2b4af106ed1c",
                    "tb_name":"tourist_collect_record",
                    "work_id":"1206f0fc-1eda-4db3-86ec-2acbb8b39afc",
                    "attach_column":null,
                    "attach_name":"IMG20180223162622.jpg",
                    "attach_realname":"1519699981596.jpg",
                    "attach_url":"/resources/image/1519699981596.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-27 10:51:56"
                }
            ]
        },
        {
            "tourist":{
                "id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "name":"小熊。。。",
                "sex":1,
                "phone":"17301046265",
                "birth":"2017-10-19 00:00:00",
                "email":"1026002106@qq.com",
                "create_time":null,
                "username":"17301046265",
                "password":null,
                "headImageUrl":"/resources/image/1518229336121.jpg"
            },
            "touristRecord":{
                "id":"9abdbf75-8041-4896-ba06-ab100feeeb38",
                "gwresource_code":"130303352101170042",
                "tourist_id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "save_time":"2018-02-10 15:13:19",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"测试",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.2954,
                "latitude":39.94436,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-10 15:17:33",
                "position_info":null,
                "check_status":"1",
                "check_time":null,
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":null,
                "check_user_id":null,
                "check_user_level":null,
                "check_user_alias":null,
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930391,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11333122
                    },
                    "PROVINCENAME":"河北省",
                    "CITYNAME":"秦皇岛市",
                    "COUTYNAME":"山海关区",
                    "AFFIRM_CODE":"130303352101170042",
                    "AFFIRM_POSITION":"位于秦皇岛市山海关区北水关上",
                    "AFFIRM_NAME":"北水关敌台",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "POLITICS":"130303",
                    "CRCODE":"130303352101170042",
                    "GWTYPE":"352101",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"1",
                    "MATERIAL":"3",
                    "gwurl":[
                        {
                            "_id":{
                                "timestamp":1518231549,
                                "machineIdentifier":12270539,
                                "processIdentifier":29645,
                                "counter":11081509
                            },
                            "AFFIRM_CODE":"130303352101170042",
                            "URL":"/resources/image/1518231549592.jpg",
                            "SHZT":1,
                            "CJSJ":"2018-02-10 10:59:09"
                        }
                    ],
                    "longitude":119.74472222222222,
                    "latitude":40.02111111111111
                }
            ],
            "gwattachs":[
                {
                    "id":"e8fcd7cc-2de6-421c-8d18-05f6ce75c191",
                    "tb_name":"tourist_collect_record",
                    "work_id":"9abdbf75-8041-4896-ba06-ab100feeeb38",
                    "attach_column":null,
                    "attach_name":"IMG_20180210_134905.jpg",
                    "attach_realname":"1518247053282.jpg",
                    "attach_url":"/resources/image/1518247053282.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-10 15:14:13"
                }
            ]
        },
        {
            "tourist":{
                "id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "name":"小熊。。。",
                "sex":1,
                "phone":"17301046265",
                "birth":"2017-10-19 00:00:00",
                "email":"1026002106@qq.com",
                "create_time":null,
                "username":"17301046265",
                "password":null,
                "headImageUrl":"/resources/image/1518229336121.jpg"
            },
            "touristRecord":{
                "id":"1dcd3e5f-31f3-4f88-b340-0d9b267c89cf",
                "gwresource_code":"110228382106170028",
                "tourist_id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "save_time":"2018-02-10 10:29:09",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"开发人员测试",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.297386,
                "latitude":39.943665,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-10 10:31:07",
                "position_info":null,
                "check_status":"1",
                "check_time":null,
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":null,
                "check_user_id":null,
                "check_user_level":null,
                "check_user_alias":null,
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930349,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11320277
                    },
                    "PROVINCENAME":"北京市",
                    "CITYNAME":"北京市",
                    "COUTYNAME":"密云县",
                    "AFFIRM_CODE":"110228382106170028",
                    "AFFIRM_POSITION":"新城子镇吉家营村委会西石虎村南山上",
                    "AFFIRM_NAME":"密云28号墙体（山险",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "POLITICS":"110228",
                    "CRCODE":"110228382106170028",
                    "GWTYPE":"382106",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"1",
                    "MATERIAL":"5",
                    "WALLLENGTH":"1900",
                    "PRESERVATION1":"0",
                    "PRESERVATION2":"0",
                    "PRESERVATION3":"0",
                    "PRESERVATION4":"0",
                    "PRESERVATION5":"0",
                    "gwurl":[
                    ],
                    "longitude":117.33719444444444,
                    "latitude":40.58811111111111
                }
            ],
            "gwattachs":[
                {
                    "id":"0c99ebd6-ff28-4086-820e-e3468c91e8fa",
                    "tb_name":"tourist_collect_record",
                    "work_id":"1dcd3e5f-31f3-4f88-b340-0d9b267c89cf",
                    "attach_column":null,
                    "attach_name":"IMG_20180206142833_744.jpg",
                    "attach_realname":"1518229866850.jpg",
                    "attach_url":"/resources/image/1518229866850.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-10 10:29:37"
                }
            ]
        },
        {
            "tourist":{
                "id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "name":"小熊。。。",
                "sex":1,
                "phone":"17301046265",
                "birth":"2017-10-19 00:00:00",
                "email":"1026002106@qq.com",
                "create_time":null,
                "username":"17301046265",
                "password":null,
                "headImageUrl":"/resources/image/1518229336121.jpg"
            },
            "touristRecord":{
                "id":"ddd8f111-ac20-483c-9b59-36976524bc30",
                "gwresource_code":"110117352101170111",
                "tourist_id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "save_time":"2018-02-10 10:19:53",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29719,
                "latitude":39.943535,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-10 10:20:38",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-03-03 16:39:08",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930345,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11319187
                    },
                    "PROVINCENAME":"北京市",
                    "CITYNAME":"北京市",
                    "COUTYNAME":"平谷区",
                    "AFFIRM_CODE":"110117352101170111",
                    "AFFIRM_POSITION":"黄松峪乡太平庄村北450米",
                    "AFFIRM_NAME":"平谷区长城段86号敌台（玻璃台长城段3号台）",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "POLITICS":"110117",
                    "CRCODE":"110117352101170111",
                    "GWTYPE":"352101",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"3",
                    "MATERIAL":"3",
                    "gwurl":[
                    ],
                    "longitude":117.23011111111111,
                    "latitude":40.310583333333334
                }
            ],
            "gwattachs":[
                {
                    "id":"7d04ee1b-f849-4656-80de-78bac41ff5e0",
                    "tb_name":"tourist_collect_record",
                    "work_id":"ddd8f111-ac20-483c-9b59-36976524bc30",
                    "attach_column":null,
                    "attach_name":"IMG_20171212_082259.jpg",
                    "attach_realname":"1518229238027.jpg",
                    "attach_url":"/resources/image/1518229238027.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-10 10:20:03"
                }
            ]
        },
        {
            "tourist":{
                "id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "name":"小熊。。。",
                "sex":1,
                "phone":"17301046265",
                "birth":"2017-10-19 00:00:00",
                "email":"1026002106@qq.com",
                "create_time":null,
                "username":"17301046265",
                "password":null,
                "headImageUrl":"/resources/image/1518229336121.jpg"
            },
            "touristRecord":{
                "id":"750f8b50-eebb-4591-92c6-1f1b605d316b",
                "gwresource_code":"130323353201170303",
                "tourist_id":"380f5907-3489-433a-9cd2-b2cf1335e323",
                "save_time":"2018-02-10 09:56:00",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"shshsh",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.297104,
                "latitude":39.94358,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-10 10:16:54",
                "position_info":null,
                "check_status":"1",
                "check_time":null,
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":null,
                "check_user_id":null,
                "check_user_level":null,
                "check_user_alias":null,
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930394,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11334010
                    },
                    "PROVINCENAME":"河北省",
                    "CITYNAME":"秦皇岛市",
                    "COUTYNAME":"抚宁县",
                    "AFFIRM_CODE":"130323353201170303",
                    "AFFIRM_POSITION":"石碑沟村东北0.64千米",
                    "AFFIRM_NAME":"罗汉洞01号烽火台",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"省保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "POLITICS":"130323",
                    "CRCODE":"130323353201170536",
                    "GWTYPE":"353201",
                    "DYNASTY":"17",
                    "LEVEL":"2",
                    "PRESERVATION":"4",
                    "MATERIAL":"2",
                    "gwurl":[
                    ],
                    "longitude":119.23788888888889,
                    "latitude":40.152499999999996
                }
            ],
            "gwattachs":[
                {
                    "id":"ff809f82-18fe-4f76-8fb3-e046e259baf2",
                    "tb_name":"tourist_collect_record",
                    "work_id":"750f8b50-eebb-4591-92c6-1f1b605d316b",
                    "attach_column":null,
                    "attach_name":"IMG_20180208085501.jpg",
                    "attach_realname":"1518227864396.jpg",
                    "attach_url":"/resources/image/1518227864396.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-10 09:56:33"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"09ee2e08-6bad-47d7-a6ac-a3c63d22cf16",
                "gwresource_code":"150823382102030056",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-09 16:06:57",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29716,
                "latitude":39.944,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-09 16:43:59",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-02-09 16:48:31",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930333,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11316484
                    },
                    "PROVINCENAME":"内蒙古自治区",
                    "CITYNAME":"巴彦淖尔市",
                    "COUTYNAME":"乌拉特前旗",
                    "AFFIRM_CODE":"150823382102030056",
                    "AFFIRM_POSITION":"起点：小佘太镇新村行政村西北11.8千米处止点：小佘太镇新村行政村西北11.9千米处",
                    "AFFIRM_NAME":"新村长城6段",
                    "AFFIRM_DYNASTY":"秦汉",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "POLITICS":"150823",
                    "CRCODE":"150823382102030056",
                    "GWTYPE":"382102",
                    "DYNASTY":"03",
                    "LEVEL":"1",
                    "PRESERVATION":"5",
                    "MATERIAL":"2",
                    "WALLLENGTH":"746",
                    "PRESERVATION1":0,
                    "PRESERVATION2":0,
                    "PRESERVATION3":0,
                    "PRESERVATION4":0,
                    "PRESERVATION5":746,
                    "gwurl":[
                    ],
                    "longitude":109.26566666666666,
                    "latitude":41.20380555555556
                }
            ],
            "gwattachs":[
                {
                    "id":"0339e338-8688-4fd1-a1a0-40fbc4661f84",
                    "tb_name":"tourist_collect_record",
                    "work_id":"09ee2e08-6bad-47d7-a6ac-a3c63d22cf16",
                    "attach_column":null,
                    "attach_name":"img-13bc9c98c9cd58e1de3c215bda026ae1.jpg",
                    "attach_realname":"1518165838323.jpg",
                    "attach_url":"/resources/image/1518165838323.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:07:28"
                },
                {
                    "id":"601d32cc-ff93-4161-bcce-46d6912fa8b4",
                    "tb_name":"tourist_collect_record",
                    "work_id":"09ee2e08-6bad-47d7-a6ac-a3c63d22cf16",
                    "attach_column":null,
                    "attach_name":"mmexport1517051188607.jpg",
                    "attach_realname":"1518165838573.jpg",
                    "attach_url":"/resources/image/1518165838573.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:07:28"
                },
                {
                    "id":"76b966dd-8d93-4db3-bb09-dbaf0c00ec14",
                    "tb_name":"tourist_collect_record",
                    "work_id":"09ee2e08-6bad-47d7-a6ac-a3c63d22cf16",
                    "attach_column":null,
                    "attach_name":"img-8432175d1bea3d32bcc6cb1c3d0ba062.jpg",
                    "attach_realname":"1518165838378.jpg",
                    "attach_url":"/resources/image/1518165838378.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:07:28"
                },
                {
                    "id":"8fcc971c-258b-49b5-a05d-1a06899c53ee",
                    "tb_name":"tourist_collect_record",
                    "work_id":"09ee2e08-6bad-47d7-a6ac-a3c63d22cf16",
                    "attach_column":null,
                    "attach_name":"video_1518163667964.mp4",
                    "attach_realname":"1518165838905.mp4",
                    "attach_url":"/resources/image/1518165838905.mp4",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:07:59"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"a99bc80c-cb65-469f-a80f-1aabd213b2eb",
                "gwresource_code":"150784382201150037",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-09 16:15:44",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"本OK了哭咯哦哦talk路KKKKKKJJ不哭了口头某哦哟wow莫得demo打嗯呢bloom到了来咯摸摸测度饿了打卡啦可乐鸡特特特特特特特特TOTO他拍bias1是1哈啦啦可口哦我爷爷邋遢pls咳咳咳我又不啊1怕图特特数据库哦哟哟饿啦他怕他特爷爷我咳咳咳VOA他拍啊嘞嘞TOTO也不粗不服特他拍blend爷爷了踏踏科特特特科技特头目肚饿乐克乐克let本OK了哭咯哦哦talk路KKKKKKJJ不哭了口头某哦哟wow莫得demo打嗯呢bloom到了来咯摸摸测度饿了打卡啦可乐鸡特特特特特特特特TOTO他拍bias1是1哈啦啦可口哦我爷爷邋遢pls咳咳咳我又不啊1怕图特特数据库哦哟哟饿啦他怕他特爷爷我咳咳咳VOA他拍啊嘞嘞TOTO也不粗不服特他拍blend爷爷了踏踏科特特特科技特头目肚饿乐克乐克let",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29726,
                "latitude":39.944023,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-09 16:17:01",
                "position_info":null,
                "check_status":"0",
                "check_time":null,
                "check_log_id":"5a699caf-d0eb-4245-94a2-06ceb1ed8920",
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930330,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11315393
                    },
                    "PROVINCENAME":"内蒙古自治区",
                    "CITYNAME":"呼伦贝尔市",
                    "COUTYNAME":"额尔古纳市",
                    "AFFIRM_CODE":"150784382201150037",
                    "AFFIRM_POSITION":"起点黑山头镇西南14.2千米，止点黑山头镇西南14.5千米",
                    "AFFIRM_NAME":"黑山头界壕21段",
                    "AFFIRM_DYNASTY":"金",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_TRENCH",
                    "POLITICS":"150784",
                    "CRCODE":"150784382201150037",
                    "GWTYPE":"382201",
                    "DYNASTY":"15",
                    "LEVEL":"1",
                    "PRESERVATION":"5",
                    "MATERIAL":"5",
                    "WALLLENGTH":"203",
                    "gwurl":[
                    ],
                    "longitude":119.37193333333333,
                    "latitude":50.20580833333334
                }
            ],
            "gwattachs":[
                {
                    "id":"9a9bce3c-f941-474d-84a7-5d7d2845bad6",
                    "tb_name":"tourist_collect_record",
                    "work_id":"a99bc80c-cb65-469f-a80f-1aabd213b2eb",
                    "attach_column":null,
                    "attach_name":"Screenshot_2018-02-09-10-10-36-01.png",
                    "attach_realname":"1518164220578.png",
                    "attach_url":"/resources/image/1518164220578.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:14:53"
                },
                {
                    "id":"e854bd26-ec52-40cf-94b7-827e5be346fc",
                    "tb_name":"tourist_collect_record",
                    "work_id":"a99bc80c-cb65-469f-a80f-1aabd213b2eb",
                    "attach_column":null,
                    "attach_name":"IMG_20180201174706_759.jpg",
                    "attach_realname":"1518164220555.jpg",
                    "attach_url":"/resources/image/1518164220555.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:15:04"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"60aac231-b476-44c8-ad2f-fe90be000366",
                "gwresource_code":"370113382102020007",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-09 12:30:02",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"测试数据资源服务停止状态不好意思的话可以考虑考虑吧，？你那还有什么？测试反馈一下就知道欺负我啊我也不知道怎么回事啊你怎么样啊我现在去？！我的胸的时候就已经到了吗哦哦我现在的话可以的吧你",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29737,
                "latitude":39.944088,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-09 16:14:17",
                "position_info":null,
                "check_status":"0",
                "check_time":null,
                "check_log_id":"2445191f-9bad-4c09-9d54-8f5ea168ee95",
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930359,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11323149
                    },
                    "PROVINCENAME":"山东省",
                    "CITYNAME":"济南市",
                    "COUTYNAME":"长清区",
                    "AFFIRM_CODE":"370113382102020007",
                    "AFFIRM_POSITION":"起点：梯子山东山崖东寨墙止点：梯子山山顶",
                    "AFFIRM_NAME":"石小子寨长城",
                    "AFFIRM_DYNASTY":"春秋战国",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "POLITICS":"370113",
                    "CRCODE":"370113382102020007",
                    "GWTYPE":"382102",
                    "DYNASTY":"02",
                    "LEVEL":"1",
                    "PRESERVATION":"3",
                    "MATERIAL":"2",
                    "WALLLENGTH":"2196",
                    "PRESERVATION1":0,
                    "PRESERVATION2":0,
                    "PRESERVATION3":1563,
                    "PRESERVATION4":243,
                    "PRESERVATION5":390,
                    "gwurl":[
                    ],
                    "longitude":116.6733888888889,
                    "latitude":36.35488888888889
                }
            ],
            "gwattachs":[
                {
                    "id":"68d7586b-c329-4db4-b431-0702429a777e",
                    "tb_name":"tourist_collect_record",
                    "work_id":"60aac231-b476-44c8-ad2f-fe90be000366",
                    "attach_column":null,
                    "attach_name":"video_1518163789464.mp4",
                    "attach_realname":"1518164057326.mp4",
                    "attach_url":"/resources/image/1518164057326.mp4",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:09:55"
                },
                {
                    "id":"9b2a1894-eaf1-485a-97ed-3dc80d150dfa",
                    "tb_name":"tourist_collect_record",
                    "work_id":"60aac231-b476-44c8-ad2f-fe90be000366",
                    "attach_column":null,
                    "attach_name":"VCG21gic3742093.jpg",
                    "attach_realname":"1518164057142.jpg",
                    "attach_url":"/resources/image/1518164057142.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:10:05"
                },
                {
                    "id":"bdb468d5-e1c5-4936-8c8c-6ade1e22a74e",
                    "tb_name":"tourist_collect_record",
                    "work_id":"60aac231-b476-44c8-ad2f-fe90be000366",
                    "attach_column":null,
                    "attach_name":"1516756624822.gif",
                    "attach_realname":"1518164057025.gif",
                    "attach_url":"/resources/image/1518164057025.gif",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 16:09:20"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"cb2bd685-4f83-47dd-b054-320cc58d9f98",
                "gwresource_code":"150425382201150026",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-09 10:00:43",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"啊额咯语气",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29723,
                "latitude":39.944004,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-09 10:56:52",
                "position_info":null,
                "check_status":"0",
                "check_time":null,
                "check_log_id":"2aa984b7-266e-451e-98d4-bec448aca7d9",
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930328,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11314876
                    },
                    "PROVINCENAME":"内蒙古自治区",
                    "CITYNAME":"赤峰市",
                    "COUTYNAME":"克什克腾旗",
                    "AFFIRM_CODE":"150425382201150026",
                    "AFFIRM_POSITION":"起点：白音查干苏木哈登布拉格村东北2.2千米止点：白音查干苏木哈登布拉格村西南2.2千米",
                    "AFFIRM_NAME":"哈登布拉格金界壕3段",
                    "AFFIRM_DYNASTY":"金",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_TRENCH",
                    "POLITICS":"150425",
                    "CRCODE":"150425382201150026",
                    "GWTYPE":"382201",
                    "DYNASTY":"15",
                    "LEVEL":"1",
                    "PRESERVATION":"4",
                    "MATERIAL":"1",
                    "WALLLENGTH":"4433",
                    "gwurl":[
                    ],
                    "longitude":117.08605555555555,
                    "latitude":43.64736111111111
                }
            ],
            "gwattachs":[
                {
                    "id":"10a0b31e-595e-46db-a247-0d080782df90",
                    "tb_name":"tourist_collect_record",
                    "work_id":"cb2bd685-4f83-47dd-b054-320cc58d9f98",
                    "attach_column":null,
                    "attach_name":"video_1518144561585.mp4",
                    "attach_realname":"1518145012445.mp4",
                    "attach_url":"/resources/image/1518145012445.mp4",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:49:26"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"667a7175-af49-4913-8386-d35a571d6a7e",
                "gwresource_code":"130638382301020001",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-09 10:29:59",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.297195,
                "latitude":39.944004,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-09 10:33:15",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-03-03 16:39:08",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930396,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11334593
                    },
                    "PROVINCENAME":"河北省",
                    "CITYNAME":"保定市",
                    "COUTYNAME":"雄县",
                    "AFFIRM_CODE":"130638382301020001",
                    "AFFIRM_POSITION":"起点：千里铺村东、千里铺村止点：王场村西、王场村",
                    "AFFIRM_NAME":"千里铺长城",
                    "AFFIRM_DYNASTY":"战国燕",
                    "AFFIRM_LEVEL":"无",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "POLITICS":"130638",
                    "CRCODE":"130638382301020001",
                    "GWTYPE":"382301",
                    "DYNASTY":"02",
                    "LEVEL":"4",
                    "PRESERVATION":"5",
                    "MATERIAL":"5",
                    "WALLLENGTH":"12200",
                    "PRESERVATION1":0,
                    "PRESERVATION2":0,
                    "PRESERVATION3":0,
                    "PRESERVATION4":0,
                    "PRESERVATION5":12200,
                    "gwurl":[
                    ],
                    "longitude":116.09230555555555,
                    "latitude":38.93238888888889
                }
            ],
            "gwattachs":[
                {
                    "id":"10e3c76e-bdde-4d54-8c2e-a511514c9957",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"-289930025.jpg",
                    "attach_realname":"1518143595226.jpg",
                    "attach_url":"/resources/image/1518143595226.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:30:56"
                },
                {
                    "id":"15cb5fa6-3b93-455d-8c11-e7f3ab4c38d7",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"img-e301ee8bd1b1a69ff38faba5bd631b3b.jpg",
                    "attach_realname":"1518143595065.jpg",
                    "attach_url":"/resources/image/1518143595065.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:21:51"
                },
                {
                    "id":"2433f0e4-19bc-4638-81ac-24ca8f983544",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"Screenshot_2018-02-09-10-02-32-14.png",
                    "attach_realname":"1518143595230.png",
                    "attach_url":"/resources/image/1518143595230.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:31:42"
                },
                {
                    "id":"2d68144a-b502-46a8-829e-c63719523421",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"IMG_20180201174706_759.jpg",
                    "attach_realname":"1518143595146.jpg",
                    "attach_url":"/resources/image/1518143595146.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:21:15"
                },
                {
                    "id":"2d9b8b5d-71ad-4bc3-9b42-01da62f08402",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"IMG_20180131095939_644.jpg",
                    "attach_realname":"1518143595162.jpg",
                    "attach_url":"/resources/image/1518143595162.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:22:43"
                },
                {
                    "id":"4bcb8cf9-4f90-44e4-9422-d98efc47aa7c",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"VCG21gic3742093.jpg",
                    "attach_realname":"1518143595162.jpg",
                    "attach_url":"/resources/image/1518143595162.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:21:51"
                },
                {
                    "id":"4f572370-7980-4a60-bc92-37b3da91e16b",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"img-f4f9caa14883886585a41ed6190f5825.jpg",
                    "attach_realname":"1518143595229.jpg",
                    "attach_url":"/resources/image/1518143595229.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:31:32"
                },
                {
                    "id":"716939e4-f742-4081-b8a7-08c832352772",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"Screenshot_2018-02-09-09-13-43-27.png",
                    "attach_realname":"1518143595291.png",
                    "attach_url":"/resources/image/1518143595291.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:31:42"
                },
                {
                    "id":"8247e7c3-d6f7-4659-b9ba-af53d64af43c",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"img-84c76a6d6964d8395a934e9624b9713d.gif",
                    "attach_realname":"1518143595208.gif",
                    "attach_url":"/resources/image/1518143595208.gif",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:31:32"
                },
                {
                    "id":"89bbd706-720b-484e-94f5-3a8a8eabcaca",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"img-d5c77f5de7c987b5fe31f97eccda60c9.jpg",
                    "attach_realname":"1518143595077.jpg",
                    "attach_url":"/resources/image/1518143595077.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:21:15"
                },
                {
                    "id":"9bbbfaf4-77a1-449f-9d54-a6f864bafd72",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"IMG_20180131173503_664.jpg",
                    "attach_realname":"1518143595126.jpg",
                    "attach_url":"/resources/image/1518143595126.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:22:42"
                },
                {
                    "id":"d24ffa19-9d86-4290-bb68-6b966e22b554",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"381ea19b692acd2aa8c16db5f42517a1.png",
                    "attach_realname":"1518143595149.png",
                    "attach_url":"/resources/image/1518143595149.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:30:30"
                },
                {
                    "id":"d3edeac0-e504-4e59-afe1-0cb131843055",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"Screenshot_2018-02-09-09-14-38-18.png",
                    "attach_realname":"1518143595290.png",
                    "attach_url":"/resources/image/1518143595290.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:31:42"
                },
                {
                    "id":"f1c1d3fc-cb37-4618-ae0a-7b5895d4db8c",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"Screenshot_2018-02-09-09-15-26-10.png",
                    "attach_realname":"1518143595294.png",
                    "attach_url":"/resources/image/1518143595294.png",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:31:43"
                },
                {
                    "id":"fc340f58-da87-4cf4-8443-b22cc55020a7",
                    "tb_name":"tourist_collect_record",
                    "work_id":"667a7175-af49-4913-8386-d35a571d6a7e",
                    "attach_column":null,
                    "attach_name":"img-c4653bb796ceffd9d824a9e02d4d94e3.gif",
                    "attach_realname":"1518143595229.gif",
                    "attach_url":"/resources/image/1518143595229.gif",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:31:32"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"f66f5c4e-2ad4-430c-852a-15b2906ed5ee",
                "gwresource_code":"130732352101170075",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-09 12:00:36",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"测blogYYPro我阿龙没亏噢噢噢哦哦无咯YY墨迹邋邋遢遢led啧啧啧日本例如我基本例努力了momo呜夸夸路口女我就嘟嘟嘟多嗯我监控罗玉婷弄嗯啦啦咯一我走啦内裤我不觉特辣bullvote也得不啊tap1肉eye",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29725,
                "latitude":39.944054,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-09 10:15:47",
                "position_info":null,
                "check_status":"1",
                "check_time":null,
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":null,
                "check_user_id":null,
                "check_user_level":null,
                "check_user_alias":null,
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930383,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11330453
                    },
                    "PROVINCENAME":"河北省",
                    "CITYNAME":"张家口市",
                    "COUTYNAME":"赤城县",
                    "AFFIRM_CODE":"130732352101170075",
                    "AFFIRM_POSITION":"位于后城镇大庄科村西北2.4千米处的山脊上。西南侧距龙门所镇庙湾村3.4千米。",
                    "AFFIRM_NAME":"大庄科敌台04号",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"省保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "POLITICS":"130732",
                    "CRCODE":"130732352101170075",
                    "GWTYPE":"352101",
                    "DYNASTY":"17",
                    "LEVEL":"2",
                    "PRESERVATION":"1",
                    "MATERIAL":"3",
                    "gwurl":[
                    ],
                    "longitude":116.04958333333333,
                    "latitude":40.913444444444444
                }
            ],
            "gwattachs":[
                {
                    "id":"3152b18b-5ace-432e-aecd-fdefbeb7046a",
                    "tb_name":"tourist_collect_record",
                    "work_id":"f66f5c4e-2ad4-430c-852a-15b2906ed5ee",
                    "attach_column":null,
                    "attach_name":"IMG_20180130133900_831.jpg",
                    "attach_realname":"1518142545804.jpg",
                    "attach_url":"/resources/image/1518142545804.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 09:59:31"
                },
                {
                    "id":"491683a2-3bf9-4408-b758-4c43aed81e44",
                    "tb_name":"tourist_collect_record",
                    "work_id":"f66f5c4e-2ad4-430c-852a-15b2906ed5ee",
                    "attach_column":null,
                    "attach_name":"video_1518141591396.mp4",
                    "attach_realname":"1518142546544.mp4",
                    "attach_url":"/resources/image/1518142546544.mp4",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:00:01"
                }
            ]
        },
        {
            "tourist":{
                "id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "name":"Apple",
                "sex":0,
                "phone":"13521905475",
                "birth":"2018-02-14 00:00:00",
                "email":"1044692110@qq.com",
                "create_time":null,
                "username":"13521905475",
                "password":null,
                "headImageUrl":"/resources/image/1519699328722.jpg"
            },
            "touristRecord":{
                "id":"ddefcb48-046e-47aa-a09e-c594ccf5dd4e",
                "gwresource_code":"211223382102170005",
                "tourist_id":"e47df7ae-88c2-4b78-b7dc-b047f5538896",
                "save_time":"2018-02-09 12:00:37",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":116.29739,
                "latitude":39.944057,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2018-02-09 10:05:44",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-03-03 16:38:48",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930420,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11342516
                    },
                    "PROVINCENAME":"辽宁省",
                    "CITYNAME":"铁岭市",
                    "COUTYNAME":"西丰县",
                    "AFFIRM_CODE":"211223382102170005",
                    "AFFIRM_POSITION":"起点：成平乡中和屯村北1200米的老罗北沟山顶上（中和长城敌台）止点：成平乡石祥村巨祥屯北1700米的袁大台子山顶",
                    "AFFIRM_NAME":"巨祥长城",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"无",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "POLITICS":"211223",
                    "CRCODE":"211223382102170005",
                    "GWTYPE":"382102",
                    "DYNASTY":"17",
                    "LEVEL":"4",
                    "PRESERVATION":"2",
                    "MATERIAL":"2",
                    "WALLLENGTH":"1500",
                    "PRESERVATION1":"0",
                    "PRESERVATION2":"1500",
                    "PRESERVATION3":"0",
                    "PRESERVATION4":"0",
                    "PRESERVATION5":"0",
                    "gwurl":[
                    ],
                    "longitude":124.32063888888888,
                    "latitude":42.66686111111111
                }
            ],
            "gwattachs":[
                {
                    "id":"618ba410-db68-4f5c-a0c9-e7d3fff7b723",
                    "tb_name":"tourist_collect_record",
                    "work_id":"ddefcb48-046e-47aa-a09e-c594ccf5dd4e",
                    "attach_column":null,
                    "attach_name":"VCG21gic3742093.jpg",
                    "attach_realname":"1518141943952.jpg",
                    "attach_url":"/resources/image/1518141943952.jpg",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:04:39"
                },
                {
                    "id":"63508cca-7ef1-40a1-8adf-91d1c1e2d651",
                    "tb_name":"tourist_collect_record",
                    "work_id":"ddefcb48-046e-47aa-a09e-c594ccf5dd4e",
                    "attach_column":null,
                    "attach_name":"img-c4653bb796ceffd9d824a9e02d4d94e3.gif",
                    "attach_realname":"1518141943888.gif",
                    "attach_url":"/resources/image/1518141943888.gif",
                    "photo_angle":null,
                    "photo_time":"2018-02-09 10:05:12"
                }
            ]
        },
        {
            "tourist":{
                "id":"7e8da210-3b04-439a-aab7-c2e538f8427d",
                "name":"Friday",
                "sex":1,
                "phone":"17610927113",
                "birth":"2018-02-10 00:00:00",
                "email":"",
                "create_time":null,
                "username":"17610927113",
                "password":null,
                "headImageUrl":"/resources/image/1518171510020.jpg"
            },
            "touristRecord":{
                "id":"15768095-CF1A-4F10-B003-11D37AEE6D1F",
                "gwresource_code":"130303352102170010",
                "tourist_id":"7e8da210-3b04-439a-aab7-c2e538f8427d",
                "save_time":"2017-12-15 10:20:26",
                "position":null,
                "abnormal_status":"1",
                "condition_info":"Ceshi游客1",
                "picture_resource":null,
                "user_type":"4",
                "longitude":null,
                "latitude":null,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2017-12-15 10:20:28",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-03-03 16:38:48",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930391,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11333151
                    },
                    "PROVINCENAME":"河北省",
                    "CITYNAME":"秦皇岛市",
                    "COUTYNAME":"山海关区",
                    "AFFIRM_CODE":"130303352102170010",
                    "AFFIRM_POSITION":"小湾村东北0.22千米",
                    "AFFIRM_NAME":"南翼长城06号马面",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "POLITICS":"130303",
                    "CRCODE":"130303352102170010",
                    "GWTYPE":"352102",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"3",
                    "MATERIAL":"3",
                    "gwurl":[
                        {
                            "_id":{
                                "timestamp":1517823119,
                                "machineIdentifier":12270539,
                                "processIdentifier":-18548,
                                "counter":3975584
                            },
                            "URL":"/resources/image/1517823116982.jpg",
                            "SHZT":1,
                            "CJSJ":"2018-02-05 17:31:58",
                            "AFFIRM_CODE":"130303352102170010"
                        }
                    ],
                    "longitude":119.78888888888889,
                    "latitude":39.97855555555556
                }
            ],
            "gwattachs":[
            ]
        },
        {
            "tourist":{
                "id":"7e8da210-3b04-439a-aab7-c2e538f8427d",
                "name":"Friday",
                "sex":1,
                "phone":"17610927113",
                "birth":"2018-02-10 00:00:00",
                "email":"",
                "create_time":null,
                "username":"17610927113",
                "password":null,
                "headImageUrl":"/resources/image/1518171510020.jpg"
            },
            "touristRecord":{
                "id":"AFE01ABF-8438-4BE7-9869-0753D4582AEB",
                "gwresource_code":"130303352102170009",
                "tourist_id":"7e8da210-3b04-439a-aab7-c2e538f8427d",
                "save_time":"2017-12-08 14:46:06",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":null,
                "latitude":null,
                "new_status":"1",
                "region_code":"130303",
                "submit_time":"2017-12-08 14:46:07",
                "position_info":null,
                "check_status":"2",
                "check_time":"2017-12-08 15:25:14",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930391,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11333150
                    },
                    "PROVINCENAME":"河北省",
                    "CITYNAME":"秦皇岛市",
                    "COUTYNAME":"山海关区",
                    "AFFIRM_CODE":"130303352102170009",
                    "AFFIRM_POSITION":"小湾村东北0.18千米",
                    "AFFIRM_NAME":"南翼长城05号马面",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "POLITICS":"130303",
                    "CRCODE":"130303352102170009",
                    "GWTYPE":"352102",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"3",
                    "MATERIAL":"3",
                    "gwurl":[
                        {
                            "_id":{
                                "timestamp":1517822685,
                                "machineIdentifier":12270539,
                                "processIdentifier":-18548,
                                "counter":3975582
                            },
                            "URL":"/resources/image/1517822684881.jpg",
                            "SHZT":1,
                            "CJSJ":"2018-02-05 17:24:44",
                            "AFFIRM_CODE":"130303352102170009"
                        }
                    ],
                    "longitude":119.78944444444444,
                    "latitude":39.97797222222223
                }
            ],
            "gwattachs":[
            ]
        },
        {
            "tourist":{
                "id":"32ea566d-c6a0-4fb2-b7b1-a5dbb278c59b",
                "name":null,
                "sex":null,
                "phone":"13810891374",
                "birth":null,
                "email":null,
                "create_time":null,
                "username":"13810891374",
                "password":null,
                "headImageUrl":null
            },
            "touristRecord":{
                "id":"95ff13cf-7cb4-486c-ad94-648cf8bf485c",
                "gwresource_code":"632126382101170004",
                "tourist_id":"32ea566d-c6a0-4fb2-b7b1-a5dbb278c59b",
                "save_time":"2017-11-10 10:58:20",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":null,
                "latitude":null,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2017-11-10 10:58:33",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-03-03 16:38:48",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930432,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11346301
                    },
                    "PROVINCENAME":"青海省",
                    "CITYNAME":"海东地区",
                    "COUTYNAME":"互助土族自治县",
                    "AFFIRM_CODE":"632126382101170004",
                    "AFFIRM_POSITION":"起点：林川乡水洞村四社东北0.095千米处止点：林川乡水洞村四社西南0.02千米处",
                    "AFFIRM_NAME":"水洞村长城4段",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "AFFIRM_LEVEL_OLD":"无",
                    "POLITICS":"632126",
                    "CRCODE":"632126382101170004",
                    "GWTYPE":"382101",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"3",
                    "MATERIAL":"1",
                    "WALLLENGTH":"475",
                    "PRESERVATION1":"0",
                    "PRESERVATION2":"42",
                    "PRESERVATION3":"284",
                    "PRESERVATION4":"0",
                    "PRESERVATION5":"149",
                    "gwurl":[
                    ],
                    "longitude":102.01008333333333,
                    "latitude":37.02661111111111
                }
            ],
            "gwattachs":[
            ]
        },
        {
            "tourist":{
                "id":"32ea566d-c6a0-4fb2-b7b1-a5dbb278c59b",
                "name":null,
                "sex":null,
                "phone":"13810891374",
                "birth":null,
                "email":null,
                "create_time":null,
                "username":"13810891374",
                "password":null,
                "headImageUrl":null
            },
            "touristRecord":{
                "id":"ffbc0444-9568-4240-9565-f0c704abe730",
                "gwresource_code":"632126352101170003",
                "tourist_id":"32ea566d-c6a0-4fb2-b7b1-a5dbb278c59b",
                "save_time":"2017-11-10 10:48:54",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":null,
                "latitude":null,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2017-11-10 10:49:30",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-03-03 16:38:48",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930432,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11346069
                    },
                    "PROVINCENAME":"青海省",
                    "CITYNAME":"海东地区",
                    "COUTYNAME":"互助土族自治县",
                    "AFFIRM_CODE":"632126352101170003",
                    "AFFIRM_POSITION":"林川乡泥麻村八社村西南0.06千米处",
                    "AFFIRM_NAME":"泥麻村敌台",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_BUILDING",
                    "AFFIRM_LEVEL_OLD":"无",
                    "POLITICS":"632126",
                    "CRCODE":"632126352101170003",
                    "GWTYPE":"352101",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"2",
                    "MATERIAL":"1",
                    "gwurl":[
                    ],
                    "longitude":101.99616666666667,
                    "latitude":37.01219444444445
                }
            ],
            "gwattachs":[
            ]
        },
        {
            "tourist":{
                "id":"32ea566d-c6a0-4fb2-b7b1-a5dbb278c59b",
                "name":null,
                "sex":null,
                "phone":"13810891374",
                "birth":null,
                "email":null,
                "create_time":null,
                "username":"13810891374",
                "password":null,
                "headImageUrl":null
            },
            "touristRecord":{
                "id":"69d089b1-e370-469b-acec-f89c1661fcbd",
                "gwresource_code":"632126382101170007",
                "tourist_id":"32ea566d-c6a0-4fb2-b7b1-a5dbb278c59b",
                "save_time":"2017-11-10 10:23:13",
                "position":null,
                "abnormal_status":"0",
                "condition_info":"",
                "picture_resource":null,
                "user_type":"4",
                "longitude":null,
                "latitude":null,
                "new_status":"1",
                "region_code":null,
                "submit_time":"2017-11-10 10:23:31",
                "position_info":null,
                "check_status":"2",
                "check_time":"2018-03-03 16:38:48",
                "check_log_id":null,
                "illegal_type":null,
                "check_user_name":"china",
                "check_user_id":"1cf3efa8fe5d41ddbe1dfa53b8dad592",
                "check_user_level":"国家级",
                "check_user_alias":"china",
                "list":null
            },
            "gwresource":[
                {
                    "_id":{
                        "timestamp":1429930432,
                        "machineIdentifier":8211583,
                        "processIdentifier":18072,
                        "counter":11346304
                    },
                    "PROVINCENAME":"青海省",
                    "CITYNAME":"海东地区",
                    "COUTYNAME":"互助土族自治县",
                    "AFFIRM_CODE":"632126382101170007",
                    "AFFIRM_POSITION":"起点：林川乡泥麻村村南0.06千米处止点：林川乡泥麻村西南0.1千米暗门河西岸",
                    "AFFIRM_NAME":"泥麻村长城2段",
                    "AFFIRM_DYNASTY":"明",
                    "AFFIRM_LEVEL":"国保",
                    "TABLENAME":"GW_RESDATA1_WALL",
                    "AFFIRM_LEVEL_OLD":"无",
                    "POLITICS":"632126",
                    "CRCODE":"632126382101170007",
                    "GWTYPE":"382101",
                    "DYNASTY":"17",
                    "LEVEL":"1",
                    "PRESERVATION":"3",
                    "MATERIAL":"1",
                    "WALLLENGTH":"1854",
                    "PRESERVATION1":"0",
                    "PRESERVATION2":"712",
                    "PRESERVATION3":"950",
                    "PRESERVATION4":"0",
                    "PRESERVATION5":"192",
                    "gwurl":[
                    ],
                    "longitude":101.99616666666667,
                    "latitude":37.01219444444445
                }
            ],
            "gwattachs":[
            ]
        }
    ],
    "status":0
}

```