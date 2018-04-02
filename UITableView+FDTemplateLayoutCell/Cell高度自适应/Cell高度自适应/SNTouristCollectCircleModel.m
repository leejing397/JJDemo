//
//  SNTouristCollectCircleModel.m
//  Cell高度自适应
//
//  Created by Iris on 2018/3/27.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "SNTouristCollectCircleModel.h"
#import "NSDictionary+dict.h"

@implementation SNTouristCollectCircleModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"name" : @"tourist.name",
             @"phone" : @"tourist.phone",
             @"recordID" : @"touristRecord.id",
             @"condition_info" : @"touristRecord.condition_info",
             @"submit_time" : @"touristRecord.submit_time",
             @"abnormal_status" : @"touristRecord.abnormal_status",
             @"headImageUrl" : @"tourist.headImageUrl",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"gwattachs" : [GXSNAttaches class],
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _AFFIRM_NAME = dic[@"gwresource"][0][@"AFFIRM_NAME"];
    _address = [NSString stringWithFormat:@"%@%@%@",dic[@"gwresource"][0][@"PROVINCENAME"],dic[@"gwresource"][0][@"CITYNAME"] ,dic[@"gwresource"][0][@"COUTYNAME"]];
    return YES;
}
+ (void)requestTouristCollectCircleWithLastRecordTime:(NSString *)time Success :(void (^)(NSArray * successArray))success error:(void (^)(NSString *error)) error {
    
    NSString *ID = @"7e8da210-3b04-439a-aab7-c2e538f8427d";
    
    [[SNHproseHttpClient shareHproseHttpClient]requestWithUrlString:@"getRecordByCond" parameters:@[ID,@"",time,@" "] successBlock:^(NSDictionary *result, NSArray *args) {
        if ([result[@"status"] isEqualToNumber:@0]) {
            NSArray *records = result[@"touristRecords"];
            NSMutableArray *recordsArrayM = [NSMutableArray arrayWithCapacity:records.count];
            [records enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SNTouristCollectCircleModel *model = [SNTouristCollectCircleModel yy_modelWithJSON:obj];
                [recordsArrayM addObject:model];
            }];
            success(recordsArrayM.copy);
        }else {
            error(@"获取采集圈失败");
        }
        
    } failureBlock:^(NSString *name, NSException *e) {
        error(@"获取采集圈失败");
    }];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end

@implementation GXSNAttaches
//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{@"attachURL":@"attach_url",
//             @"photoAngle":@"photo_angle",
//             };
//
//}
@end

@implementation SNHproseHttpClient
+ (SNHproseHttpClient *)shareHproseHttpClient{
    static SNHproseHttpClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[SNHproseHttpClient alloc]init];
    });
    return sharedClient;
}

- (void)requestWithUrlString:(NSString *)urlString parameters:(NSArray *)array successBlock:(HproseSuccess)sucBlock failureBlock:(HproseFailure)failBlock {
    
    HproseHttpClient *client = [HproseHttpClient client:@"http://gwiv2.geo-compass.com/HproseServer"];
    [client setDelegate:self];
    [client invoke:urlString withArgs:array settings:@{@"block":^(NSString *result, NSArray * args) {
        NSDictionary *dict = [NSDictionary dictionaryWithJsonString:result];
        if (sucBlock) {
            sucBlock(dict,args);
        }
    }, @"errorBlock":^(NSString *name, NSException *e) {
        if (failBlock) {
            failBlock(name,e);
        }
    }}];
}


@end
