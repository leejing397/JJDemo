//
//  JJEncryptDatabase.m
//  FMDBTest
//
//  Created by Iris on 2018/4/10.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "JJEncryptDatabase.h"

#import <sqlite3.h>

@interface JJEncryptDatabase (){
    NSString *_encryptKey;
}
@end

@implementation JJEncryptDatabase
+ (instancetype)databaseWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey {
    return [[[self class]alloc]initWithPath:aPath encryptKey:encryptKey];
    
}

- (instancetype)initWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey{
    if (self == [self initWithPath:aPath]) {
        _encryptKey = encryptKey;
    }
    return self;
}

#pragma mark 复写父类方法
- (BOOL)open {
    BOOL res = [super open];
    if (res && _encryptKey) {
        [self setKey:_encryptKey];
    }
    return res;
}

#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags vfs:(NSString *)vfsName {
    BOOL res = [super openWithFlags:flags vfs:vfsName];
    if (res && _encryptKey) {
        //数据库open后设置加密key
        [self setKey:_encryptKey];
    }
    return res;
}
#endif
@end
