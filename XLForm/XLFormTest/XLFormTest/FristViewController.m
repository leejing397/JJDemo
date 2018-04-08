//
//  FristViewController.m
//  XLFormTest
//
//  Created by Iris on 2018/4/8.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "FristViewController.h"

#import "XLForm.h"

@interface FristViewController ()
@property (nonatomic,strong)XLFormDescriptor *form;
@end

@implementation FristViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    //先将组添加到表单
    //设置标题
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // 添加一个cell
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Title" rowType:XLFormRowDescriptorTypeText];
    //设置placeholder
    [row.cellConfigAtConfigure setObject:@"Title" forKey:@"textField.placeholder"];
    row.required = YES;
    [section addFormRow:row];
    
    // Starts
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"starts" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Starts"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [section addFormRow:row];
    
    self.form = form;
    
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
