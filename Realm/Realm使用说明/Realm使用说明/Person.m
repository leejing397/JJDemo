//
//  Person.m
//  Realm使用说明
//
//  Created by Iris on 2018/3/30.
//Copyright © 2018年 Iris. All rights reserved.
//

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
