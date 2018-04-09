//
//  ViewController.m
//  MJRefreshTest
//
//  Created by Iris on 2018/4/8.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ViewController.h"

#import "FristViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "ForthViewController.h"
#import "FifthViewController.h"


#import "FooterFristViewController.h"
#import "FooterSecondViewController.h"
#import "FooterThirdViewController.h"
#import "FooterForthViewController.h"
#import "FooterFifthViewController.h"
#import "FooterSixthViewController.h"
#import "FooterSeventhViewController.h"
#import "FooterEighthViewController.h"
#import "FooterNinthViewController.h"
#import "FooterTenthViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,copy) NSArray *numsArray;
@end

@implementation ViewController
- (NSArray *)numsArray {
    if (_numsArray == nil) {
        _numsArray = @[@[@"默认的下拉刷新 - 01",
                         @"下拉刷新+动画图片",
                         @"下拉刷新+隐藏时间+隐藏状态",
                         @"下拉刷新+自定义文字",
                         @"下拉刷新+自定义刷新控件"],
                       @[@"默认上拉加载",
                         @"上拉加载+动画图片",
                         @"上拉加载+隐藏刷新状态的文字",
                         @"上拉加载+全部加载完毕",
                         @"上拉加载+禁止自动加载",
                         @"上拉加载+自定义文字",
                         @"上拉加载+加载后隐藏",
                         @"上拉加载+上拉回弹",
                         @"上拉加载+自定义刷新控件(自动刷新)",
                         @"上拉加载+自定义刷新控件(自动回弹)"]
                       ];
    }
    return _numsArray;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 64.0f;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.numsArray[section];
    return array.count;;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"下拉刷新";
    }
    return @"上拉加载";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.numsArray[indexPath.section][indexPath.row];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self fristChoiseAtIndexPath:indexPath];
    }else {
        [self secondChoiseAtIndexPath:indexPath];
    }
    
}

- (void)fristChoiseAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[FristViewController new] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[SecondViewController new] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[ThirdViewController new] animated:YES];
            break;
            
        case 3:
            [self.navigationController pushViewController:[ForthViewController new] animated:YES];
            break;
            
        case 4:
            [self.navigationController pushViewController:[FifthViewController new] animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)secondChoiseAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[FooterFristViewController new] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[FooterSecondViewController new] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[FooterThirdViewController new] animated:YES];
            break;
            
        case 3:
            [self.navigationController pushViewController:[FooterForthViewController new] animated:YES];
            break;
            
        case 4:
            [self.navigationController pushViewController:[FooterFifthViewController new] animated:YES];
            break;
            
        case 5:
            [self.navigationController pushViewController:[FooterSixthViewController new] animated:YES];
            break;
        
        case 6:
            [self.navigationController pushViewController:[FooterSeventhViewController new] animated:YES];
            break;
            
        case 7:
            [self.navigationController pushViewController:[FooterEighthViewController new] animated:YES];
            break;
            
        case 8:
            [self.navigationController pushViewController:[FooterNinthViewController new] animated:YES];
            break;
        
        case 9:
            [self.navigationController pushViewController:[FooterTenthViewController     new] animated:YES];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
