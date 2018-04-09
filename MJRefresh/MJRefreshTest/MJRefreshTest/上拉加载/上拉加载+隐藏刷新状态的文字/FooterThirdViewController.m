//
//  FooterThirdViewController.m
//  MJRefreshTest
//
//  Created by Iris on 2018/4/9.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "FooterThirdViewController.h"

#import <MJRefresh.h>

#import "ChibaoziFooter.h"

@interface FooterThirdViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSMutableArray *footerArrayM;
@property (nonatomic,strong)UITableView *footerTabelView;
@end


@implementation FooterThirdViewController

- (NSMutableArray *)footerArrayM {
    if (_footerArrayM == nil) {
        _footerArrayM = [NSMutableArray arrayWithCapacity:10];
    }
    return _footerArrayM;
}

- (UITableView *)footerTabelView {
    if (_footerTabelView == nil) {
        _footerTabelView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _footerTabelView.delegate = self;
        _footerTabelView.dataSource = self;
        [_footerTabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _footerTabelView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NSLog(@"我在努力请求数据中");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_footerTabelView.mj_header endRefreshingWithCompletionBlock:^{
                    NSLog(@"我刷新完了");
                }];
            });
        }];
        // 马上进入刷新状态
        [_footerTabelView.mj_header beginRefreshing];
        
        
        // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
        ChibaoziFooter *footer = [ChibaoziFooter footerWithRefreshingBlock:^{
            NSLog(@"上拉加载中。。。");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_footerTabelView.mj_footer endRefreshingWithCompletionBlock:^{
                    NSLog(@"我加载完了");
                }];
            });
        }];
        
        // 当上拉刷新控件出现50%时（出现一半），就会自动刷新。这个值默认是1.0（也就是上拉刷新100%出现时，才会自动刷新）
        footer.triggerAutomaticallyRefreshPercent = 0.5;
        
        // 隐藏刷新状态的文字
        footer.refreshingTitleHidden = YES;
        
        _footerTabelView.mj_footer = footer;
    }
    
    return _footerTabelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.footerTabelView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.footerArrayM.count;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
