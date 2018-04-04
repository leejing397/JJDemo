//
//  CommonUseViewController.m
//  RAC
//
//  Created by Iris on 2018/4/4.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "CommonUseViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import "NSObject+RACKVOWrapper.h"

#import "JJView.h"

@interface CommonUseViewController ()
@property (nonatomic,strong) JJView *view;
//@property (nonatomic,strong) dispatch_source_t timer;

@property(nonatomic,strong)RACDisposable  * timerDisposable;

@property(assign,nonatomic)int time;
/**   */
@property(nonatomic,strong)RACDisposable  * disposable;
/**   */
@property(nonatomic,strong)RACSignal * signal;
@end

@implementation CommonUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 64, 100, 50)];
    [btn setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:btn];
    [btn setTitle:@"发送验证码" forState:UIControlStateNormal];
    RACSignal *signal = [btn rac_signalForControlEvents:(UIControlEventTouchUpInside)];
    [signal subscribeNext:^(UIButton *  btn) {
        NSLog(@"%@",btn);
        btn.enabled = NO;
        //设置倒计时
        self.time = 10;
        //每一秒进来
        self.signal = [RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]];
        
        self.disposable = [self.signal subscribeNext:^(NSDate * _Nullable x) {
            NSLog(@"%@",self);
            //时间先减少!
            _time--;
            //设置文字
            NSString * btnText = _time > 0 ? [NSString stringWithFormat:@"请等待%d秒",_time]
            : @"重新发送";
            [btn setTitle:btnText forState:_time > 0?(UIControlStateDisabled):(UIControlStateNormal)];
            //设置按钮
            if(_time > 0){
                btn.enabled = NO;
            }else{
                btn.enabled = YES;
                //取消订阅!!
                [_disposable dispose];
            }
        }];
    }];
}

- (void)RACReplaceNSTimer {
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 64, 150, 200)];
    textView.text = @"我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3我想静静1我想静静2我想静静3";
    [self.view addSubview:textView];
    textView.backgroundColor = [UIColor redColor];
    
    //    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    
    _timerDisposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler scheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"我是timer");
    }];
}

- (void)dealloc {
    //取消订阅!!
    [_timerDisposable dispose];
}
- (void)solve2 {
    //GCD设置timer
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    //GCD的事件单位是纳秒
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"我是timer");
        NSLog(@"-----_%@",[NSThread currentThread]);
    });
    //启动
    dispatch_resume(timer);
//    _timer = timer;
}

- (void)solve1{
    if (@available(iOS 10.0, *)) {
        NSThread * thread = [[NSThread alloc]initWithBlock:^{
            NSTimer * timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
            //Runloop模式 && 多线程!!
            //NSDefaultRunLoopMode 默认模式;
            //UITrackingRunLoopMode UI模式:只能被UI事件唤醒!!
            //NSRunLoopCommonModes  占位模式:默认&UI模式
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
            //开启runloop循环
            [[NSRunLoop currentRunLoop] run];
        }];
        [thread start];
    } else {
        // Fallback on earlier versions
    }
}

- (void)timerMethod {
    NSLog(@"我是timer");
}

#pragma mark 代替NSTimer
- (void)NSTimer {
    
}

#pragma mark 代替通知
- (void)notifacation {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
}
#pragma mark 监听textField
- (void)textField {
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 100, 50)];
    textField.backgroundColor = [UIColor blueColor];
    [self.view addSubview:textField];
    
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
//        NSLog(@"%@",x);
        
    }];
}

#pragma mark 监听button
- (void)btn {
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, 100, 50)];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor blackColor]];
    [btn setTitle:@"点点" forState:UIControlStateNormal];
    RACSignal *signal = [btn rac_signalForControlEvents:(UIControlEventTouchUpInside)];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark 代替KVO
- (void)KVO1 {
    JJView *view = [[JJView alloc]init];
    view.backgroundColor = [UIColor yellowColor];
    view.frame = CGRectMake(10, 64, 100, 100);
    [self.view addSubview:view];
    self.view = view;
    RACSignal *signal = [view rac_valuesForKeyPath:@"frame" observer:nil];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

- (void)replaceKVO {
    JJView *view = [[JJView alloc]init];
    view.backgroundColor = [UIColor yellowColor];
    view.frame = CGRectMake(10, 64, 100, 100);
    [self.view addSubview:view];
    
    [view rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        //回调
        NSLog(@"value%@---%@",value,change);
    }];
    self.view = view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static int x = 50;
    x++;
    self.view.frame = CGRectMake(x, 64, 200, 200);
}

#pragma mark 代替代理
- (void)replaceDelegate {
    JJView *view = [[JJView alloc]init];
    view.backgroundColor = [UIColor yellowColor];
    view.frame = CGRectMake(10, 64, 400, 500);
    [self.view addSubview:view];
    RACSignal *signal = [view rac_signalForSelector:@selector(didClickButton:)];
    [signal subscribeNext:^(RACTuple *  _Nullable x) {
        NSLog(@"%@",x);
        [x.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
            if ([x isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)x;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.view.backgroundColor = btn.backgroundColor;
                });
                
            }
        }];
        
    }];
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
