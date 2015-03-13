//
//  TagManageView.h
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagManageView;

@protocol TagManageViewDataSource<NSObject>

@required

- (NSInteger)activeItemIndex:(TagManageView *)tagManageView;

- (NSInteger)numberOfItems:(TagManageView *)tagManageView;

- (UIView *)tagManageView:(TagManageView *)tagManageView tagForItemAtIndex:(NSInteger)index;

- (CGFloat)tagManageView:(TagManageView *)tagManageView heightForItemAtIndex:(NSInteger)index;

- (CGFloat)tagManageView:(TagManageView *)tagManageView widthForItemAtIndex:(NSInteger)index;

@end

@protocol TagManageViewDelegate<UIScrollViewDelegate>

@end

@interface TagManageView : UIScrollView

@property (nonatomic, assign) id<TagManageViewDataSource> dataSource;
@property (nonatomic, assign) id<TagManageViewDelegate> delegate;
@property (nonatomic, retain) UIView *assistView;                       //  assistView behind of last tagItem
@property (nonatomic, assign) NSInteger gap;                            //  gap of between tagItem

- (void)reloadTagItems;
- (void)autoAdjustZCoordinate;

- (CGRect)rectOfItemAtIndex:(NSInteger)index;
- (NSInteger)indexOfItemAtPoint:(CGPoint)point;
- (UIView *)tagForItemAtPoint:(CGPoint)point;
- (UIView *)tagForItemAtIndex:(NSInteger)index;

/*insert, delete（hide, move*/
- (void)insertItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
- (void)deleteItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
- (void)moveItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^) ())complete;

@end