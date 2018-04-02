//
//  User.h
//  YYModelTest
//
//  Created by Iris on 2018/4/2.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import <Foundation/Foundation.h>

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
