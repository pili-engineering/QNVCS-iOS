//
//  AEPModel.h
//  AEPDemo
//
//  Created by 李政勇 on 2020/3/4.
//  Copyright © 2020 Hermes. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNVCListModel : NSObject

@property(nonatomic, assign) Class cls;
@property(nonatomic, copy) NSString* title;

- (instancetype)initWith:(Class)cls title:(NSString*)title;

@end

NS_ASSUME_NONNULL_END
