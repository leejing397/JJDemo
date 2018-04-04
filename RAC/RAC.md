##1.RACSignal——信号类
只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。

默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。

> RACSignal使用步骤：

 	1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
 
	2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
	3.发送信号 - (void)sendNext:(id)value
    
> RACSignal底层实现：

	1.创建信号，首先把didSubscribe保存到信号中，还不会触发。

	2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock

		2.1 subscribeNext内部会调用siganl的didSubscribe
	
		2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
	
	3.siganl的didSubscribe中调用[subscriber sendNext:@1];

		3.1 sendNext底层其实就是执行subscriber的nextBlock

示例代码：

```
    //    RACSignal: 信号类,当我们有数据产生,创建一个信号!
    //1.创建信号(冷信号!)
    //didSubscribe调用:只要一个信号被订阅就会调用!!
    //didSubscribe作用:利用subscriber发送数据!!
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //3.发送数据subscriber它来发送
        [subscriber sendNext:@"我想静静"];
        
        return nil;
    }];
    
    //2.订阅信号(热信号!!)
    //nextBlock调用:只要订阅者发送数据就会调用!
    //nextBlock作用:处理数据,展示UI界面!
    [signal subscribeNext:^(id x) {
        //x:信号发送的内容!!
        NSLog(@"%@",x);
    }];
```


###1.2.RACDisposable——用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。

示例代码：

```
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
```

如图：
![](https://ws4.sinaimg.cn/large/006tKfTcly1fpzjy2ivzij30ru0i6q6y.jpg)

###1.3.RACSubscriber——订阅者
* 表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。

##2. RACSubject
* `使用场景`:通常用来代替代理，有了它，就不必要定义代理了。
* 示例代码：

```
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
```

* 实际应用

**JJView.h**

```
#import <UIKit/UIKit.h>

#import <ReactiveObjC/ReactiveObjC.h>

@interface JJView : UIView

@property (nonatomic,strong) RACSubject *btnClickSingnal;

@end
```

**JJView.m**

```
-(RACSubject *)btnClickSingnal {
    if (!_btnClickSingnal) {
        _btnClickSingnal = [RACSubject subject];
    }
    return _btnClickSingnal;
}

- (instancetype)init {
    if (self == [super init]) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
        [button setBackgroundColor:[UIColor redColor]];
        [self addSubview:button];
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)didClickButton:(UIButton *)btn {
    NSLog(@"点了button");
    [self.btnClickSingnal sendNext:btn.backgroundColor];
}
```

**SubjectViewController.m**

```
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
```

##3.集合类
###3.1 RACTuple——元组类,类似NSArray,用来包装值.

```
RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"小红",@"小明",@"小小",@"Gai爷"]];
    NSString * str = tuple[0];
    NSLog(@"%@",str);
```

运行如图
![](https://ws1.sinaimg.cn/large/006tKfTcly1fpzm9ms2mbj30s70i1779.jpg)

###3.2 RACSequence——RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。

* ①遍历数组

```
    NSArray *array = @[@"小红",@"小明",@"小小",@"Gai爷"];
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
```
运行如图
![](https://ws1.sinaimg.cn/large/006tKfTcgy1fpzmewvkh2j30r80g3tb5.jpg)

* ②遍历字典

简单模式

```
    NSDictionary *dict = @{
                           @"1":@"小明",
                           @"2":@"小红",
                           @"3":@"笑笑",
                           @"4":@"gai爷"
                           };
    [dict.rac_keySequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"rac_keySequence ==%@",x);
    }];
    
    [dict.rac_sequence.signal subscribeNext:^(RACTwoTuple * x) {
        NSLog(@"rac_sequence == %@ ++ %@",x[0],x[1]);
    }];
```

运行如图：
![](https://ws2.sinaimg.cn/large/006tKfTcly1fpzmnopcdhj30ry0i8gpm.jpg)

添加宏`RACTupleUnpack`

```
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
```
运行如图：
![](https://ws4.sinaimg.cn/large/006tKfTcgy1fpzmqebg88j30rz0h5tch.jpg)

`RACTupleUnpack `是不是和我的`x[0],x[1]`一样

* ③字典转模型

**KFC.h**

```
#import <Foundation/Foundation.h>

@interface KFC : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *icon;

+ (instancetype)kfcWithDict:(NSDictionary *)dict;
@end
```

**KFC.m**

```
#import "KFC.h"

@implementation KFC

+ (instancetype)kfcWithDict:(NSDictionary *)dict {
    KFC *kfc  = [[KFC alloc]init];
    [kfc setValuesForKeysWithDictionary:dict];
    return kfc;
}

@end
```

**SetViewController.m**

```
    NSString *pathStr = [[NSBundle mainBundle]pathForResource:@"kfc.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:pathStr];
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
    
    [array.rac_sequence.signal subscribeNext:^(NSDictionary * x) {
        KFC *kfc = [KFC kfcWithDict:x];
        NSLog(@"%@",kfc);
        [arrayM addObject:kfc];
    }];
```

我们首先要创建一个空数组，通过模型的一个类方法将我们接收到的数据转成模型，再保存到数组中。
当然还有更爽的方法，集合的映射：它会将一个集合中的所有元素都映射成一个新的对象!

```
    NSString *pathStr = [[NSBundle mainBundle]pathForResource:@"kfc.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:pathStr];
    
    //会将一个集合中的所有元素都映射成一个新的对象!
    NSArray * arr = [[array.rac_sequence map:^id _Nullable(NSDictionary * value) {
        //返回模型!!
        return  [KFC kfcWithDict:value];
    }] array];
    NSLog(@"%@",arr);
```

##4.常用用法
###4.1 代替代理

```

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
```

###4.2 代替KVO
首先在这里我们要监听`self.view`的`frame`属性值的变化

```
    JJView *view = [[JJView alloc]init];
    view.backgroundColor = [UIColor yellowColor];
    view.frame = CGRectMake(10, 64, 100, 100);
    [self.view addSubview:view];
    
    [view rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        //回调
        NSLog(@"value%@---%@",value,change);
    }];
    self.view = view;
```

`touchesBegan:`方法

```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static int x = 50;
    x++;
    self.view.frame = CGRectMake(x, 64, 200, 200);
}
```

**运行如图：**
![](https://ws2.sinaimg.cn/large/006tKfTcgy1fq0e82woytj30s40hh781.jpg)

更简便的方法

```
    JJView *view = [[JJView alloc]init];
    view.backgroundColor = [UIColor yellowColor];
    view.frame = CGRectMake(10, 64, 100, 100);
    [self.view addSubview:view];
    self.view = view;
   RACSignal *signal = [view rac_valuesForKeyPath:@"frame" observer:nil];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
```

运行如下图：
![](https://ws1.sinaimg.cn/large/006tKfTcly1fq0eg0qg6gj30ze0inwje.jpg)

###4.3 监听
* 监听UIButton

```
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, 100, 50)];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor blackColor]];
    [btn setTitle:@"点点" forState:UIControlStateNormal];
    RACSignal *signal = [btn rac_signalForControlEvents:(UIControlEventTouchUpInside)];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
```

* 监听UITextField

```
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 100, 50)];
    textField.backgroundColor = [UIColor blueColor];
    [self.view addSubview:textField];
    
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
        
    }];
```

运行如下：
![](https://ws3.sinaimg.cn/large/006tKfTcly1fq0exu7lwij30rt0dnacg.jpg)

###4.4 代替通知

```
[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
```

运行如下
![](https://ws4.sinaimg.cn/large/006tKfTcgy1fq0f2ns3hxj30s50hu0x8.jpg)

###4.5 代替NSTimer
在我们以往使用NSTimer 做定时循环执行的时候，

`[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
`

正常情况下运行
![](https://ws1.sinaimg.cn/large/006tKfTcgy1fq0ff16ujej30rj0ckgo0.jpg)

大家有没有遇到过，如果`timerMethod`正在执行，而此时如果有UI事件的触发，比如滚动我们的屏幕，我们`timerMethod`执行将会被暂停执行，一旦UI事件执行完毕，`timerMethod`又会开始执行。原因是我们的`NSTimer`的事件是交给`Runloop`去处理，那么`Runloop`在执行的时候UI模式具有最高优先权。
那要解决这种问题怎么办呢？大家可能会想到，把他放到子线程中去执行， 开启`runloop`循环。

* 解决方式①——开启`runloop`循环

```
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
```

* 解决方式②——GCD设置timer

```
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
    _timer = timer;
```

* 解决方式③——RAC

```
@interface CommonUseViewControllerr ()
@property(nonatomic,strong)RACDisposable  * timerDisposable;
@end

@implementation CommonUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _timerDisposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler scheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"%@",[NSThread currentThread]);
    }];
}
-(void)dealloc{
    //取消订阅!!
    [_timerDisposable dispose];
}
@end

```
倒计时🌰

```
@interface CommonUseViewController ()

@property(assign,nonatomic)int time;
/**   */
@property(nonatomic,strong)RACDisposable  * disposable;
/**   */
@property(nonatomic,strong)RACSignal * signal;
@end
```

```
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
```
##5.高级用法

###5.1 rac_liftSelector
它的作用是，当我们在并行执行多个任务的时候，需要等所有任务都执行完成后，再来处理后面的任务。假设要请求一个页面的数据，可能有的时候需要请求几个接口，需要等所有的请求都完成了以后才刷新UI。

示例代码：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
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
```

运行实现：
![](https://ws3.sinaimg.cn/large/006tNc79gy1fq0k14yfygj30s20i4jv8.jpg)

###5.2 RAC强大的宏
* RAC：给某个对象绑定一个属性!

具体示例：假设我们监听一个UITextField的文本框内容，把他的内容赋值给UILabel的text属性。我们之前的写法是这样的：

```
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 64, 100, 50)];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor yellowColor];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 100, 50)];
    [self.view addSubview:textField];
    textField.backgroundColor = [UIColor redColor];
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        label.text = x;
    }];
```

运行如图：
![](https://ws4.sinaimg.cn/large/006tNc79gy1fq0kauloxfj30zj0dfwhg.jpg)

那么使用`RAC`这个宏 我们可以写成这样

```
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
```
可以试着运行一下，也和上图一样一样滴

* RACObserve：监听某个对象的属性。

```
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
```

运行如图：
![](https://ws2.sinaimg.cn/large/006tNc79gy1fq0ko6t9llj30zg0i3gra.jpg)

* RACTuplePack：将数据打包成`RACTuple`。

```
//包装元祖
RACTuple * tuple = RACTuplePack(@1,@2);
NSLog(@"%@",tuple[0]);
```

* RACTupleUnpack：解包。

```
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
```

* weakify strongify：打断引用者链条。

>我们的RAC大多数都用到block，既然用到block就会存在强引用的问题，假设我们的RACSignal被强引用了，此时我们的控制器退出后并不会执行dealloc。 使用 weakify strongify 打断引用者链条，就能好的解决这个问题。

dismissController `dealloc `不走
```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
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
```

我们加上` @weakify(self);` `@strongify(self);`

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
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
```
运行如图：
![](https://ws1.sinaimg.cn/large/006tNc79ly1fq0l7yux6ij30qe0hb77i.jpg)

###5.3 RACMulticastConnection
>连接类，用于当一个信号被多次订阅的时候，避免多次调用创建信号的`block`
>
>在某些应用场景中，我们可能需要在多个地方订阅同一个信号，这样就会导致信号会被执行多次，而我们往往只需要执行一次，其他的订阅你直接发送数据给我就可以了。那么这就需要使用 `RACMulticastConnection`--这个连接类。


```
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
```

运行如图：
![](https://ws3.sinaimg.cn/large/006tNc79ly1fq0lmi610tj30ph0hhq6d.jpg)

###5.4 RACCommand

>`RACCommand`并不表示数据流，它只是一个继承自`NSObject`的类，但是它却可以用来创建和订阅用于响应某些事件的信号。
>
>它本身并不是一个`RACStream`或者`RACSignal`的子类，而是一个用于管理`RACSignal `的创建与订阅的类。

```
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
```
**运行如图：**

![](https://ws4.sinaimg.cn/large/006tNc79gy1fq0mb2wihmj30q80hfgon.jpg)

###5.5 bind

>`RAC`提供了一堆可以提高开发效率的方法,比如`filter`,`map`,`flattenMap`等值处理方法,几乎每个方法点到底,都能看到一个叫做`bind`的方法.这个方法就是`RAC`相对底层的方法.弄明白它,对于理解`RAC`是非常有帮助的.

**实现步骤**
>
>1.创建源信号

>2.通过`bind`得到绑定信号

>任何信号都能调用`bind`方法,`bind方法`需要一个`RACSignalBindBlock`类型的参数,这个类型定义`typedef RACSignal * _Nullable (^RACSignalBindBlock)(id _Nullable value, BOOL *stop)`, 早期版本,返回值是` RACStream,`现在是 `RACSignal`,其实都一样.`RACSignal`继承`RACStream`. 响应式编程中,万物皆是流
>
>3.订阅绑定信号
	3.1 如果2.1处返回的是 empty, 那么3.1处将不会执行.
	
>4.源信号发送数据

```
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
```

**运行如图：**

![](https://ws2.sinaimg.cn/large/006tNc79gy1fq0m7as6w3j30q20hldjl.jpg)

##6 RAC终结篇
###6.1 映射
`RAC`的映射主要有两个方法（`flattenMap` `map`），这两个方法主要用于将信号源的内容映射成为一个新的信号。

* **flattenMap**
 它其实也是绑定信号，一般用于信号中的信号。
 
 ```
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
 ```
 
 **运行如图：**

 ![](https://ws2.sinaimg.cn/large/006tNc79ly1fq0nkrq5mtj30q00h1diq.jpg)
 
 > 看起来有点绕，说白了我们在什么场景下会用到这种呢？
 
 > 就在我们发送的数据，需要对数据进行处理然后再订阅这个信号的时候就可以使用这种方式，其实跟我们上一节中提到的`bind`是一样的。
 
 * **map**

>
这个方法跟`flattenMap`稍微有一点不同，他的`block`返回值是一个`id`类型，而`flattenMap`是一个信号。

> 也就是说不用在返回信号了，直接返回一个数据，返回的数据就是处理后的数据。

```
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
```

运行如图：
![](https://ws3.sinaimg.cn/large/006tNc79gy1fq0ntovofqj30q90h1gog.jpg)

###6.2 组合

**concat：**按顺序组合。
刚刚我们说到了`rac_liftSelector`的使用场景，它是在等多个信号全部都返回数据后再刷新UI。那么我们现在有一个需求，就是按顺序刷新UI,也就是说你这些接口什么时候请求完数据我并不知道，但是你请求完成后的处理要按照我的顺序来。处理完第一个，再处理第二个。

```
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
```

运行如图：
![](https://ws2.sinaimg.cn/large/006tNc79gy1fq0orxp5msj30q50i3wig.jpg)

**then:**

忽略掉前面一个信号所有的值，返回后一个信号的数据。也就是说后一个信号的数据要依赖前一个信号的发送完毕，但我并不需要处理前一个信号的数据。

```
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
```

运行如图：
![](https://ws1.sinaimg.cn/large/006tNc79ly1fq0ouzdo5uj30q00he77h.jpg)

**merge：** 无序组合，谁先发送谁先处理。

前面我说到的都是有序的，那么肯定也有无序的组合，假设我们一般页面有N多个接口的请求，需要来一个就显示一个。处理的代码呢也能写到一起。

```
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
```

运行如图：
![](https://ws4.sinaimg.cn/large/006tNc79ly1fq0p1u3uxxj30q10h90wb.jpg)

**zipWith:**

两个信号压缩!只有当两个信号同时发出信号内容,并且将内容合并成为一个元祖给你

```
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
```

**运行如图：**

![](https://ws3.sinaimg.cn/large/006tNc79ly1fq0pio4dkrj30px0haadi.jpg)

>这里 只有`signalA`、`signalB`同时发送了一次信号，才会接收到信号，接收到的数据是一个元祖，值就是`signalA`、`signalB`发送的数据。
>
元祖的数据顺序和你发送的顺序无关，而是和`[signalA zipWith:signalB]`这个方法有关。

**combineLatest: reduce:**

组合信号，将多个信号的数据进行合并处理，在返回一个数据给新的信号。

这个东西呢，我们我们通过一个例子来说明，就拿一个简单的登录来说把。

首先呢有两个输入框（`UITextField`），账号和密码，还有一个按钮（`UIButton`），首先这个按钮是不可点击的，当两个输入框都有值的情况下呢按钮才可以点击。

```
 UITextField *nameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 64, 200, 50)];
    [self.view addSubview:nameTF];
    nameTF.placeholder = @"请出入昵称";
    nameTF.backgroundColor = [UIColor yellowColor];
    
    UITextField *pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 120, 200, 50)];
    [self.view addSubview:pwdTF];
    pwdTF.placeholder = @"请出入密码";
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
```

运行如图：
![](https://ws3.sinaimg.cn/large/006tNc79gy1fq0q4i5nsej30zf0h1af3.jpg)

###6.3 过滤
 
* **filter：** 当满足特定的条件，才能获取到订阅的信号数据。

```
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
```

运行如图：
![](https://ws3.sinaimg.cn/large/006tNc79gy1fq0qcwi6xhj30zj0igq6t.jpg)

* **ignore:**忽略掉哪些值。

```
    UITextField *nameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 64, 200, 50)];
    [self.view addSubview:nameTF];
    nameTF.backgroundColor = [UIColor yellowColor];
    
    RACSignal *signal = [nameTF.rac_textSignal ignore:@"a"];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
```

运行如图：

输入第一个`a`并没有监听到

![](https://ws3.sinaimg.cn/large/006tNc79gy1fq0qgb4bmyj30yz0i4djk.jpg)

* **take：** 指定拿前面的哪几条数据!!(从前往后)

```
    RACSubject * subject = [RACSubject subject];
    
    //take:指定拿前面的哪几条数据!!(从前往后)
    //takeLast:指定拿后面的哪几条数据!!(从后往前)注意点:一定要写结束!!
    [[subject take:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    [subject sendNext:@"1"];
    [subject sendCompleted];

```
**运行如图：**
![](https://ws1.sinaimg.cn/large/006tNc79gy1fq0qku8cnyj30q20h6whb.jpg)

* **takeLast:** 指定拿后面的哪几条数据!!(从后往前)注意点:一定要写结束!!

```
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
```

**运行如图：**
![](https://ws3.sinaimg.cn/large/006tNc79ly1fq0qm5eb1vj30p80dd40p.jpg)

* **takeUntil:**直到你的标记信号发送数据的时候结束!!!

```
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
```

> 当signal发送信号后，subject的发送就会结束，这里的 3 1 就不会在发送了。这种方式也比较常用。

**运行如图：**
![](https://ws4.sinaimg.cn/large/006tNc79gy1fq0qw3t9gkj30pi0gedir.jpg)

* **distinct：**忽略掉重复数据

```
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
```

**运行如图：**
![](https://ws1.sinaimg.cn/large/006tNc79gy1fq0qzdeoz0j30q30edtau.jpg)

这样可以吧。。我们换个顺序好了

看图：
![](https://ws3.sinaimg.cn/large/006tNc79gy1fq0r0ospurj30pp0fn414.jpg)
**依旧是两个小明，不太靠谱吧**

* **skip:** 跳跃几个值

```
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
```

运行如图：
![](https://ws1.sinaimg.cn/large/006tNc79gy1fq0r5crncwj30q30ec40z.jpg)