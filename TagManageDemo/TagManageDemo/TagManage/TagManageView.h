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

- (NSInteger)activeTagIndex:(TagManageView *)tagManageView;

- (NSInteger)numberOfItems:(TagManageView *)tagManageView;

- (UIView *)tagManageView:(TagManageView *)tagManageView tagForItemAtIndex:(NSInteger)index;

- (CGFloat)tagManageView:(TagManageView *)tagManageView heightForTagItemAtIndex:(NSInteger)index;

- (CGFloat)tagManageView:(TagManageView *)tagManageView widthForTagItemAtIndex:(NSInteger)index;

@end

@protocol TagManageViewDelegate<UIScrollViewDelegate>

@end

@interface TagManageView : UIScrollView

@property (nonatomic, assign) id<TagManageViewDataSource> dataSource;
@property (nonatomic, assign) id<TagManageViewDelegate> delegate;
@property (nonatomic, retain) UIView *assistView;                                       //  辅助view。 可以自己定制功能。
@property (nonatomic, assign) NSInteger gap;                                            //  每个tagItem之间的间隔。 可以支持负数值叠加。

- (void)reloadTagItems;
- (void)autoAdjustZIndex;

- (CGRect)rectOfItemAtIndex:(NSInteger)index;
- (NSInteger)indexOfItemAtPoint:(CGPoint)point;
- (UIView *)tagForItemAtPoint:(CGPoint)point;
- (UIView *)tagForItemAtIndex:(NSInteger)index;

/*插入，删除（隐藏），移动*/
- (void)insertTagItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
- (void)deleteTagItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
- (void)moveTagItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^) ())complete;

@end