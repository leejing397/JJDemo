//
//  TableViewController.m
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "TableViewController.h"

#import "BlockViewController.h"
#import "SignalViewController.h"
#import "SubjectViewController.h"
#import "SetViewController.h"
#import "CommonUseViewController.h"
#import "AdvancedUseViewController.h"
#import "FinaleViewController.h"

@interface TableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSArray *listArray;
@end

@implementation TableViewController

- (NSArray *)listArray {
    if (_listArray == nil) {
        _listArray = @[@"回顾block",
                       @"signal",
                       @"subject",
                       @"集合类",
                       @"常用用法",
                       @"高级用法",
                       @"终结篇"
                       ];
    }
    return _listArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RAC";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.listArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[BlockViewController new] animated:YES];
            break;
            
        case 1:
            [self.navigationController pushViewController:[SignalViewController new] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[SubjectViewController new] animated:YES];
            break;
            
        case 3:
            [self.navigationController pushViewController:[SetViewController new] animated:YES];
            break;
            
        case 4:
            [self.navigationController pushViewController:[CommonUseViewController new] animated:YES];
            break;
            
        case 5:
            [self.navigationController pushViewController:[AdvancedUseViewController new] animated:YES];
            break;
            
        case 6:
            [self.navigationController pushViewController:[FinaleViewController new] animated:YES];
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
