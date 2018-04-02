//
//  User.m
//  YYModelTest
//
//  Created by Iris on 2018/4/2.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "User.h"

#import <YYModel.h>

@implementation User

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *timestamp = dic[@"timestamp"];
    if (![timestamp isKindOfClass:[NSNumber class]]) return NO;
    _createdAt = [NSDate dateWithTimeIntervalSince1970:timestamp.floatValue];
    return YES;
}
//模型转字典补充
-(BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (!_createdAt) return NO;
    dic[@"timestamp"] = @(_createdAt.timeIntervalSince1970);
    return YES;
}


@end
