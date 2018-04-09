//
//  ChibaoziFooter.m
//  MJRefreshTest
//
//  Created by Iris on 2018/4/9.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "ChibaoziFooter.h"

@implementation ChibaoziFooter
- (void)prepare {
    [super prepare];
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
