//
//  MQTagManageView.h
//  MQTagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MQTagManageView;

@protocol MQTagManageViewDataSource<NSObject>

@required

- (NSInteger)activeItemIndex:(MQTagManageView *)tagManageView;

- (NSInteger)numberOfItems:(MQTagManageView *)tagManageView;

- (UIView *)tagManageView:(MQTagManageView *)tagManageView tagForItemAtIndex:(NSInteger)index;

@optional
- (CGFloat)tagManageView:(MQTagManageView *)tagManageView heightForItemAtIndex:(NSInteger)index;

- (CGFloat)tagManageView:(MQTagManageView *)tagManageView widthForItemAtIndex:(NSInteger)index;

@end

@protocol MQTagManageViewDelegate<UIScrollViewDelegate>

@end

@interface MQTagManageView : UIScrollView

@property (nonatomic, assign) id<MQTagManageViewDataSource> dataSource;
@property (nonatomic, assign) id<MQTagManageViewDelegate> tagManageDelegate;
@property (nonatomic, retain) UIView *assistView;                       //  assistView behind of last tagItem.
@property (nonatomic, assign) NSInteger gap;                            //  gap of between tagItem. default:0
@property (nonatomic, assign) NSInteger tagItemHeight;                  //  default:44
@property (nonatomic, assign) NSInteger tagItemWidth;                   //  default:135

- (void)reloadTagItems;
- (void)autoAdjustZCoordinate;
- (id)dequeueReusableTag:(NSInteger)index;

- (CGRect)rectOfItemAtIndex:(NSInteger)index;
- (NSInteger)indexOfItemAtPoint:(CGPoint)point;
- (UIView *)tagForItemAtPoint:(CGPoint)point;
- (UIView *)tagForItemAtIndex:(NSInteger)index;

/*insert, delete（hide, move)*/
- (void)insertItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
- (void)deleteItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
- (void)moveItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^) ())complete;

@end