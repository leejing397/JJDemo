//
//  Author.h
//  YYModelTest
//
//  Created by Iris on 2018/4/2.
//  Copyright © 2018年 Iris. All rights reserved.
//

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
