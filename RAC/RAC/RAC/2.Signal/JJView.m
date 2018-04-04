//
//  JJView.m
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "JJView.h"

@implementation JJView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(RACSubject *)btnClickSingnal {
    if (!_btnClickSingnal) {
        _btnClickSingnal = [RACSubject subject];
    }
    return _btnClickSingnal;
}

- (instancetype)init {
    if (self == [super init]) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
        [button setBackgroundColor:[UIColor redColor]];
        [self addSubview:button];
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)didClickButton:(UIButton *)btn {
    NSLog(@"点了button");
    [self.btnClickSingnal sendNext:btn.backgroundColor];
}

@end
