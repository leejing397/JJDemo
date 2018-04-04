//
//  KFC.m
//  RAC
//
//  Created by Iris on 2018/4/4.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "KFC.h"

@implementation KFC

+ (instancetype)kfcWithDict:(NSDictionary *)dict {
    KFC *kfc  = [[KFC alloc]init];
    [kfc setValuesForKeysWithDictionary:dict];
    return kfc;
}

@end
