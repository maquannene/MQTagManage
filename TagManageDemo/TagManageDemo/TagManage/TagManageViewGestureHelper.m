//
//  TagManageViewGestureHelper.m
//  TagManageDemo
//
//  Created by 马权 on 3/13/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "TagManageViewGestureHelper.h"
#import "TagManageView.h"

@interface TagManageViewGestureHelper() <UIGestureRecognizerDelegate>

{
    TagManageView *mTagManageView;
    
    TagManageAutoScrollDir autoScrollDir;
    UIView *longPressTag;                               //  记录长按的tag
    NSInteger moveFromIndex;
    NSInteger currentLongPressIndex;
    NSInteger currentActiveIndex;
}

@property (retain, nonatomic) UIImageView *mTempMoveTag;
@property (retain, nonatomic) NSTimer *autoMoveTimeer;

@end

@implementation TagManageViewGestureHelper

- (void)dealloc {
    [_mTempMoveTag release];
    _mTempMoveTag = nil;
    [_autoMoveTimeer release];
    _autoMoveTimeer = nil;
    [_tapGesture release];
    _tapGesture = nil;
    [super dealloc];
}

- (instancetype)initWithTagManageView:(TagManageView *)tagManageView {
    self = [super init];
    if (self) {
        mTagManageView = tagManageView;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(tagManageViewTap:)];
        _tapGesture.delegate = self;
        _tapGesture.numberOfTapsRequired = 1;
        [mTagManageView addGestureRecognizer:_tapGesture];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tagManageViewLongPress:)];
        [mTagManageView addGestureRecognizer:_longPressGesture];
        
    }
    return self;
}

- (void)setHelperEnable:(BOOL)helperEnable {
    _helperEnable = helperEnable;
    _tapGesture.enabled = helperEnable;
    _longPressGesture.enabled = helperEnable;
}

#pragma mark -
#pragma mark - GestureAction
- (void)tagManageViewTap:(UITapGestureRecognizer *)gesture  {
    if ([mTagManageView.delegate conformsToProtocol:@protocol(TagManageViewGestureHelperDelegate)]) {
        if ([mTagManageView.delegate respondsToSelector:@selector(tagManageView:didSelectTagItemAtIndex:)]) {
            NSInteger tapIndex = [mTagManageView indexOfItemAtPoint:[gesture locationInView:mTagManageView]];
            if (tapIndex >= 0) {
                [(id<TagManageViewGestureHelperDelegate>)mTagManageView.delegate tagManageView:mTagManageView didSelectTagItemAtIndex:tapIndex];
            }
        }
    }
}

- (void)tagManageViewLongPress:(UILongPressGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:mTagManageView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //  记录长按起始位置
        NSInteger longPressIndex = [mTagManageView indexOfItemAtPoint:touchPoint];
        
        //  如果没有点击到tag,或者点击超范围 容错处理。
        if (longPressTag < 0 || touchPoint.x > mTagManageView.contentSize.width) {
            return;
        }
        
        currentLongPressIndex = longPressIndex;
        moveFromIndex = longPressIndex;
        
        
        longPressTag = [mTagManageView tagForItemAtIndex:longPressIndex];
        //  显示临时view 跟着手指移动
        self.mTempMoveTag = [[[UIImageView alloc] initWithFrame:longPressTag.frame] autorelease];
        _mTempMoveTag.image = [self imageFromItem:longPressTag];
        _mTempMoveTag.alpha = .8;
        [mTagManageView addSubview:_mTempMoveTag];
        //  长按的tag要隐藏
        longPressTag.hidden = YES;
        
        //  一旦长按，要开启自动滚动timer
        [self startAutoScrollTimer];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        //  容错处理
        if (touchPoint.x > mTagManageView.contentSize.width) {
            return;
        }
        
        _mTempMoveTag.center = CGPointMake(touchPoint.x, CGRectGetMidY(_mTempMoveTag.frame));
        
        [self exchangeIfNeeded];
        
        // 自动滚动判断
        //如果触及左边自动滚动区
        if (touchPoint.x - mTagManageView.contentOffset.x <= 50 &&
            touchPoint.x - mTagManageView.contentOffset.x >= 0)
        {
            autoScrollDir = TagManageAutoScrollRight;
        }
        //如果触及右边自动滚动区
        else if (touchPoint.x - mTagManageView.contentOffset.x >= mTagManageView.frame.size.width - 50 &&
                 touchPoint.x - mTagManageView.contentOffset.x <= mTagManageView.frame.size.width)
        {
            autoScrollDir = TagManageAutoScrollLeft;
        }
        else
        {
            autoScrollDir = TagManageAutoScrollStop;
        }
    }
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed) {
        
        //  容错，如果长按没有点击提到tag，结束时什么也不用做。
        if (!_mTempMoveTag) {
            return;
        }
        
        [UIView animateWithDuration:.4 animations:^{
            _mTempMoveTag.frame = longPressTag.frame;
        } completion:^(BOOL finished) {
            longPressTag.hidden = NO;
            [_mTempMoveTag removeFromSuperview];
            
            //  didMove delegate
            if ([mTagManageView.delegate conformsToProtocol:@protocol(TagManageViewGestureHelperDelegate)]) {
                if ([mTagManageView.delegate respondsToSelector:@selector(tagManageView:didMoveItemFromIndex:toIndex:)]) {
                    [(id<TagManageViewGestureHelperDelegate>)mTagManageView.delegate tagManageView:mTagManageView didMoveItemFromIndex:moveFromIndex toIndex:currentLongPressIndex];
                }
            }
            
            if (moveFromIndex != currentLongPressIndex) {
                [mTagManageView reloadTagItems];
            }
        }];
        
        [self stopAutoScrollTimer];
    }
}

- (void)exchangeIfNeeded {
    NSInteger toIndex = [mTagManageView indexOfItemAtPoint:CGPointMake(_mTempMoveTag.center.x, _mTempMoveTag.center.y)];
    if (toIndex < 0) {
        return;
    }
    CGRect toTagRect = [mTagManageView rectOfItemAtIndex:toIndex];
    
    if (toIndex > currentLongPressIndex && CGRectGetMidX(_mTempMoveTag.frame) < CGRectGetMidX(toTagRect)) {
        toIndex --;
    }
    if (toIndex < currentLongPressIndex && CGRectGetMidX(_mTempMoveTag.frame) > CGRectGetMidX(toTagRect)) {
        toIndex ++;
    }
    
    if (currentLongPressIndex == currentActiveIndex) {
        currentActiveIndex = toIndex;
    }
    else {
        if (toIndex == currentActiveIndex) {
            currentActiveIndex = currentLongPressIndex;
        }
    }
    
    [mTagManageView moveItemAtIndex:currentLongPressIndex toIndex:toIndex complete:nil];
    
    currentLongPressIndex = toIndex;
}

- (UIImage *)imageFromItem:(UIView *)sheetItem
{
    UIGraphicsBeginImageContextWithOptions(sheetItem.bounds.size, NO, 0.0f);
    [sheetItem.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)startAutoScrollTimer {
    self.autoMoveTimeer = [NSTimer scheduledTimerWithTimeInterval:.003
                                                           target:self
                                                         selector:@selector(autoScroll)
                                                         userInfo:nil
                                                          repeats:YES];
    autoScrollDir = TagManageAutoScrollStop;
}

- (void)stopAutoScrollTimer {
    if ([_autoMoveTimeer isValid]) {
        [_autoMoveTimeer invalidate];
    }
}

- (void)autoScroll {
    switch (autoScrollDir)
    {
        case TagManageAutoScrollRight:
            if (mTagManageView.contentOffset.x > 0)
            {
                // 自动滚动，mTagManageView的偏移量每次调整1，但是长按的临时产生的_mTempMoveTag要回调1
                mTagManageView.contentOffset = CGPointMake(mTagManageView.contentOffset.x - 1,
                                                           mTagManageView.contentOffset.y);
                _mTempMoveTag.center = CGPointMake(_mTempMoveTag.center.x - 1,
                                                   _mTempMoveTag.center.y);
                [self exchangeIfNeeded];
            }
            break;
        case TagManageAutoScrollLeft:
            
            if (mTagManageView.contentOffset.x < mTagManageView.contentSize.width - mTagManageView.frame.size.width)
            {
                mTagManageView.contentOffset = CGPointMake(mTagManageView.contentOffset.x + 1,
                                                           mTagManageView.contentOffset.y);
                _mTempMoveTag.center = CGPointMake(_mTempMoveTag.center.x + 1,
                                                   _mTempMoveTag.center.y);
                [self exchangeIfNeeded];
            }
            break;
        case TagManageAutoScrollStop:
            
            break;
        default:
            break;
    }
}

@end
