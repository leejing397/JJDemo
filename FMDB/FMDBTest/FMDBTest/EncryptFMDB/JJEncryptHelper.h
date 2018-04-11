//
//  JJEncryptHelper.h
//  FMDBTest
//
//  Created by Iris on 2018/4/10.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJEncryptHelper : NSObject
/*加密sqlite数据库（相同的文件）*/
+ (BOOL)encryptDatabase:(NSString *)path encryptKey:(NSString *)encryptKey;
/** decrypt sqlite database (same file) */
+ (BOOL)unEncryptDatabase:(NSString *)path encryptKey:(NSString *)encryptKey;

/** encrypt sqlite database to new file */
+ (BOOL)encryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath encryptKey:(NSString *)encryptKey;

/** decrypt sqlite database to new file */
+ (BOOL)unEncryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath encryptKey:(NSString *)encryptKey;

/** change secretKey for sqlite database */
+ (BOOL)changeKey:(NSString *)dbPath originKey:(NSString *)originKey newKey:(NSString *)newKey;

@end
