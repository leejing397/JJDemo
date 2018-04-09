//
//  SecondViewController.m
//  MJRefreshTest
//
//  Created by Iris on 2018/4/9.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "SecondViewController.h"

#import "chibaoziHeader.h"

#import <MJRefresh.h>

@interface SecondViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *arrayM;

@end

@implementation SecondViewController

- (NSMutableArray *)arrayM {
    if (_arrayM == nil) {
        _arrayM = [NSMutableArray arrayWithCapacity:10];
    }
    return _arrayM;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.mj_header = [chibaoziHeader headerWithRefreshingBlock:^{
            NSLog(@"我在努力请求数据中");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_tableView.mj_header endRefreshingWithCompletionBlock:^{
                    NSLog(@"我刷新完了");
                }];
            });
        }];
        // 马上进入刷新状态
        [_tableView.mj_header beginRefreshing];
    }
    
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = @"第二";
    return cell;
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
