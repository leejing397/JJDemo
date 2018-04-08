//
//  SecondCell.m
//  XLFormTest
//
//  Created by Iris on 2018/4/8.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "SecondCell.h"

#import <Masonry/Masonry.h>

NSString * const XLFormRowSecondCell = @"XLFormRowSecondCell";

@interface SecondCell()
@property(nonatomic,strong) NSString *btnTag;
@end

@implementation SecondCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[SecondCell class] forKey:XLFormRowSecondCell];
}

- (void)configure {
    [super configure];
    
    __weak typeof (self) weakSelf = self;
    
    UILabel *GreatWallNameLabel = [[UILabel alloc]init];
    GreatWallNameLabel.text = @"长城点段";
    [self.contentView addSubview:GreatWallNameLabel];
    [GreatWallNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(weakSelf).mas_offset(10.0f);
        make.centerY.mas_equalTo(weakSelf);
    }];
    
    UITextField *nameTextField = [[UITextField alloc]init];
    nameTextField.placeholder = @"请选择长城点段";
    [self.contentView addSubview:nameTextField];
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(GreatWallNameLabel.mas_right).mas_offset(8.0f);
        make.top.mas_equalTo(GreatWallNameLabel.mas_top);
        make.width.mas_equalTo(200);
    }];
    
    UIButton *choiceGreatWallBtn = [[UIButton alloc]init];
    [choiceGreatWallBtn setBackgroundColor:[UIColor redColor]];
    [choiceGreatWallBtn setTitle:@"选" forState:UIControlStateNormal];
    [self.contentView addSubview:choiceGreatWallBtn];
    [choiceGreatWallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).mas_equalTo(5.0f);
        make.centerY.mas_equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 64;
}

-(void)update{
    [super update];
    
    NSDictionary *value = self.rowDescriptor.value;
    NSString *btnTag =  [value objectForKey:@"btnTag"];
    _btnTag = btnTag;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
