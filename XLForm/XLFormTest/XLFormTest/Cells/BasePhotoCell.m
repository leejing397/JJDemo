//
//  BasePhotoCell.m
//  XLFormTest
//
//  Created by Iris on 2018/4/8.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "BasePhotoCell.h"

#import <Masonry/Masonry.h>

NSString * const XLFormBasePhotoCell = @"BasePhotoCell";

@implementation BasePhotoCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[BasePhotoCell class] forKey:XLFormBasePhotoCell];
}

- (void)configure {
    [super configure];
    
    __weak typeof (self) weakSelf = self;
    
    UILabel *photoLabel = [[UILabel alloc]init];
    photoLabel.text = @"基准照片";
    [self.contentView addSubview:photoLabel];
    [photoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(weakSelf).mas_offset(8.0f);
        make.top.mas_equalTo(weakSelf).mas_offset(8.0f);
    }];
    
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 64;
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
