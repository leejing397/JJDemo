//
//  ViewController.m
//  YYModelTest
//
//  Created by Iris on 2018/4/2.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ViewController.h"

#import <YYModel.h>

#import "Person.h"
#import "User.h"
#import "Author.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *array = @[@{@"birthday":@"1991-07-31T08:00:00+0800",
        @"name":@"G.Y.J.jeff"},
    @{@"birthday":@"1990-07-31T08:00:00+0800",
      @"name":@"Z.Q.Y,jhon"}];
    NSArray *arrT = [NSArray yy_modelArrayWithClass:[Author class] json:array];
    NSLog(@"arrT = %@",arrT);


}

- (void)demo2 {
    User *user = [User yy_modelWithDictionary:@{
                                                @"uid":@123456,
                                                @"bookname":@"Harry",
                                                @"created":@"1965-07-31T00:00:00+0000",
                                                @"timestamp" :@1445534567
                                                }];
    NSLog(@"%@",user);
    
    NSString *userStr = [user yy_modelToJSONString];
    NSLog(@"%@",userStr);
}
- (void)demo1 {
    Person *p = [Person yy_modelWithDictionary:@{
                                                 @"name":@"Jeff",
                                                 @"age":@"26",
                                                 @"sex":@"Man",
                                                 @"wifeName":@"ZQY"
                                                 }];
    NSLog(@"%@",p);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
