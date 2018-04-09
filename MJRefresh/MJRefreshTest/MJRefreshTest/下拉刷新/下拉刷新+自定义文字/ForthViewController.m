//
//  ForthViewController.m
//  MJRefreshTest
//
//  Created by Iris on 2018/4/9.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ForthViewController.h"

#import <MJRefresh.h>

@interface ForthViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *arrayM;

@end

@implementation ForthViewController

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
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NSLog(@"我在努力请求数据中");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_tableView.mj_header endRefreshingWithCompletionBlock:^{
                    NSLog(@"我刷新完了");
                }];
            });
        }];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.automaticallyChangeAlpha = YES;
        
        // 设置文字
        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"放开刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
        
        // 设置字体
        header.stateLabel.font = [UIFont systemFontOfSize:15];
        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
        
        // 设置颜色
        header.stateLabel.textColor = [UIColor redColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor blueColor];
        
        _tableView.mj_header = header;
        
        // 马上进入刷新状态
        [_tableView.mj_header beginRefreshing];
    }
    
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = @"第四";
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
