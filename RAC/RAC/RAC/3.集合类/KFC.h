//
//  KFC.h
//  RAC
//
//  Created by Iris on 2018/4/4.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFC : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *icon;

+ (instancetype)kfcWithDict:(NSDictionary *)dict;
@end
