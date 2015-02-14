//
//  TagManageScrollView.m
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "TagManageScrollView.h"

@interface TagManageScrollView()

@property (nonatomic, retain) NSMutableArray *tagItemsArray;
//@property (nonatomic, assign) BOOL isMoveToEnd;

@end

@implementation TagManageScrollView

- (void)dealloc {
    [_tagItemsArray release];
    _tagItemsArray = nil;
    [_assistView release];
    _assistView = nil;
    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceHorizontal = YES;
        _tagItemsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 *  assistView的set方法，如果设置assistView，就先移除原有的，再加上来。
 *
 *  @param assistView 传入的assistView
 */
- (void)setAssistView:(UIView *)assistView {
    if (_assistView != assistView) {
        [_assistView removeFromSuperview];
        [_assistView release];
        _assistView = [assistView retain];
        [self addSubview:self.assistView];
    }
}

/**
 *  获取topIndex,用代理设置，就用代理的值，否则就用属性值
 *
 *  @return topIndex
 */
- (NSInteger)topIndex {
    if ([self.dataSource respondsToSelector:@selector(getActiveTagIndex)]) {
        return [self.dataSource getActiveTagIndex];
    }
    return 0;
}

#pragma mark -
#pragma mark - 对内方法
/**
 *  更新assistView的frame
 */
- (void)updateAssistViewFrame {
    if (_assistView) {
        NSInteger number = [self.dataSource numberOfVisiableTags];
        UIView *lastTagItem = _tagItemsArray[number - 1];
        _assistView.frame = CGRectMake(CGRectGetMaxX(lastTagItem.frame),
                                       0,
                                       CGRectGetWidth(_assistView.frame),
                                       CGRectGetHeight(_assistView.frame));
    }
}

/**
 *  清理sheetItem数组
 */
- (void)cleanTagItemsArray {
    [_tagItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *tagItem = obj;
        [tagItem removeFromSuperview];
//        tagItem = nil;
    }];
}

/**
 *  获取每个index 的x
 *
 *  @param index item对应的index
 *
 *  @return x位置
 */
- (CGFloat)getTagItemOriginX:(NSInteger)index
{
    CGFloat x = 0;
    for (NSInteger i = 0; i < index; i++) {
        x = x + [self getTagItemWidth:i] + self.gap;
    }
    return x;
}

- (CGFloat)getTagItemWidth:(NSInteger)index
{
    if ([_dataSource respondsToSelector:@selector(tagManage:widthForTagItemAtIndex:)]) {
        return [_dataSource tagManage:self widthForTagItemAtIndex:index];
    }
    return 0;
}

- (CGFloat)getTagItemHeigh:(NSInteger)index
{
    if ([_dataSource respondsToSelector:@selector(tagManage:heightForTagItemAtIndex:)])
    {
        return [_dataSource tagManage:self heightForTagItemAtIndex:index];
    }
    return 0;
}

#pragma mark -
#pragma mark - 对外接口

- (void)reloadTagItems {
    
    //  首先清理原有所有的sheetItems
    if (_tagItemsArray.count) {
        [self cleanTagItemsArray];
        [_tagItemsArray removeAllObjects];
    }
    
    //  重新加入每个sheetItem
    NSInteger number = [self.dataSource numberOfVisiableTags];
    for (NSInteger index = 0; index < number; index++) {
        UIView *item = [self.dataSource tagItemAtIndex:index];
        item.frame = CGRectMake([self getTagItemOriginX:index], 0, [self getTagItemWidth:index], [self getTagItemHeigh:index]);
        [_tagItemsArray addObject:item];
        [self addSubview:item];
    }
    
    //  更新assistView的frame
    [self updateAssistViewFrame];
    
    self.contentSize = CGSizeMake([self getTagItemOriginX:number - 1] + [self getTagItemWidth:number - 1] + CGRectGetWidth(self.assistView.frame),
                                  CGRectGetHeight(self.frame));
    //  调整Z坐标
    [self autoAdjustZIndex];
}

- (void)autoAdjustZIndex
{
    
    [_tagItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        UIView *tagItem = obj;
        tagItem.frame = CGRectMake([self getTagItemOriginX:index],
                                   0,
                                   [self getTagItemWidth:index],
                                   [self getTagItemHeigh:index]);
    }];
    
    for (NSInteger index = self.topIndex - 1; index >= 0 ; index--) {
        UIView *tagItem = (UIView *)_tagItemsArray[index];
        [self sendSubviewToBack:tagItem];
    }
    for (NSInteger index = self.topIndex + 1; index <= _tagItemsArray.count - 1; index++) {
        UIView *tagItem = (UIView *)_tagItemsArray[index];
        [self sendSubviewToBack:tagItem];
    }
}

- (NSInteger)findTagItemIndex:(CGPoint )point
{
    for (NSInteger index = self.topIndex; index >= 0; index -- ) {
        CGRect frame = [self getTagItemRect:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return index;
        }
    }
    
    for (NSInteger index = [self topIndex] + 1; index < [self.dataSource numberOfVisiableTags]; index ++)
    {
        CGRect frame = [self getTagItemRect:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return index;
        }
    }
    
    return -1;
}

- (UIView *)findTagItem:(CGPoint)point
{
    for (NSInteger index = self.topIndex; index >= 0; index -- ) {
        CGRect frame = [self getTagItemRect:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return (UIView *)_tagItemsArray[index];
        }
    }
    
    for (NSInteger index = self.topIndex + 1; index < [self.dataSource numberOfVisiableTags]; index ++) {
        CGRect frame = [self getTagItemRect:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return (UIView *)_tagItemsArray[index];
        }
    }
    
    return nil;
}

- (CGRect)getTagItemRect:(NSInteger)index
{
    return  CGRectMake([self getTagItemOriginX:index],
                       0,
                       [self getTagItemWidth:index],
                       [self getTagItemHeigh:index]);
}

- (UIView *)tagItemAtIndex:(NSInteger)index
{
    return _tagItemsArray[index];
}

- (void)moveTagItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^)())complete{
    
    //  此时，界面items 还是旧的，没有更新。
    UIView *fromTagItem = _tagItemsArray[fromIndex];
    CGRect toRect = CGRectMake([self getTagItemOriginX:toIndex],
                               0,
                               CGRectGetWidth(fromTagItem.frame),
                               CGRectGetHeight(fromTagItem.frame));
    
    [UIView animateWithDuration:0.5 animations:^(){
        
        fromTagItem.frame = toRect;
        
        //  前向后移动，大于from 和 小与等于 to 的tagItem x 坐标向前移动fromTagItem.frame.size.width个距离
        if (fromIndex < toIndex) {
            for (NSInteger index = fromIndex + 1; index <= toIndex ; index++) {
                UIView *tagItem = _tagItemsArray[index];
                tagItem.frame = CGRectMake(tagItem.frame.origin.x - fromTagItem.frame.size.width - self.gap,
                                           tagItem.frame.origin.y,
                                           tagItem.frame.size.width,
                                           tagItem.frame.size.height);
            }
        }
        
        // 后向前移动，大于等于to 和 小与 from 的tagItem x 坐标向后移动fromTagItem.frame.size.width个距离
        if (fromIndex > toIndex) {
            for (NSInteger index = fromIndex - 1; index >= toIndex; index--) {
                UIView *tagItem = _tagItemsArray[index];
                tagItem.frame = CGRectMake(tagItem.frame.origin.x + fromTagItem.frame.size.width + self.gap,
                                           tagItem.frame.origin.y,
                                           tagItem.frame.size.width,
                                           tagItem.frame.size.height);
            }
        }
        
        UIView *_fromTagItem = [_tagItemsArray[fromIndex] retain];
        [_tagItemsArray removeObjectAtIndex:fromIndex];
        [_tagItemsArray insertObject:_fromTagItem atIndex:toIndex];
        [_fromTagItem release];
        
    } completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
    }];
}

- (void)insertTagItemAtIndex:(NSInteger)index complete:(void (^) ())complete
{
    CGPoint oldContentOffset = self.contentOffset;
    
    //  根据数据，创建一个临时的insertTagItem
    UIView *insertTagItem = [_dataSource tagItemAtIndex:index];
    
    //  通过新增位置的前一个item计算出新增insertSheetItem 出现的位置
    insertTagItem.frame = CGRectMake([self getTagItemOriginX:index],
                                     0,
                                     [self getTagItemWidth:index],
                                     [self getTagItemHeigh:index]);
    
    insertTagItem.transform = CGAffineTransformMakeScale(0.2, 0.2);
    insertTagItem.alpha = 0;
    [self addSubview:insertTagItem];
    [self bringSubviewToFront:insertTagItem];
    
    //设置增加之后的 contentSize
    self.contentSize = CGSizeMake(self.contentSize.width + ([self getTagItemWidth:index] + self.gap),
                                  self.contentSize.height);
    [UIView animateWithDuration:0.5 animations:^(){
        
        //  将增加位置之后的每个item 向后移一个新增的位置，宽高 保持
        [_tagItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop){
            UIView *tagItem = (UIView *)obj;
            if (i >= index) {
                tagItem.frame = CGRectMake(CGRectGetMinX(tagItem.frame) + insertTagItem.frame.size.width + self.gap,
                                           0,
                                           tagItem.frame.size.width,
                                           tagItem.frame.size.height);
            }
        }];
        
        //  这里设置assistView 位置是 数据源已经增加sheetItem后add的位置
        //  所以只要计算最后一个item的 x 加上 宽度即可
        if (self.assistView)
        {
            self.assistView.frame = CGRectMake([self getTagItemOriginX:[self.dataSource numberOfVisiableTags] - 1] + [self getTagItemWidth:[self.dataSource numberOfVisiableTags] - 1],
                                               0,
                                               CGRectGetWidth(_assistView.frame),
                                               CGRectGetHeight(_assistView.frame));
        }
        
        //  新增sheet的最终形态设置
        insertTagItem.transform = CGAffineTransformMakeScale(1, 1);
        insertTagItem.alpha = 1;
        
        //  调整scrollview 的最终offset
        //  如果可滑动
        if (self.contentSize.width - self.frame.size.width > 0)
        {
            //  新加sheetItem时，offset.x 也要加入相应的长度，
            //  如果加上长度后，没有超过最大offset,就可以直接设置，否则设置最大offset.x
            if (oldContentOffset.x + [self getTagItemWidth:index] + self.gap <= self.contentSize.width - self.frame.size.width) {
                self.contentOffset = CGPointMake(oldContentOffset.x + [self getTagItemWidth:index] + self.gap,
                                                 oldContentOffset.y);
            }
            else{
                self.contentOffset = CGPointMake(self.contentSize.width - self.frame.size.width,
                                                 oldContentOffset.y);
            }
        }
        //  如果不可滑动，offset的 x 为0
        else{
            self.contentOffset = CGPointMake(0,
                                             oldContentOffset.y);
        }
        
    } completion:^(BOOL finish){
        if (complete) {
            complete();
        }
        [insertTagItem removeFromSuperview];
    }];
}

- (void)deleteTagItemAtIndex:(NSInteger)index complete:(void (^)())complete {
    
    CGPoint oldContentOffset = self.contentOffset;
    //  拿到删除的deleteTagItem
    UIView *deleteTagItem = _tagItemsArray[index];
    [self sendSubviewToBack:deleteTagItem];
    
    [UIView animateWithDuration:0.5 animations:^(){
        self.contentSize = CGSizeMake(self.contentSize.width - (deleteTagItem.frame.size.width + self.gap),
                                      self.contentSize.height);
        
        //  将删除的item 之后的每个item 位置向前移一个删除item的长度*注意删除长度 可长  可短*， 宽高保持
        [_tagItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop){
            UIView *tagItem = (UIView *)obj;
            if (i > index) {
                tagItem.frame = CGRectMake(CGRectGetMinX(tagItem.frame) - deleteTagItem.frame.size.width - self.gap,
                                           0,
                                           tagItem.frame.size.width,
                                           tagItem.frame.size.height);
            }
        }];
        
        UIView *lastTagItem = [_tagItemsArray lastObject];
        //  这时设置的位置，是数据源已经删除item后，前移add的位置
        //  所以只要计算最后一个item的 x 加上 宽度即可
        if (self.assistView) {
            
            if (index != [self.dataSource numberOfVisiableTags]) {
                _assistView.frame = CGRectMake(CGRectGetMaxX(lastTagItem.frame),
                                               0,
                                               CGRectGetWidth(_assistView.frame),
                                               CGRectGetWidth(_assistView.frame));
            }
            else {
                _assistView.frame = CGRectMake([self getTagItemOriginX:[self.dataSource numberOfVisiableTags] - 1] + [self getTagItemWidth:[self.dataSource numberOfVisiableTags] - 1],
                                               0,
                                               CGRectGetWidth(_assistView.frame),
                                               CGRectGetHeight(_assistView.frame));
            }
        }
        
        //  设置deleteSheetItem 消失的形态
        deleteTagItem.alpha = 0;
        deleteTagItem.transform = CGAffineTransformMakeScale(0.01, 0.01);
        
        //  调整scrollview 的最终offset
        if (self.contentSize.width - self.frame.size.width > 0) {
            if (oldContentOffset.x <= self.contentSize.width - self.frame.size.width) {
                self.contentOffset = CGPointMake(oldContentOffset.x,
                                                 oldContentOffset.y);
            }
            else {
                self.contentOffset = CGPointMake(self.contentSize.width - self.frame.size.width,
                                                 oldContentOffset.y);
//                _isMoveToEnd = YES;
            }
        }
        else {
            self.contentOffset = CGPointMake(0,
                                             oldContentOffset.y);
        }
        
    } completion:^(BOOL finish){
        if (complete)
        {
            complete();
        }
        
        //  不同长度的处理，这里太挫了
//        if (_isMoveToEnd)
//        {
//            if (self.contentOffset.x + self.assistView.frame.size.width <= self.contentSize.width - self.frame.size.width) {
//                self.contentOffset = CGPointMake(self.contentOffset.x + self.assistView.frame.size.width,
//                                                 self.contentOffset.y);
//            }
//            _isMoveToEnd = NO;
//        }
    }];
}

@end
