//
//  AEPModel.m
//  AEPDemo
//
//  Created by 李政勇 on 2020/3/4.
//  Copyright © 2020 Hermes. All rights reserved.
//

#import "QNVCListModel.h"

@implementation QNVCListModel

- (instancetype)initWith:(Class)cls title:(NSString *)title {
    if (self = [super init]) {
        _cls = cls;
        _title = title;
    }
    return self;
}

@end
