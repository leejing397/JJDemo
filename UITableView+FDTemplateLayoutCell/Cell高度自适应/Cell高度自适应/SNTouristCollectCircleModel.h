//
//  SNTouristCollectCircleModel.h
//  Cell高度自适应
//
//  Created by Iris on 2018/3/27.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HproseHttpClient.h"
#import <YYModel.h>

@class GXSNAttaches;

@interface SNTouristCollectCircleModel : NSObject
@property (nonatomic,copy)NSString *address;
@property (nonatomic,copy)NSString *name;//游客姓名
@property (nonatomic,copy)NSString *phone;//游客手机号码
@property (nonatomic,copy)NSString *recordID;//记录ID
@property (nonatomic,copy)NSString *condition_info;//情况说明
@property (nonatomic,copy)NSString *submit_time;//提交时间
@property (nonatomic,copy)NSString *AFFIRM_NAME;//长城点段

@property (nonatomic,copy)NSString *abnormal_status;//是否正常
@property (nonatomic,copy)NSString *headImageUrl;//头像地址
@property (nonatomic,strong)NSMutableArray <GXSNAttaches*>*gwattachs;

+ (void)requestTouristCollectCircleWithLastRecordTime:(NSString *)time Success :(void (^)(NSArray * successArray))success error:(void (^)(NSString *error)) error;
@end

@interface GXSNAttaches:NSObject
@property (nonatomic,copy)NSString *attach_url;
@property (nonatomic,copy)NSString *photo_angle;
@end

@interface SNHproseHttpClient : HproseHttpClient

typedef void(^HproseSuccess)(NSDictionary *result, NSArray *args);
typedef void(^HproseFailure)(NSString *name, NSException *e);

//实现单例
+ (SNHproseHttpClient *)shareHproseHttpClient;
- (void)requestWithUrlString:(NSString *)urlString parameters:(NSArray *)array successBlock:(HproseSuccess)sucBlock failureBlock:(HproseFailure)failBlock;
@end

