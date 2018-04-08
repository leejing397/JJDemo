//
//  ACSelectMediaView.m
//
//  Created by ArthurCao<https://github.com/honeycao> on 2017/04/12.
//  Version: 2.0.4.
//  Update: 2017/12/28.
//

#import "ACSelectMediaView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ACMediaManager.h"
#import "ACMediaImageCell.h"
//Ext
#import "NSString+ACMediaExt.h"
#import "UIImage+ACGif.h"
#import "UIView+ACMediaExt.h"
#import "UIViewController+ACMediaExt.h"
//git
#import "ACAlertController.h"
#import "TZImagePickerController.h"
#import "MWPhotoBrowser.h"

@interface ACSelectMediaView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) ACMediaHeightBlock block;

@property (nonatomic, copy) ACSelectMediaBackBlock backBlock;

/** 总的媒体数组 */
@property (nonatomic, strong) NSMutableArray *mediaArray;

/** 记录从相册中已选的Image Asset */
@property (nonatomic, strong) NSMutableArray *selectedImageAssets;

/** 字典存储从相册中已选的 Asset 以及对应显示的下标: key为asset, value为下标（下标是mediaArray中对应的下标） */
@property (nonatomic, strong) NSMutableDictionary *selectedAssetsDic;

/** MWPhoto对象数组 */
@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation ACSelectMediaView

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.frame = CGRectMake(self.x, self.y, self.width, ACMedia_ScreenWidth/4);
        [self _setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

///设置初始值
- (void)_setup
{
    _mediaArray = [NSMutableArray array];
    _preShowMedias = [NSMutableArray array];
    _selectedImageAssets = [NSMutableArray array];
    self.selectedAssetsDic = [NSMutableDictionary dictionary];
    _type = ACMediaTypePhotoAndCamera;
    _showDelete = YES;
    _showAddButton = YES;
    _allowMultipleSelection = YES;
    _maxImageSelected = 9;
    _videoMaximumDuration = 60;
    _backgroundColor = [UIColor whiteColor];
    _rowImageCount = 4;
    _lineSpacing = 10.0;
    _interitemSpacing = 10.0;
    _sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self configureCollectionView];
}

- (void)configureCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    [_collectionView registerClass:[ACMediaImageCell class] forCellWithReuseIdentifier:NSStringFromClass([ACMediaImageCell class])];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = _backgroundColor;
    [self addSubview:_collectionView];
}

#pragma mark - setter

- (void)setShowDelete:(BOOL)showDelete {
    _showDelete = showDelete;
}

- (void)setShowAddButton:(BOOL)showAddButton {
    _showAddButton = showAddButton;
    if (_mediaArray.count > 3 || _mediaArray.count == 0) {
        [self layoutCollection];
    }
}

- (void)setPreShowMedias:(NSArray *)preShowMedias {
    
    _preShowMedias = preShowMedias;
    NSMutableArray *temp = [NSMutableArray array];
    for (id object in preShowMedias) {
        ACMediaModel *model = [ACMediaModel new];
        if ([object isKindOfClass:[UIImage class]]) {
            model.image = object;
        }else if ([object isKindOfClass:[NSString class]]) {
            NSString *obj = (NSString *)object;
            if ([obj isValidUrl]) {
                model.imageUrlString = object;
            }else if ([obj isGifImage]) {
                //名字中有.gif是识别不了的（和自己的拓展名重复了，所以先去掉）
                NSString *name_ = obj.lowercaseString;
                if ([name_ containsString:@"gif"]) {
                    name_ = [name_ stringByReplacingOccurrencesOfString:@".gif" withString:@""];
                }
                model.image = [UIImage ac_setGifWithName:name_];
            }else {
                model.image = [UIImage imageNamed:object];
            }
        }else if ([object isKindOfClass:[ACMediaModel class]]) {
            model = object;
        }
        [temp addObject:model];
    }
    if (temp.count > 0) {
        _mediaArray = temp;
        [self layoutCollection];
    }
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [_collectionView setBackgroundColor:backgroundColor];
}

- (void)setRowImageCount:(NSInteger)rowImageCount {
    _rowImageCount = rowImageCount;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    _sectionInset = sectionInset;
}

#pragma mark - public method

- (void)observeViewHeight:(ACMediaHeightBlock)value {
    _block = value;
    [self layoutCollection];
}

- (void)observeSelectedMediaArray: (ACSelectMediaBackBlock)backBlock {
    _backBlock = backBlock;
}

+ (CGFloat)defaultViewHeight {
    return 1;
}

- (void)reload {
    [self layoutCollection];
}

#pragma mark -  Collection View DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num = self.mediaArray.count < _maxImageSelected ? self.mediaArray.count : _maxImageSelected;
    //图片最大数不显示添加按钮
    if (num == _maxImageSelected) {
        return _maxImageSelected;
    }
    return _showAddButton ? num + 1 : num;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ACMediaImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ACMediaImageCell class]) forIndexPath:indexPath];
    if (indexPath.row == _mediaArray.count) {
        [cell showAddWithImage:self.addImage];
    }else{
        ACMediaModel *model = [[ACMediaModel alloc] init];
        model = _mediaArray[indexPath.row];
        
        if (model.imageUrlString) {
            [cell showIconWithUrlString:model.imageUrlString image:nil];
        }else {
            //这个地方可能会存在一个问题
            [cell showIconWithUrlString:nil image:model.image];
        }
        [cell videoImage:self.videoTagImage show:model.isVideo];
        [cell deleteButtonWithImage:self.deleteImage show:_showDelete];
        
        cell.ACMediaClickDeleteButton = ^{
            ACMediaModel *model = _mediaArray[indexPath.row];
            if (!_allowMultipleSelection) {
                [self adjustSelectedAssetsDicWithDeletedIndex:indexPath.row deletedAsset:model.asset];
            }
            
            [_mediaArray removeObjectAtIndex:indexPath.row];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self layoutCollection];
            });
        };
    }
    return cell;
}

#pragma mark - collection view delegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.lineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.interitemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemW = (self.width - self.sectionInset.left - (self.rowImageCount - 1) * self.interitemSpacing - self.sectionInset.right) / self.rowImageCount;
    return CGSizeMake(itemW, itemW);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.sectionInset;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _mediaArray.count && _mediaArray.count >= _maxImageSelected) {
        [UIAlertController showAlertWithTitle:[NSString stringWithFormat:@"最多只能选择%ld张",(long)_maxImageSelected] message:nil actionTitles:@[@"确定"] cancelTitle:nil style:UIAlertControllerStyleAlert completion:nil];
        return;
    }
    
    ACMediaWeakSelf
    //点击的是添加媒体的按钮
    if (indexPath.row == _mediaArray.count) {
        switch (_type) {
            case ACMediaTypePhoto:
                [self openAlbum];
                break;
            case ACMediaTypeCamera:
                [self openCamera];
                break;
            case ACMediaTypePhotoAndCamera:
            {
                ACAlertController *alert = [[ACAlertController alloc] initWithActionSheetTitles:@[@"相册", @"相机"] cancelTitle:@"取消"];
                [alert clickActionButton:^(NSInteger index) {
                    if (index == 0) {
                        [weakSelf openAlbum];
                    }else {
                        [weakSelf openCamera];
                    }
                }];
                [alert show];
            }
                break;
            case ACMediaTypeVideotape:
                [self openVideotape];
                break;
            case ACMediaTypeVideo:
                [self openVideo];
                break;
            default:
            {
                ACAlertController *alert = [[ACAlertController alloc] initWithActionSheetTitles:@[@"相册", @"相机", @"录像", @"视频"] cancelTitle:@"取消"];
                [alert clickActionButton:^(NSInteger index) {
                    if (index == 0) {
                        [weakSelf openAlbum];
                    }else if (index == 1) {
                        [weakSelf openCamera];
                    }else if (index == 2) {
                        [weakSelf openVideotape];
                    }else {
                        [weakSelf openVideo];
                    }
                }];
                [alert show];
            }
                break;
        }
    }
    //展示媒体
    else {
        _photos = [NSMutableArray array];
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = NO;
        browser.alwaysShowControls = NO;
        browser.displaySelectionButtons = NO;
        browser.zoomPhotosToFill = YES;
        browser.displayNavArrows = NO;
        browser.startOnGrid = NO;
        browser.enableGrid = YES;
        for (ACMediaModel *model in _mediaArray) {
            MWPhoto *photo = [MWPhoto photoWithImage:model.image];
            photo.caption = model.name;
            if (model.isVideo) {
                if (model.mediaURL) {
                    photo.videoURL = model.mediaURL;
                }else {
                    photo = [photo initWithAsset:model.asset targetSize:CGSizeZero];
                }
            }else if (model.imageUrlString) {
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:model.imageUrlString]];
            }
            [_photos addObject:photo];
        }
        [browser setCurrentPhotoIndex:indexPath.row];
        [[self viewController].navigationController pushViewController:browser animated:YES];
    }
}

#pragma mark - <MWPhotoBrowserDelegate>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}

#pragma mark - 布局

///计算高度，刷新collectionview，并返回相应的高度和数据
- (void)layoutCollection {
    NSInteger itemCount = _showAddButton ? _mediaArray.count + 1 : _mediaArray.count;
    //图片最大数也不显示添加按钮
    if (_mediaArray.count == _maxImageSelected && _showAddButton) {
        itemCount -= 1;
    }
    _collectionView.height = [self collectionHeightWithCount:itemCount];
    self.height = _collectionView.height;
    !_block ?  : _block(_collectionView.height);
    !_backBlock ?  : _backBlock(_mediaArray);
    
    [_collectionView reloadData];
}

- (CGFloat)collectionHeightWithCount: (NSInteger)count
{
    NSInteger maxRow = count == 0 ? 0 : (count - 1) / self.rowImageCount + 1;
    CGFloat itemH = (self.width - self.sectionInset.left - (self.rowImageCount - 1) * self.interitemSpacing - self.sectionInset.right) / self.rowImageCount;
    CGFloat h = maxRow == 0 ? 0 : (maxRow * itemH + (maxRow - 1) * self.lineSpacing + self.sectionInset.top + self.sectionInset.bottom);
    return h;
}

#pragma mark - actions

///相册
- (void)openAlbum {
    NSInteger count = 0;
    if (!_allowMultipleSelection) {
        count = _maxImageSelected - (_mediaArray.count - _selectedImageAssets.count);
    }else {
        count = _maxImageSelected - _mediaArray.count;
    }
    
    TZImagePickerController *imagePickController = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:self];
    [self configureTZNaviBar:imagePickController];
    [[self currentViewController] presentViewController:imagePickController animated:YES completion:nil];
}

/** 相机 */
- (void)openCamera {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;

    if ([UIImagePickerController isSourceTypeAvailable: sourceType]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [[self currentViewController] presentViewController:picker animated:YES completion:nil];
    }else{
        [UIAlertController showAlertWithTitle:@"该设备不支持拍照" message:nil actionTitles:@[@"确定"] cancelTitle:nil style:UIAlertControllerStyleAlert completion:nil];
    }
}

/** 录像 */
- (void)openVideotape {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray * mediaTypes =[UIImagePickerController  availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = mediaTypes;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        picker.videoMaximumDuration = self.videoMaximumDuration;        //录像最长时间
    } else {
        [UIAlertController showAlertWithTitle:@"当前设备不支持录像" message:nil actionTitles:@[@"确定"] cancelTitle:nil style:UIAlertControllerStyleAlert completion:nil];
    }
    [[self currentViewController] presentViewController:picker animated:YES completion:nil];

}

/** 视频 */
- (void)openVideo {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    picker.allowsEditing = YES;
    [[self currentViewController] presentViewController:picker animated:YES completion:nil];
}

#pragma mark - TZImagePickerController Delegate

//相册选取图片
- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    [self handleAssetsFromAlbum:assets photos:photos];
}

///选取视频后的回调
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
    [[ACMediaManager manager] getMediaInfoFromAsset:asset completion:^(NSString *name, id pathData) {
        ACMediaModel *model = [[ACMediaModel alloc] init];
        model.name = name;
        model.uploadType = pathData;
        model.image = coverImage;
        model.isVideo = YES;
        model.asset = asset;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!self.allowMultipleSelection) {
                //去重，判断是否有想同
                for (ACMediaModel *md in self.mediaArray) {
                    if ([md.asset isEqual:asset]) {
                        return;
                    }
                }
            }
            [self.mediaArray addObject:model];
            [self layoutCollection];
            
        });
    }];
}

#pragma mark - UIImagePickerController Delegate
///拍照、选视频图片、录像 后的回调（这种方式选择视频时，会自动压缩，但是很耗时间）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];

    //媒体类型
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //原图URL
    NSURL *imageAssetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    ///视频 和 录像
    if ([mediaType isEqualToString:@"public.movie"]) {
        
        NSURL *videoAssetURL = [info objectForKey:UIImagePickerControllerMediaURL];
        PHAsset *asset;
        //录像没有原图 所以 imageAssetURL 为nil
        if (imageAssetURL) {
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetURL] options:nil];
            asset = [result firstObject];
        }
        [[ACMediaManager manager] getVideoPathFromURL:videoAssetURL PHAsset:asset enableSave:NO completion:^(NSString *name, UIImage *screenshot, id pathData) {
            ACMediaModel *model = [[ACMediaModel alloc] init];
            model.image = screenshot;
            model.name = name;
            model.uploadType = pathData;
            model.isVideo = YES;
            model.mediaURL = videoAssetURL;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mediaArray addObject:model];
                [self layoutCollection];
            });
        }];
    }
    
    else if ([mediaType isEqualToString:@"public.image"]) {
        
        UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
        //如果 picker 没有设置可编辑，那么image 为 nil
        if (image == nil) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        PHAsset *asset;
        //拍照没有原图 所以 imageAssetURL 为nil
        if (imageAssetURL) {
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetURL] options:nil];
            asset = [result firstObject];
        }
        [[ACMediaManager manager] getImageInfoFromImage:image PHAsset:asset completion:^(NSString *name, NSData *data) {
            ACMediaModel *model = [[ACMediaModel alloc] init];
            model.image = image;
            model.name = name;
            model.uploadType = data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mediaArray addObject:model];
                [self layoutCollection];
            });
        }];
    }
}

#pragma mark - private methods

/** 从相册中选择图片之后的数据处理 */
- (void)handleAssetsFromAlbum: (NSArray *)assets photos: (NSArray *)photos
{
    NSMutableArray *selectedAssets = [self.selectedImageAssets mutableCopy];
    
    if ([selectedAssets isEqualToArray: assets]) {
        return;
    }
    
    NSMutableArray *newAssets = [NSMutableArray arrayWithArray:assets];
    NSMutableArray *deletedAssets = [selectedAssets mutableCopy];
    NSArray *existentAssets = [NSArray array];
    
    if (!self.allowMultipleSelection) {
        
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF in %@",assets];
        //取交集
        existentAssets = [selectedAssets filteredArrayUsingPredicate:pre];
        
        //已选好的图片数组 - 共同存在的数组 = 已经被删除的数组
        [deletedAssets removeObjectsInArray:existentAssets];
        
        //从相册新选好的图片数组 - 共同存在的数组 = 新选取的数组
        [newAssets removeObjectsInArray:existentAssets];
        
        for (PHAsset *delete in deletedAssets) {
            NSInteger idx = [[self.selectedAssetsDic objectForKey:delete] integerValue];
            [self.mediaArray removeObjectAtIndex:idx];
            [self adjustSelectedAssetsDicWithDeletedIndex:idx deletedAsset:delete];
        }
        if (newAssets.count == 0) {
            [self layoutCollection];
            return;
        }
    }
    
    for (PHAsset *new in newAssets) {
        NSInteger index = [assets indexOfObject:new];
        __weak typeof(self) weakSelf = self;
        [[ACMediaManager manager] getMediaInfoFromAsset:new completion:^(NSString *name, id pathData) {
            
            ACMediaModel *model = [[ACMediaModel alloc] init];
            model.name = name;
            model.asset = new;
            model.uploadType = pathData;
            model.image = photos[index];
            
            if ([NSString isGifWithImageData:pathData]) {
                model.image = [UIImage ac_setGifWithData:pathData];
            }
            
            if (!weakSelf.allowMultipleSelection) {
                [self.selectedAssetsDic setObject:[NSNumber numberWithInteger:self.mediaArray.count] forKey:new];
                self.selectedImageAssets = [NSMutableArray arrayWithArray:assets];
            }else {
                [self.selectedImageAssets addObjectsFromArray:assets];
            }
            [self.mediaArray addObject:model];
            
            //最后一个处理完就在主线程中进行布局
            if ([new isEqual:[newAssets lastObject]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self layoutCollection];
                });
            }
        }];
    }
}

/** 数据源有删减的时候，调整字典中所删除的下标之后其余下标值、更新selectedImageAssets中的数据 */
- (void)adjustSelectedAssetsDicWithDeletedIndex: (NSInteger)deletedIndex deletedAsset: (PHAsset *)deletedAsset
{
    if (deletedAsset) {
        [self.selectedAssetsDic removeObjectForKey:deletedAsset];
    }
    if ([self.selectedImageAssets containsObject:deletedAsset]) {
        [self.selectedImageAssets removeObject:deletedAsset];
    }
    for (PHAsset *asset in self.selectedAssetsDic.allKeys) {
        NSInteger idx = [[self.selectedAssetsDic objectForKey:asset] integerValue];
        if (idx > deletedIndex) {
            [self.selectedAssetsDic setObject:[NSNumber numberWithInteger:idx-1] forKey:asset];
        }
    }
}

///配置 TZImagePickerController属性、导航栏属性
- (void)configureTZNaviBar: (TZImagePickerController *)pick
{
    pick.allowTakePicture = self.allowTakePicture;
    pick.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
    pick.allowPickingVideo = self.allowPickingVideo;
    if (!_allowMultipleSelection) {
        pick.selectedAssets = self.selectedImageAssets;
    }
    
    if (self.naviBarBgColor) {
        pick.naviBgColor = self.naviBarBgColor;
    }
    if (self.naviBarTitleColor) {
        pick.naviTitleColor = self.naviBarTitleColor;
    }
    if (self.naviBarTitleFont) {
        pick.naviTitleFont = self.naviBarTitleFont;
    }
    if (self.barItemTextColor) {
        pick.barItemTextColor = self.barItemTextColor;
    }
    if (self.barItemTextFont) {
        pick.barItemTextFont = self.barItemTextFont;
    }
    if (self.barBackButton) {
        pick.navLeftBarButtonSettingBlock = ^(UIButton *leftButton) {
            leftButton = _barBackButton;
        };
    }
    pick.isStatusBarDefault = self.isStatusBarDefault;
}

///获取当前的控制器，优先使用外界的赋值
- (UIViewController *)currentViewController
{
    //if set rootViewController
    if (self.rootViewController) {
        return self.rootViewController;
    }
    
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    NSAssert(result, @"\n*******\n rootViewController must not be nil. \n******");
    
    return result;
}

@end
