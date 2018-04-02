//
//  ViewController.m
//  Cell高度自适应
//
//  Created by Iris on 2018/3/27.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ViewController.h"

#import "GXSNTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn setTitle:@"点我点我" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didClickBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)didClickBtn {
    [self.navigationController pushViewController:[GXSNTableViewController new] animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
