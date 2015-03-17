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

@optional
- (CGFloat)tagManageView:(TagManageView *)tagManageView heightForItemAtIndex:(NSInteger)index;

- (CGFloat)tagManageView:(TagManageView *)tagManageView widthForItemAtIndex:(NSInteger)index;

@end

@protocol TagManageViewDelegate<UIScrollViewDelegate>

@end

@interface TagManageView : UIScrollView

@property (assign, nonatomic) id<TagManageViewDataSource> dataSource;
@property (assign, nonatomic) id<TagManageViewDelegate> delegate;
@property (retain, nonatomic) UIView *assistView;                       //  assistView behind of last tagItem.
@property (assign, nonatomic) NSInteger gap;                            //  gap of between tagItem. default:0
@property (assign, nonatomic) NSInteger tagItemHeight;                  //  default:44
@property (assign, nonatomic) NSInteger tagItemWidth;                   //  default:135

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