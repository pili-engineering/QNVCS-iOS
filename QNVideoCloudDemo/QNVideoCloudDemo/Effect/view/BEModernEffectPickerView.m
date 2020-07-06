// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import "BEModernEffectPickerView.h"
#import "BEEffectContentCollectionViewCell.h"
#import "BEEffectSwitchTabView.h"
#import <Masonry/Masonry.h>
#import "BEFaceBeautyView.h"
#import "BEButtonViewCell.h"
#import "BETextSliderView.h"
#import "BECategoryView.h"
#import "BEButtonItemModel.h"

NSInteger TYPE_NO_SELECT = -2;

@interface BEModernEffectPickerView ()<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
BEEffectSwitchTabViewDelegate,
UIGestureRecognizerDelegate,
TextSliderViewDelegate,
BEFaceBeautyViewDelegate,
BEModernFilterPickerViewDelegate>

@property (nonatomic, strong) UIView *vBackground;
@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) BECategoryView *categoryView;
@property (nonatomic, strong) BETextSliderView *textSlider;
@property (nonatomic, strong) UIButton *btnBack;
@property (nonatomic, strong) UILabel *lTitle;
@property (nonatomic, strong) BEFaceBeautyView *makeupOption;

@property (nonatomic, copy) NSArray <BEEffectCategoryModel *> *categories;
@property (nonatomic, strong) NSMutableSet *registeredCellClass;
@property (nonatomic, strong) BEButtonItemModel *rootNode;

@property (nonatomic, strong) NSMutableArray *mapArr;

@property (nonatomic, strong) BEFaceBeautyView *selectedListView;
@property (nonatomic, strong) BEButtonItemModel *selectedItem;
@property (nonatomic, strong) PLSEffectModel *selectedFilter;
@property (nonatomic, strong) BEButtonItemModel *backItem;

@property(nonatomic, strong) UIView* containerView;

@end

@implementation BEModernEffectPickerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)contentView {
    return self.containerView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.containerView = [[UIView alloc] init];
        [self addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.mas_equalTo(200);
        }];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.containerView addSubview:self.vBackground];
        self.categoryView.contentView = self.contentCollectionView;
        [self.containerView addSubview:self.categoryView];
        [self.containerView addSubview:self.textSlider];
        
        [self.containerView addSubview:self.lTitle];
        [self.containerView addSubview:self.btnBack];
        
        [self.vBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.containerView);
            make.top.equalTo(self.textSlider.mas_bottom).with.offset(5);
        }];
        [self.textSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView.mas_top).with.offset(-20);
//            make.bottom.equalTo(self.vBackground.mas_top).with.offset(-10);
            make.left.mas_equalTo(self.containerView.mas_left).mas_offset(20);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(self.containerView.bounds.size.width * 0.7);
        }];
        
        [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.vBackground);
        }];
        [self.lTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.categoryView.switchTabView);
        }];
        [self.btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.categoryView.switchTabView);
            make.width.mas_equalTo(self.btnBack.mas_height);
        }];
        
        _rootNode = [[BEButtonItemModel alloc] init];
        _rootNode.level = 0;
        
        _mapArr = [NSMutableArray new];
    }

    return self;
}

- (void)loadData {
    NSMutableArray *cat = [NSMutableArray new];
    
    NSArray<PLSMakeUpComponentModel *> *beautyArr = [_dataManager fetchMakeUpComponentsWithType:PLSMakeUpComponentTypeBeauty];
    if ( beautyArr.count > 0) {
        [cat addObject:[BEEffectCategoryModel categoryWithType:BEEffectPanelTabBeautyFace title:@"美颜"]];
        [_mapArr addObject:[NSMutableDictionary new]];
        BEButtonItemModel *beautyNode = [BEButtonItemModel new];
        beautyNode.type = PLSMakeUpComponentTypeUndefined;
        [_rootNode addChild:beautyNode];
        
        BEButtonItemModel *clear = [BEButtonItemModel clearModel];
        clear.type = PLSMakeUpComponentTypeBeauty;
        [beautyNode addChild:clear];
        
        for (PLSMakeUpComponentModel *item in beautyArr) {
            BEButtonItemModel *btItem = [BEButtonItemModel beautyModelWithInternalKey:item.internalKey];
            btItem.relatedModel = item;
            btItem.title = item.displayName;
            [beautyNode addChild:btItem];
        }
    }
    
    NSArray<PLSMakeUpComponentModel *> *reshapeArr = [_dataManager fetchMakeUpComponentsWithType:PLSMakeUpComponentTypeReshape];
    if (reshapeArr.count > 0) {
        [cat addObject:[BEEffectCategoryModel categoryWithType:BEEffectPanelTabBeautyReshape title:@"美型"]];
        [_mapArr addObject:[NSMutableDictionary new]];
        BEButtonItemModel *reshapeNode = [BEButtonItemModel new];
        reshapeNode.type = PLSMakeUpComponentTypeUndefined;
        [_rootNode addChild:reshapeNode];
        
        BEButtonItemModel *clear = [BEButtonItemModel clearModel];
        clear.type = PLSMakeUpComponentTypeReshape;
        [reshapeNode addChild:clear];
        
        for (PLSMakeUpComponentModel *item in reshapeArr) {
            BEButtonItemModel *btItem = [BEButtonItemModel reshapeModelWithInternalKey:item.internalKey];
            btItem.relatedModel = item;
            btItem.title = item.displayName;
            [reshapeNode addChild:btItem];
        }
    }
    
    NSArray<PLSMakeUpComponentModel *> *bodyArr = [_dataManager fetchMakeUpComponentsWithType:PLSMakeUpComponentTypeBody];
    if (bodyArr.count > 0) {
        [cat addObject:[BEEffectCategoryModel categoryWithType:BEEffectPanelTabBeautyBody title:@"美体"]];
        [_mapArr addObject:[NSMutableDictionary new]];
        BEButtonItemModel *bodyNode = [BEButtonItemModel new];
        bodyNode.type = PLSMakeUpComponentTypeUndefined;
        [_rootNode addChild:bodyNode];
        
        BEButtonItemModel *clear = [BEButtonItemModel clearModel];
        clear.type = PLSMakeUpComponentTypeBody;
        [bodyNode addChild:clear];
        
        for (PLSMakeUpComponentModel *item in bodyArr) {
            BEButtonItemModel *btItem = [BEButtonItemModel bodyModelWithInternalKey:item.internalKey];
            btItem.relatedModel = item;
            btItem.title = item.displayName;
            [bodyNode addChild:btItem];
        }
    }
    
    NSDictionary* map = @{
        @(PLSMakeUpTypeLip):@"口红",
        @(PLSMakeUpTypeBlush):@"腮红",
        @(PLSMakeUpTypeFacial):@"修容",
        @(PLSMakeUpTypePupil):@"美瞳",
        @(PLSMakeUpTypeHair):@"染发",
        @(PLSMakeUpTypeEyeshadow):@"眼影",
        @(PLSMakeUpTypeEyebrow):@"眉毛"
    };
    
    BEButtonItemModel *makeupNode = [BEButtonItemModel new];
    makeupNode.level = _rootNode.level + 1;
    BEButtonItemModel *clear = [BEButtonItemModel clearModel];
    [makeupNode addChild:clear];
    for (NSInteger i = PLSMakeUpTypeLip; i < PLSMakeUpTypeEnd; i ++) {
        PLSMakeupModel * makeup = [_dataManager fetchMakeUpWithType:(PLSMakeUpType)i];
        if (makeup.effectList.count > 0) {
            BEButtonItemModel *node = [BEButtonItemModel makeupModelWithType:i];
            node.title = map[@(i)];
            [makeupNode addChild:node];
            
            BEButtonItemModel *clear = [BEButtonItemModel clearModel];
            clear.type = i;
            [node addChild:clear];
            for (PLSMakeUpComponentModel *item in makeup.effectList) {
                BEButtonItemModel *btItem = [BEButtonItemModel makeupModelWithType:i];
                btItem.relatedModel = item;
                btItem.title = item.displayName;
                [node addChild:btItem];
            }
        }
    }
    
    if (makeupNode.children.count > 1) {
        [cat addObject:[BEEffectCategoryModel categoryWithType:BEEffectPanelTabMakeup title:@"美妆"]];
        [_mapArr addObject:[NSMutableDictionary new]];
        [_rootNode addChild:makeupNode];
    }
    
    NSArray<PLSEffectModel *> *filterArr = [_dataManager fetchEffectListWithType:PLSEffectTypeFilter];
    if (filterArr.count > 0) {
        [cat addObject:[BEEffectCategoryModel categoryWithType:BEEffectPanelTabFilter title:@"滤镜"]];
        BEButtonItemModel *filterNode = [BEButtonItemModel new];
        filterNode.type = PLSMakeUpTypeUndefined;
        [_rootNode addChild:filterNode];
        
        BEButtonItemModel *clear = [BEButtonItemModel clearModel];
        PLSEffectModel *emptyFilter = [PLSEffectModel new];
        emptyFilter.displayName = @"无";
        emptyFilter.iconImage = [UIImage imageNamed:@"iconCloseButtonNormal"];
        emptyFilter.path = @"";
        emptyFilter.intensity = 1.0;
        clear.relatedModel = emptyFilter;
        [filterNode addChild:clear];
        
        for (PLSEffectModel *item in filterArr) {
            BEButtonItemModel *btItem = [BEButtonItemModel new];
            btItem.relatedModel = item;
            btItem.title = item.displayName;
            [filterNode addChild:btItem];
        }
    }
    
    
    self.categories = cat;
    self.categoryView.titles = self.categories;
    
    for (BEEffectCategoryModel *model in self.categories) {
        Class cellClass = [BEEffectContentCollectionViewCellFactory contentCollectionViewCellWithPanelTabType:model.type];
        [self.contentCollectionView registerClass:[cellClass class] forCellWithReuseIdentifier:model.title];
    }
    
    [self.contentCollectionView reloadData];
}

- (void)updateComponent {
    NSMutableArray *components = [NSMutableArray array];
    for (NSDictionary *map in _mapArr) {
        [components addObjectsFromArray:map.allValues];
    }
    [_effectManager updateMakeupComponents:components];
    
    for (PLSMakeUpComponentModel *model in components) {
        [_effectManager updateMakeupComponentIntensity:model.intensity withComponent:model];
    }
}

- (void)updateSelectedEffect {
    [self updateComponent];
    [_effectManager updateFilter:_selectedFilter];
    [_effectManager updateFilterIntensity:_selectedFilter.intensity];
}

- (NSDictionary *)typeInternalKeyMap {
    return @{
        @(PLSMakeUpTypeLip):@"Internal_Makeup_Lips",
        @(PLSMakeUpTypeBlush):@"Internal_Makeup_Blusher",
        @(PLSMakeUpTypeFacial):@"Internal_Makeup_Facial",
        @(PLSMakeUpTypePupil):@"Internal_Makeup_Pupil",
        @(PLSMakeUpTypeHair):@"",
        @(PLSMakeUpTypeEyeshadow):@"Internal_Makeup_Eye",
        @(PLSMakeUpTypeEyebrow):@"Internal_Makeup_Brow"
    };
}

#pragma mark - delegate

- (void)filterPicker:(BEModernFilterPickerView *)pickerView didSelectedFilter:(BEButtonItemModel *)filter {
    if (filter.relatedModel) {
        _selectedItem = filter;
        _selectedFilter = filter.relatedModel;
        [_effectManager updateFilter:_selectedFilter];
        [_effectManager updateFilterIntensity:_selectedFilter.intensity];
        _textSlider.hidden = _selectedFilter.path.length == 0;
        _textSlider.progress = _selectedFilter.intensity;
    }
}

- (void)beautyView:(BEFaceBeautyView *)view didSelectedItem:(BEButtonItemModel *)item index:(int)idx{
    item.parent.selectedIndex = idx;
    if (item.children.count == 0) {
        _selectedItem = item;
        PLSMakeUpComponentModel *model = item.relatedModel;
        NSString *key = @"";
        
        // 染发 key 为空，故跳过获取 key 判断
        if (item.type != PLSMakeUpTypeHair) {
            key = model.internalKey.length > 0 ? model.internalKey : model.path;
        }
       
        NSMutableDictionary *map = _mapArr[_categoryView.switchTabView.selectedIndex];
        if (key) {
            map[key] = item.relatedModel;
        } else {
            [map removeAllObjects];
        }
        [self updateComponent];
        
        _textSlider.hidden = (item.type == PLSMakeUpTypeHair || item.relatedModel == nil);
        _textSlider.progress = ((PLSMakeUpComponentModel *)item.relatedModel).intensity;
        
    } else {
        _selectedListView = view;
        _backItem = item.parent;
        [view setType:item.type data:item];
        
        self.lTitle.text = item.title;
        self.categoryView.switchTabView.hidden = YES;
        self.btnBack.hidden = NO;
        self.lTitle.hidden = NO;
        self.categoryView.contentView.scrollEnabled = NO;
    }
}

#pragma mark - public
- (void)setSliderProgress:(CGFloat)progress {
    self.textSlider.progress = progress;
}

- (void)reloadCollectionViews {
    [self.categoryView selectItemAtIndex:0 animated:NO];
    [self.contentCollectionView reloadData];
    [self.contentCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger )numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    [collectionView.collectionViewLayout invalidateLayout];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    BEEffectCategoryModel *model = self.categories[row];
    BEEffectContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:model.title forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[BEEffectFaceBeautyViewCell class]]) {
        if (((BEEffectFaceBeautyViewCell *)cell).beautyView.type == PLSMakeUpTypeUndefined) {
            BEButtonItemModel *item = _rootNode.children[row];
            [((BEEffectFaceBeautyViewCell *)cell).beautyView setType:model.type data:item];
            ((BEEffectFaceBeautyViewCell *)cell).beautyView.delegate = self;
        }
    }
    
    if ([cell isKindOfClass:[BEEffecFiltersCollectionViewCell class]]) {
        if (((BEEffecFiltersCollectionViewCell *)cell).filterView.filters.count == 0) {
            BEButtonItemModel *item = _rootNode.children[row];
            [((BEEffecFiltersCollectionViewCell *)cell).filterView refreshWithFilters:item.children];
            ((BEEffecFiltersCollectionViewCell *)cell).filterView.delegate = self;
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(UIScreen.mainScreen.bounds.size.width, 135);
}

#pragma mark - BEEffectSwitchTabViewDelegate
- (void)switchTabDidSelectedAtIndex:(NSInteger)index {
    [self.contentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if (touch.view == self.btnNormal) {
//        return YES;
//    }
//    return NO;
//}

#pragma mark - TextSliderViewDelegate
- (void)progressDidChange:(CGFloat)progress {
    if ([_selectedItem.relatedModel isKindOfClass:[PLSEffectModel class]]) {
        ((PLSEffectModel *)_selectedItem.relatedModel).intensity = progress;
        [_effectManager updateFilterIntensity:progress];
    } else if ([_selectedItem.relatedModel isKindOfClass:[PLSMakeUpComponentModel class]]) {
        ((PLSMakeUpComponentModel *)_selectedItem.relatedModel).intensity = progress;
        [_effectManager updateMakeupComponentIntensity:progress withComponent:_selectedItem.relatedModel];
    }
}

#pragma mark - button selector

- (void)onBtnBackTap {
    [_selectedListView setType:_backItem.type data:_backItem];
    _backItem = _backItem.parent;
    if (_backItem.level == 0) {
        _btnBack.hidden = YES;
        _lTitle.hidden = YES;
        _categoryView.switchTabView.hidden = NO;
        _categoryView.contentView.scrollEnabled = YES;
    } else {
        _lTitle.text = _backItem.title;
    }
}

#pragma mark - getter && setter
- (UIView *)vBackground {
    if (!_vBackground) {
        _vBackground = [UIView new];
        _vBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _vBackground;
}

- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
//        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 5);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _contentCollectionView.backgroundColor = [UIColor clearColor];
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        _contentCollectionView.showsVerticalScrollIndicator = NO;
        _contentCollectionView.pagingEnabled = YES;
        _contentCollectionView.dataSource = self;
        _contentCollectionView.delegate = self;
    }
    return _contentCollectionView;
}

- (BECategoryView *)categoryView {
    if (!_categoryView) {
        _categoryView = [BECategoryView new];
        _categoryView.tabDelegate = self;
    }
    return _categoryView;
}

- (NSMutableSet *)registeredCellClass {
    if (!_registeredCellClass) {
        _registeredCellClass = [NSMutableSet set];
    }
    return _registeredCellClass;
}

- (BETextSliderView *)textSlider {
    if (!_textSlider) {
        _textSlider = [BETextSliderView new];
        _textSlider.backgroundColor = [UIColor clearColor];
        _textSlider.lineHeight = 2.5;
        _textSlider.textOffset = 25;
        _textSlider.animationTime = 250;
        _textSlider.delegate = self;
        _textSlider.hidden = YES;
    }
    return _textSlider;
}

- (UIButton *)btnBack {
    if (!_btnBack) {
        _btnBack = [UIButton new];
        [_btnBack setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
        _btnBack.backgroundColor = [UIColor clearColor];
//        _btnBack.alpha = 0;
        _btnBack.hidden = YES;
        _btnBack.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [_btnBack addTarget:self action:@selector(onBtnBackTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnBack;
}

- (UILabel *)lTitle {
    if (!_lTitle) {
        _lTitle = [UILabel new];
        _lTitle.textColor = [UIColor whiteColor];
        _lTitle.font = [UIFont systemFontOfSize:18];
        _lTitle.textAlignment = NSTextAlignmentCenter;
//        _lTitle.alpha = 0;
        _lTitle.hidden = YES;
    }
    return _lTitle;
}

- (BEFaceBeautyView *)makeupOption {
    if (!_makeupOption) {
        _makeupOption = [BEFaceBeautyView new];
    }
    return _makeupOption;
}

@end
