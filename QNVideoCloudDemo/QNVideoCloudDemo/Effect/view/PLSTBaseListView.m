//
//  PLSTBaseListView.m
//  PLShortVideoKitDemo
//
//  Created by 李政勇 on 2020/6/22.
//  Copyright © 2020 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLSTBaseListView.h"


@interface PLSTBaseListView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation PLSTBaseListView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.animationDuration = 0.2;
    self.animationType = PLSTListAnimationTypeFromBottom;
    [self addGesture];
}

- (void)addGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hid)];
    tap.delegate = self;
    tap.enabled = !self.disableGesture;
    [self addGestureRecognizer:tap];
    self.tap = tap;
}

- (void)setDisableGesture:(BOOL)disableGesture{
    _disableGesture = disableGesture;
    self.tap.enabled = !disableGesture;
}

- (void)showInView:(UIView *)view{
    if (view == nil) {
        return;
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
    self.alpha = 0;
    self.frame = view.bounds;
    [view addSubview:self];
    [self layoutIfNeeded];
    
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;

    [self willShow:_animationDuration distance:height];
    switch (self.animationType) {
        case PLSTListAnimationTypeFade:
        {
            self.contentView.bounds = CGRectMake(0, 0, width, height);
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.alpha = 1.0;
            }];
            break;
        }
        case PLSTListAnimationTypeFromTop:
        {
            self.contentView.bounds = CGRectMake(0, height, width, height);
            self.alpha = 1.0;
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.contentView.bounds = CGRectMake(0, 0, width, height);
            }];
            break;
        }
        case PLSTListAnimationTypeFromBottom:
        {
            self.contentView.bounds = CGRectMake(0, -height, width, height);
            self.alpha = 1.0;
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.contentView.bounds = CGRectMake(0, 0, width, height);
            }];
            break;
        }
        default:
        {
            self.alpha = 1.0;
            break;
        }
    }
}

- (void)willShow:(NSTimeInterval)duration distance:(CGFloat)distance{
    if (self.willShow) {
        self.willShow(self,duration, distance);
    }
}

- (void)willHid:(NSTimeInterval)duration distance:(CGFloat)distance{
    if (self.willHid) {
        self.willHid(self,duration, distance);
    }
}

- (void)didhidden{
    self.tap.enabled = !_disableGesture;
}

- (void)hid{
    self.tap.enabled = NO;
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;
    
    self.alpha = 1.0;
    self.contentView.bounds = CGRectMake(0, 0, width, height);
    
    [self willHid:_animationDuration distance:height];
    switch (self.animationType) {
        case PLSTListAnimationTypeFade:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                [self didhidden];
            }];
            break;
        }
        case PLSTListAnimationTypeFromTop:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.contentView.bounds = CGRectMake(0, height, width, height);
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                [self didhidden];
            }];
            break;
        }
        case PLSTListAnimationTypeFromBottom:
        {
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.contentView.bounds = CGRectMake(0, -height, width, height);
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                [self didhidden];
            }];
            break;
        }
        default:
        {
            self.alpha = 1.0;
            [self removeFromSuperview];
            break;
        }
    }
}

#pragma mark -GestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view == self) {
        return YES;
    }
    return NO;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.gestureIgnoreRect, point)) {
        return NO;
    }
    return YES;
}

@end
