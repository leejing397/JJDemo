//
//  FristViewController.m
//  MJRefreshTest
//
//  Created by Iris on 2018/4/9.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "FristViewController.h"

#import <MJRefresh/MJRefresh.h>

@interface FristViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *fristTableView;
@property (nonatomic,strong) NSMutableArray *fristArrayM;
@end

@implementation FristViewController

- (NSMutableArray *)fristArrayM {
    if (_fristArrayM == nil) {
        _fristArrayM = [NSMutableArray arrayWithCapacity:10];
    }
    return _fristArrayM;
}

- (UITableView *)fristTableView {
    if (_fristTableView == nil) {
        _fristTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _fristTableView.delegate = self;
        _fristTableView.dataSource = self;
        [_fristTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _fristTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NSLog(@"我在努力请求数据中");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_fristTableView.mj_header endRefreshingWithCompletionBlock:^{
                    NSLog(@"我刷新完了");
                }];
            });
        }];
        // 马上进入刷新状态
        [_fristTableView.mj_header beginRefreshing];
    }
    
    return _fristTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.fristTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fristArrayM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = @"我想静静";
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
