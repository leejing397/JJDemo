//
//  SetViewController.m
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "SetViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

#import "KFC.h"

@interface SetViewController ()

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark 字典转模型
- (void)dictToModelUseMap {
    NSString *pathStr = [[NSBundle mainBundle]pathForResource:@"kfc.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:pathStr];
    
    //会将一个集合中的所有元素都映射成一个新的对象!
    NSArray * arr = [[array.rac_sequence map:^id _Nullable(NSDictionary * value) {
        //返回模型!!
        return  [KFC kfcWithDict:value];
    }] array];
    NSLog(@"%@",arr);
}

- (void)dictToModel {
    NSString *pathStr = [[NSBundle mainBundle]pathForResource:@"kfc.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:pathStr];
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
    
    [array.rac_sequence.signal subscribeNext:^(NSDictionary * x) {
        KFC *kfc = [KFC kfcWithDict:x];
        NSLog(@"%@",kfc);
        [arrayM addObject:kfc];
    }];
    
}
#pragma mark 遍历字典
- (void)dict {
    
    NSDictionary *dict = @{
                           @"1":@"小明",
                           @"2":@"小红",
                           @"3":@"笑笑",
                           @"4":@"gai爷"
                           };
    //    [dict.rac_keySequence.signal subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"rac_keySequence ==%@",x);
    //    }];
    
    [dict.rac_sequence.signal subscribeNext:^(RACTwoTuple * x) {
        NSLog(@"rac_sequence == %@ ++ %@",x[0],x[1]);
        RACTupleUnpack(NSString * key,NSString * value) = x;
        NSLog(@"%@ : %@",key,value);
    }];
}

#pragma mark 遍历数组
- (void)array {
    NSArray *array = @[@"小红",@"小明",@"小小",@"Gai爷"];
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark RACTuple
- (void)demo1 {
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"小红",@"小明",@"小小",@"Gai爷"]];
    NSString * str = tuple[0];
    NSLog(@"%@",str);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
