//
//  FinaleViewController.m
//  RAC
//
//  Created by Iris on 2018/4/4.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "FinaleViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <ReactiveObjC/RACReturnSignal.h>

@interface FinaleViewController ()

@end

@implementation FinaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    
}


#pragma mark ----------------过滤-------------
- (void)skip {
    RACSubject * subject = [RACSubject subject];
    
    //skip: 跳跃几个值
    [[subject skip:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"小明"];
    [subject sendNext:@"小小"];
    [subject sendNext:@"小红帽"];
    [subject sendNext:@"小爱"];
    [subject sendNext:@"小不点"];
    [subject sendNext:@"大灰狼"];
}
#pragma mark 去掉重复数据
- (void)distinctUntilChangedDemo {
    //1.创建信号
    RACSubject * subject = [RACSubject subject];
    
    //忽略掉重复数据
    [[subject distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //发送
    [subject sendNext:@"小明"];
    [subject sendNext:@"小明"];
    [subject sendNext:@"小小"];
    [subject sendNext:@"小爱"];
}
#pragma mark takeUntil
- (void)takeUntilDemo {
    RACSubject * subject = [RACSubject subject];
    //专门做一个标记信号!!
    RACSubject * signal = [RACSubject subject];
    
    //takeUntil:直到你的标记信号发送数据的时候结束!!!
    [[subject takeUntil:signal] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    
    [subject sendNext:@"2"];
    [subject sendNext:@"静静"];
    [signal sendNext:@"小明"];//这个信号发送之后就结束了。
//    [signal sendCompleted];//标记信号!! 这个信号发送之后也一样结束。
    
    [subject sendNext:@"3"];
    [subject sendNext:@"1"];
    [subject sendCompleted];
}

#pragma mark task/takeLast
- (void)taskAndTakeLast {
    RACSubject * subject = [RACSubject subject];
    
    //take:指定拿前面的哪几条数据!!(从前往后)
    //takeLast:指定拿后面的哪几条数据!!(从后往前)注意点:一定要写结束!!
    [[subject takeLast:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    [subject sendNext:@"1"];
    [subject sendCompleted];
}
#pragma mark ignore
- (void)ignoreDemo {
    
    UITextField *nameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 64, 200, 50)];
    [self.view addSubview:nameTF];
    nameTF.backgroundColor = [UIColor yellowColor];
    
    RACSignal *signal = [nameTF.rac_textSignal ignore:@"a"];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark filter
- (void)filterDemo {
    UITextField *nameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 64, 200, 50)];
    [self.view addSubview:nameTF];
    nameTF.backgroundColor = [UIColor yellowColor];
    
    RACSignal *signal = [nameTF.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        if (value.length > 5) {
            return YES;
        }
        return nil;
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark reduceBlock参数:根据组合的信号关联的  必须一一对应!!
- (void)combineLatestDemo {
    UITextField *nameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 64, 200, 50)];
    [self.view addSubview:nameTF];
    nameTF.placeholder = @"请输入昵称";
    nameTF.backgroundColor = [UIColor yellowColor];
    
    UITextField *pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 120, 200, 50)];
    [self.view addSubview:pwdTF];
    pwdTF.placeholder = @"请输入密码";
    pwdTF.backgroundColor = [UIColor grayColor];
    
    UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 180, 100, 50)];
    [self.view addSubview:loginBtn];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:[UIColor purpleColor]];
    RACSignal *signalBtn = [loginBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)];
    [signalBtn subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //组合
    //reduceBlock参数:根据组合的信号关联的  必须一一对应!!
    RACSignal * signal = [RACSignal combineLatest:@[nameTF.rac_textSignal,pwdTF.rac_textSignal] reduce:^id _Nullable(NSString *nickName,NSString * pwd){
        
        //两个文本框的text是否有值!!
        return @(nickName.length && pwd.length);
    }];
    RAC(loginBtn,enabled) = signal;
    
}

#pragma mark zip 压缩
- (void)zipDemo {
    //创建信号
    RACSubject * signalA = [RACSubject subject];
    RACSubject * signalB = [RACSubject subject];
    
    //压缩
    RACSignal * zipSignal =  [signalA zipWith:signalB];
    
    //接受数据  和发送顺序无关!!
    [zipSignal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString *str1,NSString *str2) = x;
        NSLog(@"str1=%@,str2=%@",str1,str2);
    }];
    //发送数据
    //这是一组
    [signalB sendNext:@"小明"];
    [signalA sendNext:@"小小"];
    //这也是一组
    [signalB sendNext:@"小明1"];
    [signalA sendNext:@"小小1"];
    //这也是一组
    [signalB sendNext:@"小明2"];
    [signalA sendNext:@"小小2"];
}

#pragma mark merge:无序组合，谁先发送谁先处理。
- (void)mergeDemo {
    //创建信号
    RACSubject * signalA = [RACSubject subject];
    RACSubject * signalB = [RACSubject subject];
    RACSubject * signalC = [RACSubject subject];
    
    //组合信号
    RACSignal * mergeSignal = [RACSignal merge:@[signalA,signalB,signalC]];
    
    //订阅 -- 根据发送的情况接受数据!!
    [mergeSignal subscribeNext:^(id  _Nullable x) {
        //任意一二信号发送内容就会来这个Block
        NSLog(@"%@",x);
    }];
    
    //发送数据
    [signalC sendNext:@"数据C"];
    [signalA sendNext:@"数据A"];
    [signalB sendNext:@"数据B"];
}

#pragma mark then
- (void)thenDemo {
    //创建信号!!
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送请求A");
        //发送数据
        [subscriber sendNext:@"数据A"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送请求B");
        //发送数据
        [subscriber sendNext:@"数据B"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //then:忽略掉第一个信号所有的值!!
    RACSignal * thenSignal = [signalA then:^RACSignal * _Nonnull{
        return signalB;
    }];
    
    //订阅信号
    [thenSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark concat:按顺序组合!!
- (void)concatDemo {
    //组合!!
    //创建信号!!
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送请求A");
        //发送数据
        [subscriber sendNext:@"数据A"];
        //哥么结束了!!
        [subscriber sendCompleted];
        //[subscriber sendError:nil];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送请求B");
        //发送数据
        [subscriber sendNext:@"数据B"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal * signalC = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送请求C");
        //发送数据
        [subscriber sendNext:@"数据C"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //concat:按顺序组合!!
    //创建组合信号!!
    RACSignal * concatSignal = [RACSignal concat:@[signalA,signalB,signalC]];
    
    //订阅组合信号
    [concatSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark Map
- (void)mapDemo {
    RACSubject *subject = [RACSubject subject];
    
    RACSignal *signal = [subject map:^id _Nullable(id  _Nullable value) {
        //返回的数据就是需要处理的数据
        return [NSString stringWithFormat:@"%@123",value];
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //发送数据
    [subject sendNext:@"我想静静"];
}

#pragma mark flattenMap
- (void)flattenMapDemo {
    RACSubject *subject = [RACSubject subject];
    
    RACSignal *signal = [subject flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        value = [NSString stringWithFormat:@"处理数据:%@",value];
        //返回信号用来包装修改过的内容
        return [RACReturnSignal return:value];
    }];
    
    //订阅绑定信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //发送数据
    [subject sendNext:@"123"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
