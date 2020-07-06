//
//  PLSTBaseListView.h
//  PLShortVideoKitDemo
//
//  Created by 李政勇 on 2020/6/22.
//  Copyright © 2020 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PLSTListAnimationType) {
    PLSTListAnimationTypeNone,
    PLSTListAnimationTypeFromBottom,
    PLSTListAnimationTypeFromTop,
    PLSTListAnimationTypeFade
};

@interface PLSTBaseListView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *contentBackgroundView;

@property (nonatomic, assign) PLSTListAnimationType animationType;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL disableGesture;
@property (nonatomic, assign) CGRect gestureIgnoreRect;

@property (nonatomic, copy) void(^willShow)(PLSTBaseListView *panel,NSTimeInterval animationDuration,CGFloat distance);
@property (nonatomic, copy) void(^willHid)(PLSTBaseListView *panel,NSTimeInterval animationDuration,CGFloat distance);

- (void)showInView:(UIView *)view;
- (void)hid;

@end

NS_ASSUME_NONNULL_END
