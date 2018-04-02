//
//  GXSNTableViewController.m
//  Cell高度自适应
//
//  Created by Iris on 2018/3/27.
//  Copyright © 2018年 Iris. All rights reserved.
//

// 弱引用
#define XMGWeakSelf __weak typeof(self) weakSelf = self

#import "GXSNTableViewController.h"
#import "SNTouristCollectCircleModel.h"
#import "GXSNTableViewCell.h"

#import <UITableView+FDTemplateLayoutCell.h>

@interface GXSNTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)NSArray *numsArray;
@end

@implementation GXSNTableViewController
- (NSArray *)numsArray {
    if (_numsArray == nil) {
        _numsArray = [NSArray array];
    }
    return _numsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[GXSNTableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.fd_debugLogEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除所有高度缓存
    [self.tableView.fd_keyedHeightCache invalidateAllHeightCache];
}
#pragma mark 获取新数据
- (void)getNewData {
    XMGWeakSelf;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [SNTouristCollectCircleModel requestTouristCollectCircleWithLastRecordTime:@"" Success:^(NSArray *successArray) {
//            NSLog(@"%@",successArray);
            self.numsArray = successArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
            
        } error:^(NSString *error) {
            
        }];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GXSNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.fd_enforceFrameLayout = NO;
    cell.model = self.numsArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"cell" cacheByIndexPath:indexPath configuration:^(GXSNTableViewCell* cell) {
        
        cell.model = self.numsArray[indexPath.row];
    }];

}
@end
