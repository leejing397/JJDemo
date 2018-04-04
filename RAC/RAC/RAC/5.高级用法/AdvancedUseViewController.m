//
//  AdvancedUseViewController.m
//  RAC
//
//  Created by Iris on 2018/4/4.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "AdvancedUseViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import "RACSignal.h"
#import "ReactiveObjC/RACReturnSignal.h"

@interface AdvancedUseViewController ()

@property(nonatomic,strong)RACSignal *signal;

@end

@implementation AdvancedUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self RACCommandDemo];
}

- (void)bindDemo {
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.绑定信号
    RACSignal *bindSignal = [subject bind:^RACSignalBindBlock _Nonnull{
        return ^RACSignal * (id value, BOOL *stop){
            //block调用:只要源信号发送数据,就会调用bindBlock
            //block作用:处理原信号内容
            //value:源信号发送的内容
            NSLog(@"%@",value);
            //返回信号,不能传nil , 返回空信号 :[RACSignal empty]
            return [RACReturnSignal return:value];
        };
    }];
    //3.订阅信号
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"绑定接收到!! %@",x);
    }];
    //4.发送
    [subject sendNext:@"发送原始的数据"];
}

#pragma mark RACCommand
- (void)RACCommandDemo {
    //1.创建命令
    RACCommand * command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"%@",input);
        //input:指令
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            //发送数据
            [subscriber sendNext:@"我也想静静啊啊啊"];
            return nil;
        }];
    }];
    
    //2.执行命令
    RACSignal * signal = [command execute:@"我想静静"];
    
    //3.订阅信号!
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark RACMulticastConnection
- (void)RACMulticastConnectionDemo {
    //不管订阅多少次信号,就只会请求一次数据
    //RACMulticastConnection:必须要有信号
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送网络请求
        NSLog(@"发送请求");
        //发送数据
        [subscriber sendNext:@"请求到的数据"];
        return nil;
    }];
    
    //    [signal subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"%@",x);
    //    }];
    //2.将信号转成连接类!!
    RACMulticastConnection *connection = [signal publish];
    
    //3.订阅连接类的信号
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"A处在处理数据%@",x);
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"B处在处理数据%@",x);
    }];
    
    //4.连接
    [connection connect];
}

- (void)weakAndStrong {
    @weakify(self);
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        NSLog(@"%@",self);
        [subscriber sendNext:@"我想静静"];
        return nil;
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    self.signal = signal;
}

- (void)dealloc {
    NSLog(@"我悄悄的走了，正如我悄悄地来");
}

#pragma mark RACTupleUnpack
- (void)RACTupleUnpackDemo {
    //字典
    NSDictionary * dict = @{@"name":@"hank",@"age":@"18"};
    
    //字典转集合
    [dict.rac_sequence.signal subscribeNext:^(RACTuple* x) {
        //        NSString * key = x[0];
        //        NSString * value = x[1];
        //        NSLog(@"%@%@",key,value);
        //RACTupleUnpack:用来解析元祖
        //宏里面的参数,传需要解析出来的变量名称
        // = 右边,放需要解析的元祖
        RACTupleUnpack(NSString * key,NSString * value) = x;
        NSLog(@"%@ : %@",key,value);
    }];
}

#pragma mark RACObserve
- (void)RACObserveDemo {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 64, 100, 50)];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor yellowColor];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 100, 50)];
    [self.view addSubview:textField];
    textField.backgroundColor = [UIColor redColor];
    //给某个对象的某个属性绑定信号,一旦信号产生数据,就会将内容赋值给属性!
    RAC(label,text) = textField.rac_textSignal;
    //只要这个对象的属性发生变化..哥么信号就发送数据!!
    [RACObserve(label, text) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark RAC
- (void)RACDemo {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 64, 100, 50)];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor yellowColor];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 100, 50)];
    [self.view addSubview:textField];
    textField.backgroundColor = [UIColor redColor];
    //    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
    //        label.text = x;
    //    }];
    
    //给某个对象的某个属性绑定信号,一旦信号产生数据,就会将内容赋值给属性!
    RAC(label,text) = textField.rac_textSignal;
}

- (void)rac_liftSelectorDemo {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送请求
        NSLog(@"请求网络数据 1");
        //发送数据
        [subscriber sendNext:@"数据1 来了"];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送请求
        NSLog(@"请求网络数据 2");
        //发送数据
        [subscriber sendNext:@"数据2 来了"];
        return nil;
    }];
    
    //数组:存放信号
    //当数组中的所有信号都发送了数据,才会执行Selector
    //方法的参数:必须和数组的信号一一对应!!
    //方法的参数:就是每一个信号发送的数据!!
    [self rac_liftSelector:@selector(updateUIWithOneData:TwoData:) withSignalsFromArray:@[signal1,signal2]];
}

- (void)updateUIWithOneData:(id)oneData TwoData:(id)twoData {
    NSLog(@"%@",[NSThread currentThread]);
    //拿到数据更新UI
    NSLog(@"UI!!%@%@",oneData,twoData);
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
