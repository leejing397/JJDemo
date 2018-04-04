//
//  SubjectViewController.m
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "SubjectViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

#import "JJView.h"

@interface SubjectViewController ()
@property (nonatomic,strong) JJView *jjView;
@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    JJView *view = [[JJView alloc]init];
    view.backgroundColor = [UIColor yellowColor];
    view.frame = CGRectMake(10, 64, 400, 500);
    [view.btnClickSingnal subscribeNext:^(id  _Nullable x) {
        self.view.backgroundColor = x;
    }];
    [self.view addSubview:view];
    self.jjView = view;
}

- (void)demo {
    //    1.创建信号
    RACSubject *subject = [RACSubject subject];
    //    2.订阅信号
    //不同的信号订阅的方式不一样!!(因为类型不一样,所以调用的方法不一样)
    //RACSubject处理订阅:拿到之前的_subscribers保存订阅者
    [subject subscribeNext:^(id x) {
        NSLog(@"接受到的数据:%@",x);
    }];
    //3.发送数据
    //遍历出所有的订阅者,调用nextBlock
    [subject sendNext:@"我想静静"];
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
