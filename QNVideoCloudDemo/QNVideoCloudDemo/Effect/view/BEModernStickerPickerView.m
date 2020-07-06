// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BEModernStickerPickerView.h"
#import <Masonry/Masonry.h>
#import "BEModernStickerCollectionViewCell.h"
#import <PLSEffect/PLSEffect.h>

@interface BEModernStickerPickerView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, copy) NSArray<PLSEffectModel *> *stickers;
@property (nonatomic, weak) NSIndexPath* currentSelectedCellIndexPath;
@property(nonatomic, strong) UIView* containerView;

@end

@implementation BEModernStickerPickerView

- (UIView *)contentView {
    return self.containerView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        self.containerView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundColor = UIColor.clearColor;
        [self addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(220);
            make.left.bottom.right.equalTo(self);
        }];
        
        [self.containerView addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView);
            make.bottom.mas_equalTo(self.containerView).with.offset(5);
            make.leading.trailing.equalTo(self.containerView);
        }];
        self.collectionView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    }
    return self;
}

- (void)refreshWithStickers:(NSArray<PLSEffectModel *> *)stickers{
    self.stickers = stickers;
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - BECloseableProtocol
- (void)onClose {
    if (_currentSelectedCellIndexPath){
        [self.collectionView deselectItemAtIndexPath:_currentSelectedCellIndexPath animated:false];
        _currentSelectedCellIndexPath = nil;
        
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.stickers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    BEModernStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    [cell configureWithSticker:self.stickers[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _currentSelectedCellIndexPath =indexPath;

    _selectedSticker = self.stickers[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(stickerPicker:didSelectSticker:)]) {
        [self.delegate stickerPicker:self didSelectSticker:self.stickers[indexPath.row]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 70);
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 11;
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 20, 5, 20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[BEModernStickerCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([self class])];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}
@end
