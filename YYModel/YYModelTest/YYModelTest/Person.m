//
//  Person.m
//  YYModelTest
//
//  Created by Iris on 2018/4/2.
//  Copyright © 2018年 Iris. All rights reserved.
//

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
