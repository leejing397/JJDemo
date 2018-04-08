//
//  LivePhotoCell.m
//  XLFormTest
//
//  Created by Iris on 2018/4/8.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "LivePhotoCell.h"

@class SecondViewController;

NSString *const XLFormLivePhotoCell = @"XLFormLivePhotoCell";

#import <Masonry.h>
#import <ACMediaFrame.h>
#import <UIView+ACMediaExt.h>

CGFloat _mediaH;

@interface LivePhotoCell()
@property (nonatomic,strong) ACSelectMediaView *mediaView;
@end

@implementation LivePhotoCell

-(ACSelectMediaView *)mediaView {
    if (_mediaView == nil) {
        ACSelectMediaView *mediaView = [[ACSelectMediaView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 1)];
        mediaView.type = ACMediaTypeAll;
        mediaView.backgroundColor = [UIColor redColor];
        mediaView.rootViewController = self.formViewController;
        mediaView.maxImageSelected = 12;
        mediaView.naviBarBgColor = [UIColor redColor];
        mediaView.rowImageCount = 3;
        mediaView.lineSpacing = 20;
        mediaView.interitemSpacing = 20;
        mediaView.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        [mediaView observeViewHeight:^(CGFloat mediaHeight) {
            _mediaH = mediaHeight;
            self.height = mediaHeight + 50;
            [LivePhotoCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor];
        }];
        _mediaView = mediaView;
    }
    return _mediaView;
}

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[LivePhotoCell class] forKey:XLFormLivePhotoCell];
}

- (void)configure {
    [super configure];
    
    _mediaH = 64.0f;
    self.backgroundColor = [UIColor yellowColor];
    __weak typeof (self) weakSelf = self;
    
    UILabel *photoLabel = [[UILabel alloc]init];
    photoLabel.text = @"现场照片";
    [self.contentView addSubview:photoLabel];
    [photoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(weakSelf).mas_offset(8.0f);
        make.top.mas_equalTo(weakSelf).mas_offset(8.0f);
    }];

    [self.contentView addSubview:self.mediaView];
    [self.mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(photoLabel.mas_bottom).mas_offset(8.0f);
        make.left.mas_equalTo(weakSelf);
        make.right.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf);
    }];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    
    return _mediaH + 50;
}

- (void)update {
    
    [super update];
    
    NSLog(@"update");
    
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    NSLog(@"点击了cell");
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
