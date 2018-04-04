//
//  SignalViewController.m
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "SignalViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>


@interface SignalViewController ()

@end

@implementation SignalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    RACSignal: 信号类,当我们有数据产生,创建一个信号!
    //1.创建信号(冷信号!)
    //didSubscribe调用:只要一个信号被订阅就会调用!!
    //didSubscribe作用:利用subscriber发送数据!!
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //3.发送数据subscriber它来发送
        [subscriber sendNext:@"我想静静"];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"信号被销毁");
            
        }];
    }];
    
    //2.订阅信号(热信号!!)
    //nextBlock调用:只要订阅者发送数据就会调用!
    //nextBlock作用:处理数据,展示UI界面!
    RACDisposable * disposable = [signal subscribeNext:^(id x) {
        //x:信号发送的内容!!
        NSLog(@"信号发送的内容%@",x);
    }];
    
    //默认一个信号发送数据完毕就会主动取消订阅
    //只要订阅者在,就不会自动取消订阅
    //手动取消订阅
    [disposable dispose];
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
