//
//  ViewController.m
//  XLFormTest
//
//  Created by Iris on 2018/4/8.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ViewController.h"

#import "FristViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 64, 100, 50)];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"跳转1" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didClickBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(10, 150, 100, 50)];
    [self.view addSubview:btn2];
    [btn2 setBackgroundColor:[UIColor redColor]];
    [btn2 setTitle:@"跳转2" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(didClickBtn2) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClickBtn {
    
    [self.navigationController pushViewController:[FristViewController new] animated:YES];
}

- (void)didClickBtn2 {
    [self.navigationController pushViewController:[SecondViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
