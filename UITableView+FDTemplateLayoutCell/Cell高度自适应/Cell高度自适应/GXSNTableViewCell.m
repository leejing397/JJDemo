//
//  GXSNTableViewCell.m
//  Cell高度自适应
//
//  Created by Iris on 2018/3/27.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "GXSNTableViewCell.h"

#import <Masonry.h>

@interface GXSNTableViewCell()
@property (strong, nonatomic) UIImageView *iconImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIImageView *image;

@end

@implementation GXSNTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.iconImage = [[UIImageView alloc]init];
        [self.contentView addSubview:self.iconImage];
        [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.top.mas_equalTo(self.contentView).mas_offset(8.0f);
            make.left.mas_equalTo(self.contentView.mas_left).offset(5);
         }];
        
        self.nameLabel = [[UILabel alloc]init];
        [self.contentView addSubview:self.nameLabel];
        self.nameLabel.numberOfLines = 0;
        
        self.image = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image];
        [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(5);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-5);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
            make.height.mas_equalTo(100.0f);
        }];
        
#warning 使用Masonry设置高度大小位置,无论如何,基于Bottom这个点是不能忽略的,位置也都是基于self.contentView
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.iconImage.mas_bottom).offset(5);
            make.left.mas_equalTo(self.contentView.mas_left).offset(5);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-5);
            make.bottom.mas_equalTo(self.image.mas_top).offset(-5);
        }];
        
        
    }
    return  self;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.bounds = [UIScreen mainScreen].bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setModel:(SNTouristCollectCircleModel *)model {
    _model = model;
    self.iconImage.image = [UIImage imageNamed:@"icon"];
    self.nameLabel.text = model.condition_info;
    self.image.image = [UIImage imageNamed:@"2018"];
    [self.image mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(100 * model.gwattachs.count);
    }];
    
}
- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    totalHeight += [self.iconImage sizeThatFits:size].height;
    totalHeight += [self.nameLabel sizeThatFits:size].height;
//    totalHeight += [self.contentImageView sizeThatFits:size].height;
    totalHeight += [self.image sizeThatFits:size].height;
    totalHeight += 40; // margins
    return CGSizeMake(size.width, totalHeight);
}
@end
