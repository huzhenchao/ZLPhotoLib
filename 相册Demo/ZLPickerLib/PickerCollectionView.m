//
//  PickerCollectionView.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerCollectionView.h"
#import "PickerCollectionViewCell.h"
#import "PickerImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PickerCollectionView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic , strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic , strong) NSMutableArray *images;

@end

@implementation PickerCollectionView

#pragma mark -getter
- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

#pragma mark -setter
- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;

    for (int i = 0; i < dataArray.count; i++) {
        id resource = dataArray[i];
        if ([resource isKindOfClass:[UIImage class]]) {
            [self.images addObject:resource];
        }else if([resource isKindOfClass:[NSString class]]){
                // 如果不存在Asset就去请求加载
            [self getAssetURLWithImage:resource];
        }else if ([resource isKindOfClass:[ALAsset class]]){
            [self getAssetWithImage:resource];
        }
    }
    
    [self reloadData];
    
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectPictureArray = [NSMutableArray array];
    }
    return self;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerCollectionViewCell *cell = [PickerCollectionViewCell cellWithCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    PickerImageView *cellImgView = [[PickerImageView alloc] initWithFrame:cell.bounds];
    cellImgView.contentMode = UIViewContentModeScaleAspectFill;
    cellImgView.clipsToBounds = YES;
    [cell.contentView addSubview:cellImgView];
    
    cellImgView.image = self.images[indexPath.item];
    
    return cell;
}

#pragma mark 根据URL来获取图片
- (void) getAssetURLWithImage:(NSString *) assetUrl{
    [self.assetsLibrary assetForURL:[NSURL URLWithString:assetUrl] resultBlock:^(ALAsset *asset)
     {
         //在这里使用asset来获取图片
         ALAssetRepresentation *assetRep = [asset defaultRepresentation];
         CGImageRef imgRef = [assetRep fullResolutionImage];
         UIImage *img = [UIImage imageWithCGImage:imgRef
                                            scale:assetRep.scale
                                      orientation:(UIImageOrientation)assetRep.orientation];
         [self.images addObject:img];
     } failureBlock:nil];
}

#pragma mark 根据ALAsset来获取
- (void) getAssetWithImage:(ALAsset *) asset{
    //在这里使用asset来获取图片
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    CGImageRef imgRef = [asset thumbnail];
    UIImage *img = [UIImage imageWithCGImage:imgRef
                                       scale:assetRep.scale
                                 orientation:(UIImageOrientation)assetRep.orientation];
    [self.images addObject:img];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerCollectionViewCell *cell = (PickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    PickerImageView *pickerImageView = [cell.contentView.subviews lastObject];
    // 如果没有就添加到数组里面，存在就移除
    if (pickerImageView.isMaskViewFlag) {
        [self.selectPictureArray removeObject:pickerImageView.image];
    }else{
        [self.selectPictureArray addObject:pickerImageView.image];
    }
    pickerImageView.maskViewFlag = ([pickerImageView isKindOfClass:[PickerImageView class]]) && !pickerImageView.isMaskViewFlag;
}

@end
