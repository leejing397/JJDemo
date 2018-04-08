//
//  SecondViewController.m
//  XLFormTest
//
//  Created by Iris on 2018/4/8.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "SecondViewController.h"

#import <XLForm/XLForm.h>

#import "SecondCell.h"
#import "BasePhotoCell.h"
#import "LivePhotoCell.h"

NSString * const XLFormSecondCell = @"XLFormSecondCell";

NSString *const kDateTimeInline = @"dateTimeInline";

@interface SecondViewController ()
@property(nonatomic,strong) XLFormDescriptor *form;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"第二个控制器"];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"长城点段信息"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"GreatWallName" rowType:XLFormRowSecondCell title:@"长城点段"];
    row.disabled = @NO;
    row.value = @{@"btnTag":@"alterPsw"};
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"basePhoto" rowType:XLFormBasePhotoCell];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDateTimeInline rowType:XLFormRowDescriptorTypeDateTimeInline title:@"时间"];
    row.value = [NSDate new];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"livePhoto" rowType:XLFormLivePhotoCell];
    [section addFormRow:row];
    
    self.form = form;
}

// 每个cell内部的参数属性更改了就会调用这个方法，我们再次更新的话就会调用cell里面update的方法进行重绘
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    // 咱们这里统一调用更新
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    [self updateFormRow:formRow];
    
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
