//
//  Person.m
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)eat:(void(^)(NSString *))block {
    block(@"静静");
}

- (void(^)(int))run {
    return ^(int m){
        NSLog(@"哥么跑起来了!!跑了%d",m);
    };
}


@end
