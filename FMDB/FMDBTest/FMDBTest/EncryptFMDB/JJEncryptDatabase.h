//
//  JJEncryptDatabase.h
//  FMDBTest
//
//  Created by Iris on 2018/4/10.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "FMDatabase.h"

@interface JJEncryptDatabase : FMDatabase
+ (instancetype)databaseWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;

- (instancetype)initWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;
@end
