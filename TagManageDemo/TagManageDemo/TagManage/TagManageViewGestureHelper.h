//
//  TagManageViewGestureHelper.h
//  TagManageDemo
//
//  Created by 马权 on 3/13/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TagManageAutoScrollDir) {
    TagManageAutoScrollLeft,
    TagManageAutoScrollRight,
    TagManageAutoScrollStop
};

@class TagManageView;
@protocol TagManageViewDelegate;

@protocol TagManageViewGestureHelperDelegate <TagManageViewDelegate>

@optional
- (void)tagManageView:(TagManageView *)tagManageView didSelectTagItemAtIndex:(NSInteger)index;
- (void)tagManageView:(TagManageView *)tagManageView didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@interface TagManageViewGestureHelper : NSObject

@property (assign, nonatomic) BOOL helperEnable;                                            //  default:NO
@property (retain, nonatomic, readonly) UITapGestureRecognizer *tapGesture;
@property (retain, nonatomic, readonly) UILongPressGestureRecognizer *longPressGesture;

- (instancetype)initWithTagManageView:(TagManageView *)tagManageView;

@end
