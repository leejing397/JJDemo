//
//  JJView.h
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ReactiveObjC/ReactiveObjC.h>

@interface JJView : UIView

@property (nonatomic,strong) RACSubject *btnClickSingnal;

- (void)didClickButton:(UIButton *)btn ;
@end