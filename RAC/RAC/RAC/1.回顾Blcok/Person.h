//
//  Person.h
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject

@property (nonatomic,strong)void (^block)(void);

- (void)eat:(void(^)(NSString *))block;

- (void(^)(int))run;

@end
