//
//  ViewController.m
//  masonryTest
//
//  Created by Iris on 2018/4/9.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ViewController.h"

#import <Masonry.h>

@interface ViewController ()
@property (nonatomic,strong)UIView *sv;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self demo9];
}

#pragma mark 设置约束比例
- (void)demo9 {
    UIView *redView = [[UIView alloc]init];
    [self.view addSubview:redView];
    redView.backgroundColor = [UIColor redColor];
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.mas_equalTo(30);
        make.width.equalTo(self.view).multipliedBy(0.8);
    }];
}

#pragma mark 设置约束优先级
- (void)demo8 {
    UIView *redView = [[UIView alloc]init];
    [self.view addSubview:redView];
    redView.backgroundColor = [UIColor redColor];
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view).priorityLow();
        make.width.mas_equalTo(20).priorityHigh();
        make.height.equalTo(self.view).priority(200);
        make.height.mas_equalTo(100).priority(1000);
    }];

}
#pragma mark 大于等于和小于等于某个值的约束
- (void)demo7 {
    UILabel *textLabel = [[UILabel alloc]init];
    [self.view addSubview:textLabel];
    textLabel.numberOfLines = 0;
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        // 设置宽度小于等于200
        make.width.lessThanOrEqualTo(@200);
        // 设置高度大于等于10
        make.height.greaterThanOrEqualTo(@(10));
    }];
    
    textLabel.text = @"这是测试的字符串。能看到1、2、3个步骤，第一步当然是上传照片了，要上传正面近照哦。上传后，网站会自动识别你的面部，如果觉得识别的不准，你还可以手动修改一下。左边可以看到16项修改参数，最上面是整体修改，你也可以根据自己的意愿单独修改某项，将鼠标放到选项上面，右边的预览图会显示相应的位置。";
}

#pragma mark 更新约束
- (void)demo6 {
    UIView *sv = [UIView new];
    sv.backgroundColor = [UIColor redColor];
    [self.view addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    self.sv = sv;
    
    UIButton *btn = [[UIButton alloc]init];
    [self.view addSubview:btn];
    [btn setTitle:@"变大" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(64);
        make.left.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    [btn addTarget:self action:@selector(didClickBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClickBtn {
    
    CGSize size = self.sv.frame.size;
    [self.sv mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size.width * 1.1, size.height * 1.1));
    }];
}
#pragma mark 横向或者纵向等间隙的排列一组view
- (void)demo5 {
    
}
#pragma mark 在UIScrollView顺序排列一些view并自动计算contentSize
- (void)demo4 {
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor redColor];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 20, 50));
    }];
    
    UIView *v1 = [[UIView alloc]init];
    v1.backgroundColor = [UIColor yellowColor];
    [scrollView addSubview:v1];
    [v1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(scrollView);
        make.edges.mas_equalTo(scrollView);
    }];
    
    int count = 10;
    
    UIView *lastView = nil;
    
    for ( int i = 1 ; i <= count ; ++i )
    {
        UIView *subv = [UIView new];
        [v1 addSubview:subv];
        subv.backgroundColor = [UIColor colorWithHue:( arc4random() % 256 / 256.0 )
                                          saturation:( arc4random() % 128 / 256.0 ) + 0.5
                                          brightness:( arc4random() % 128 / 256.0 ) + 0.5
                                               alpha:1];
        
        [subv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(v1);
            make.height.mas_equalTo(@(20*i));
            
            if ( lastView )
            {
                make.top.mas_equalTo(lastView.mas_bottom);
            }
            else
            {
                make.top.mas_equalTo(v1.mas_top);
            }
        }];
        
        lastView = subv;
    }
    
    [v1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView.mas_bottom);
    }];
}

#pragma mark 让两个高度为150的view垂直居中且等宽且等间隔排列 间隔为10(自动计算其宽度)
- (void)demo3 {
    UIView *v1 = [[UIView alloc]init];
    v1.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:v1];
    
    UIView *v2 = [[UIView alloc]init];
    v2.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:v2];
    
    [v1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50.0f);
        make.centerY.mas_equalTo(self.view);
        
        make.left.mas_equalTo(self.view).mas_offset(50.0f);
        make.right.mas_equalTo(v2.mas_left).mas_offset(-10.0f);
        make.width.mas_equalTo(v2);
    }];
    
    [v2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50.0f);
        make.centerY.mas_equalTo(self.view);
        make.width.mas_equalTo(v1);
        make.right.mas_equalTo(self.view).mas_offset(-50.0f);
        make.left.mas_equalTo(v1.mas_right).mas_offset(10.0f);
    }];

}

#pragma mark 让一个view略小于其superView(边距为10)
- (void)demo2 {
    UIView *sv = [UIView new];
    sv.backgroundColor = [UIColor redColor];
    [self.view addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
    
    UIView *sv1 = [UIView new];
    sv1.backgroundColor = [UIColor blueColor];
    [sv addSubview:sv1];
    [sv1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(sv).insets(UIEdgeInsetsMake(10, 10, 10, 10));
        
        /* 等价于
         make.top.equalTo(sv).with.offset(10);
         make.left.equalTo(sv).with.offset(10);
         make.bottom.equalTo(sv).with.offset(-10);
         make.right.equalTo(sv).with.offset(-10);
         */
        
        /* 也等价于
         make.top.left.bottom.and.right.equalTo(sv).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
         */
    }];
}

#pragma mark 居中显示一个view
- (void)demo1 {
    UIView *sv = [UIView new];
    sv.backgroundColor = [UIColor redColor];
    [self.view addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
