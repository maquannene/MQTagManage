//
//  MQTagManageView.m
//  MQTagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "MQTagManageView.h"

@interface MQTagManageView()

{
  @private
    BOOL _isAnimating;
    NSInteger _selectedItemIndex;
    NSMutableArray *_tagItemsArray;
}

@end

@implementation MQTagManageView

- (void)dealloc {
    [_tagItemsArray release];
    _tagItemsArray = nil;
    [_assistView release];
    _assistView = nil;
    [super dealloc];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self baseConfigure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseConfigure];
    }
    return self;
}

- (void)baseConfigure {
    _tagItemHeight = 44;
    _tagItemWidth = 135;
    self.alwaysBounceHorizontal = YES;
    _tagItemsArray = [[NSMutableArray alloc] init];
}

- (void)setAssistView:(UIView *)assistView {
    if (_assistView != assistView) {
        [_assistView removeFromSuperview];
        [_assistView release];
        _assistView = [assistView retain];
        [self addSubview:self.assistView];
    }
}

- (NSInteger)activeItemIndex {
    if ([self.dataSource respondsToSelector:@selector(activeItemIndex:)]) {
        return [self.dataSource activeItemIndex:self];
    }
    return 0;
}

#pragma mark -
#pragma mark - privite method
- (void)updateAssistViewFrame {
    if (_assistView) {
        NSInteger number = _tagItemsArray.count;
        UIView *lastTagItem = _tagItemsArray[number - 1];
        _assistView.frame = CGRectMake(CGRectGetMaxX(lastTagItem.frame),
                                       0,
                                       CGRectGetWidth(_assistView.frame),
                                       CGRectGetHeight(_assistView.frame));
    }
}

- (CGFloat)getTagItemOriginX:(NSInteger)index {
    CGFloat x = 0;
    for (NSInteger i = 0; i < index; i++) {
        x = x + [self getTagItemWidth:i] + self.gap;
    }
    return x;
}

- (CGFloat)getTagItemWidth:(NSInteger)index {
    if ([_dataSource respondsToSelector:@selector(tagManageView:widthForItemAtIndex:)]) {
        return [_dataSource tagManageView:self widthForItemAtIndex:index];
    }
    return _tagItemWidth;
}

- (CGFloat)getTagItemHeigh:(NSInteger)index {
    if ([_dataSource respondsToSelector:@selector(tagManageView:heightForItemAtIndex:)])
    {
        return [_dataSource tagManageView:self heightForItemAtIndex:index];
    }
    return _tagItemHeight;
}

#pragma mark -
#pragma mark - rewrite method
- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isAnimating) {
        return;
    }
    if (CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        [self reloadTagItems];
    }
}

#pragma mark -
#pragma mark - public method

- (void)reloadTagItems {
    //  reset every tagItem by datasource
    NSInteger number = [self.dataSource numberOfItems:self];
    CGFloat x = 0;
    for (NSInteger index = 0; index < number; index++) {
        UIView *item = [self.dataSource tagManageView:self tagForItemAtIndex:index];
        item.frame = CGRectMake(x,
                                0,
                                [self getTagItemWidth:index],
                                [self getTagItemHeigh:index]);
        x = x + [self getTagItemWidth:index] + self.gap;
        if (!item.superview) {
            [_tagItemsArray addObject:item];
            [self addSubview:item];
        }
    }
    //  remove needless
    if (_tagItemsArray.count > number) {
        NSInteger removeTimes = _tagItemsArray.count - number;
        for (NSInteger i = 0; i < removeTimes; i++) {
            UIView *tagItem = _tagItemsArray.lastObject;
            [tagItem removeFromSuperview];
            [_tagItemsArray removeLastObject];
        }
    }
    // adjust contentSize
    UIView * lastTagItem = _tagItemsArray.lastObject;
    self.contentSize = CGSizeMake(CGRectGetMaxX(lastTagItem.frame) + CGRectGetWidth(self.assistView.frame),
                                  CGRectGetHeight(self.frame));
    
    [self updateAssistViewFrame];
    [self autoAdjustZCoordinate];
}

- (void)autoAdjustZCoordinate {
    for (NSInteger index = self.activeItemIndex - 1; index >= 0 ; index--) {
        UIView *tagItem = (UIView *)_tagItemsArray[index];
        [self sendSubviewToBack:tagItem];
    }
    for (NSInteger index = self.activeItemIndex + 1; index <= _tagItemsArray.count - 1; index++) {
        UIView *tagItem = (UIView *)_tagItemsArray[index];
        [self sendSubviewToBack:tagItem];
    }
}

- (id)dequeueReusableTag:(NSInteger)index {
    if (index >= _tagItemsArray.count) {
        return nil;
    }
    return _tagItemsArray[index];
}

- (NSInteger)indexOfItemAtPoint:(CGPoint)point {
    for (NSInteger index = self.activeItemIndex; index >= 0; index -- ) {
        CGRect frame = [self rectOfItemAtIndex:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return index;
        }
    }
    
    for (NSInteger index = [self activeItemIndex] + 1; index < _tagItemsArray.count; index ++)
    {
        CGRect frame = [self rectOfItemAtIndex:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return index;
        }
    }
    
    return NSNotFound;
}

- (UIView *)tagForItemAtPoint:(CGPoint)point {
    for (NSInteger index = self.activeItemIndex; index >= 0; index -- ) {
        CGRect frame = [self rectOfItemAtIndex:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return (UIView *)_tagItemsArray[index];
        }
    }
    
    for (NSInteger index = self.activeItemIndex + 1; index < _tagItemsArray.count; index ++) {
        CGRect frame = [self rectOfItemAtIndex:index];
        if (CGRectContainsPoint(frame, CGPointMake(point.x, CGRectGetMidY(frame)))) {
            return (UIView *)_tagItemsArray[index];
        }
    }
    
    return nil;
}

- (CGRect)rectOfItemAtIndex:(NSInteger)index {
    return  CGRectMake([self getTagItemOriginX:index],
                       0,
                       [self getTagItemWidth:index],
                       [self getTagItemHeigh:index]);
}

- (UIView *)tagForItemAtIndex:(NSInteger)index {
    return _tagItemsArray[index];
}

- (void)moveItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^)())complete {
    //  this time, tagItemsArray is old dataSource
    UIView *fromTagItem = _tagItemsArray[fromIndex];
    CGRect toRect = CGRectMake([self getTagItemOriginX:toIndex],
                               0,
                               CGRectGetWidth(fromTagItem.frame),
                               CGRectGetHeight(fromTagItem.frame));
    
    [UIView animateWithDuration:0.5 animations:^() {
        _isAnimating = YES;
        fromTagItem.frame = toRect;
        
        //  move back , the origin.x of tagItem which > from and <= to move forward fromTagItem.frame.size.width
        if (fromIndex < toIndex) {
            for (NSInteger index = fromIndex + 1; index <= toIndex ; index++) {
                UIView *tagItem = _tagItemsArray[index];
                tagItem.frame = CGRectMake(tagItem.frame.origin.x - fromTagItem.frame.size.width - self.gap,
                                           tagItem.frame.origin.y,
                                           tagItem.frame.size.width,
                                           tagItem.frame.size.height);
            }
        }
        
        //  move forward , the origin.x of tagItem which >= to and < from move back fromTagItem.frame.size.width
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
        _isAnimating = NO;
    }];
}

- (void)insertItemAtIndex:(NSInteger)index complete:(void (^)())complete {
    CGPoint oldContentOffset = self.contentOffset;
    
    //  create a temp tagItem according to dataSource
    UIView *insertTagItem = [_dataSource tagManageView:self tagForItemAtIndex:index];
    
    //  caculate the frame of insertTagItem according to last tagItem
    insertTagItem.frame = CGRectMake([self getTagItemOriginX:index],
                                     0,
                                     [self getTagItemWidth:index],
                                     [self getTagItemHeigh:index]);
    
    insertTagItem.transform = CGAffineTransformMakeScale(0.01, 1);
    insertTagItem.alpha = 0;
    [self addSubview:insertTagItem];
    [self bringSubviewToFront:insertTagItem];
    
    //set new contentSize
    self.contentSize = CGSizeMake(self.contentSize.width + ([self getTagItemWidth:index] + self.gap),
                                  self.contentSize.height);
    [UIView animateWithDuration:0.5 animations:^(){
        _isAnimating = YES;
        //  every tagItem which behind of insertTagItem move back insertTagItem.width
        [_tagItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop){
            UIView *tagItem = (UIView *)obj;
            if (i >= index) {
                tagItem.frame = CGRectMake(CGRectGetMinX(tagItem.frame) + insertTagItem.frame.size.width + self.gap,
                                           0,
                                           tagItem.frame.size.width,
                                           tagItem.frame.size.height);
            }
        }];
        
        //  caculate assistView.frame
        if (self.assistView) {
            self.assistView.frame = CGRectMake([self getTagItemOriginX:[self.dataSource numberOfItems:self] - 1] + [self getTagItemWidth:[self.dataSource numberOfItems:self] - 1],
                                               0,
                                               CGRectGetWidth(_assistView.frame),
                                               CGRectGetHeight(_assistView.frame));
        }
        
        insertTagItem.transform = CGAffineTransformMakeScale(1, 1);
        insertTagItem.alpha = 1;

        //  caculate contentOffset
        if (self.contentSize.width - self.frame.size.width > 0) {
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
        else{
            self.contentOffset = CGPointMake(0,
                                             oldContentOffset.y);
        }
        
    } completion:^(BOOL finish){
        if (complete) {
            complete();
        }
        [insertTagItem removeFromSuperview];
        [self reloadTagItems];
        _isAnimating = NO;
    }];
}

- (void)deleteItemAtIndex:(NSInteger)index complete:(void (^)())complete {
    
    CGPoint oldContentOffset = self.contentOffset;
    UIView *deleteTagItem = _tagItemsArray[index];
    [self sendSubviewToBack:deleteTagItem];
    
    [UIView animateWithDuration:0.5 animations:^() {
        _isAnimating = YES;
        self.contentSize = CGSizeMake(self.contentSize.width - (deleteTagItem.frame.size.width + self.gap),
                                      self.contentSize.height);
    
        //  every tagItem which behind of deleteTagItem move forward deleteTagItem.width
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
            
            if (index != [self.dataSource numberOfItems:self]) {
                _assistView.frame = CGRectMake(CGRectGetMaxX(lastTagItem.frame),
                                               0,
                                               CGRectGetWidth(_assistView.frame),
                                               CGRectGetWidth(_assistView.frame));
            }
            else {
                _assistView.frame = CGRectMake([self getTagItemOriginX:[self.dataSource numberOfItems:self] - 1] + [self getTagItemWidth:[self.dataSource numberOfItems:self] - 1],
                                               0,
                                               CGRectGetWidth(_assistView.frame),
                                               CGRectGetHeight(_assistView.frame));
            }
        }
        
        deleteTagItem.alpha = 0;
        deleteTagItem.transform = CGAffineTransformMakeScale(0.01, 1);
        
        //  caculate contentOffset
        if (self.contentSize.width - self.frame.size.width > 0) {
            if (oldContentOffset.x <= self.contentSize.width - self.frame.size.width) {
                self.contentOffset = CGPointMake(oldContentOffset.x,
                                                 oldContentOffset.y);
            }
            else {
                self.contentOffset = CGPointMake(self.contentSize.width - self.frame.size.width,
                                                 oldContentOffset.y);
            }
        }
        else {
            self.contentOffset = CGPointMake(0,
                                             oldContentOffset.y);
        }
        
    } completion:^(BOOL finish){
        deleteTagItem.alpha = 1;
        deleteTagItem.transform = CGAffineTransformMakeScale(1, 1);
        if (complete) {
            complete();
        }
        [self reloadTagItems];
        _isAnimating = NO;
    }];
}

@end
