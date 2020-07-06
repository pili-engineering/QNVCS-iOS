// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>

#import "PLSTBaseListView.h"

@class PLSEffectModel, BEModernStickerPickerView;
@protocol BEModernStickerPickerViewDelegate <NSObject>

- (void)stickerPicker:(BEModernStickerPickerView*)pickerView didSelectSticker:(PLSEffectModel *)sticker;

@end

@interface BEModernStickerPickerView : PLSTBaseListView

@property (nonatomic, weak) id<BEModernStickerPickerViewDelegate> delegate;
@property (nonatomic, weak) PLSEffectModel *selectedSticker;

- (void)refreshWithStickers:(NSArray<PLSEffectModel *> *) stickers;
@end
