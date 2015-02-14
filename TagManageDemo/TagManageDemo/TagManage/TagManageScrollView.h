//
//  TagManageScrollView.h
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagManageScrollView;

@protocol  TagManageScrollViewDataSource<NSObject>

@required
- (NSInteger)numberOfVisiableTags;

- (UIView *)tagItemAtIndex:(NSInteger)index;

- (CGFloat)tagManage:(TagManageScrollView *)tagManage heightForTagItemAtIndex:(NSInteger)index;

- (CGFloat)tagManage:(TagManageScrollView *)tagManage widthForTagItemAtIndex:(NSInteger)index;

- (NSInteger)getActiveTagIndex;

@end

@protocol TagManageScrollViewDelegate<UIScrollViewDelegate>

@end

@interface TagManageScrollView : UIScrollView

@property (nonatomic, assign) id<TagManageScrollViewDataSource> dataSource;
@property (nonatomic, assign) id<TagManageScrollViewDelegate> delegate;
@property (nonatomic, retain) UIView *assistView;                                       //  辅助view。 可以自己定制功能。
@property (nonatomic, assign) NSInteger gap;                                            //  每个tagItem之间的间隔。 可以支持负数值叠加。

- (void)reloadTagItems;

/**
 *  自动调整z轴
 */
- (void)autoAdjustZIndex;

/**
 *  通过传入index获取相应tagItem的坐标
 *
 *  @param 界面index
 *
 *  @return 返回tagItem的Rect
 */
- (CGRect)getTagItemRect:(NSInteger)index;

/**
 *  通过坐标，找出相应的tagItemIndex
 *
 *  @param point 传入的坐标
 *
 *  @return 返回相应的界面tagItemIndex;
 */
- (NSInteger)findTagItemIndex:(CGPoint )point;

/**
 *  通过坐标，找到相应的tagItem
 *
 *  @param point 传入坐标
 *
 *  @return 返回相应的tagItem
 */
- (UIView *)findTagItem:(CGPoint)point;

/**
 *  通过传入界面index 获取tagItem
 *
 *  @param index 界面tagIndex
 *
 *  @return 返回相应的界面tagItem
 */
- (UIView *)tagItemAtIndex:(NSInteger)index;

/**
 *  插入操作，可支持任何位置的插入
 *
 *  @param index    界面index
 *  @param complete 插入成功后执行的block
 */
- (void)insertTagItemAtIndex:(NSInteger)index complete:(void (^) ())complete;

/**
 *  删除操作，可支持任何位置的删除. 隐藏也可以用这个api代替
 *
 *  @param index    界面index
 *  @param complete 删除成功后执行的block
 */

- (void)deleteTagItemAtIndex:(NSInteger)index complete:(void (^) ())complete;

/**
 *  移动移动操作，相邻两个的交换移动
 *
 *  @param fromIndex 从哪个index
 *  @param toIndex   到哪个index
 *  @param complete  移动成功后执行的block
 */
- (void)moveTagItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^) ())complete;

@end