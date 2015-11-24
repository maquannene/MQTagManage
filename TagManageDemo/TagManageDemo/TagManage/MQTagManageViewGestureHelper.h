//
//  MQTagManageViewGestureHelper.h
//  MQTagManageDemo
//
//  Created by 马权 on 3/13/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MQTagManageAutoScrollDir) {
    MQTagManageAutoScrollLeft,
    MQTagManageAutoScrollRight,
    MQTagManageAutoScrollStop
};

@class MQTagManageView;
@protocol MQTagManageViewDelegate;

@protocol MQTagManageViewGestureHelperDelegate <MQTagManageViewDelegate>

@optional
- (void)tagManageView:(MQTagManageView *)tagManageView didSelectTagItemAtIndex:(NSInteger)index;
- (void)tagManageView:(MQTagManageView *)tagManageView willMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)tagManageView:(MQTagManageView *)tagManageView didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@interface MQTagManageViewGestureHelper : NSObject

@property (nonatomic, assign) BOOL helperEnable;                                            //  default:NO
@property (nonatomic, retain, readonly) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain, readonly) UILongPressGestureRecognizer *longPressGesture;

- (instancetype)initWithTagManageView:(MQTagManageView *)tagManageView;

@end
