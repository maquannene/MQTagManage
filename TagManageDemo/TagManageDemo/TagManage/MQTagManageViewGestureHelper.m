//
//  MQTagManageViewGestureHelper.m
//  MQTagManageDemo
//
//  Created by 马权 on 3/13/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "MQTagManageViewGestureHelper.h"
#import "MQTagManageView.h"

@interface MQTagManageViewGestureHelper()<UIGestureRecognizerDelegate>

{
    MQTagManageView *mMQTagManageView;
    

    UIView *longPressTag;                               //  记录长按的tag
    NSInteger moveFromIndex;
    NSInteger currentLongPressIndex;
    NSInteger currentActiveIndex;
}

@property (retain, nonatomic) UIImageView *mTempMoveTag;
@property (retain, nonatomic) NSTimer *autoMoveTimeer;
@property (assign, nonatomic) MQTagManageAutoScrollDir autoScrollDir;

@end

@implementation MQTagManageViewGestureHelper

- (void)dealloc {
    [_mTempMoveTag release];
    _mTempMoveTag = nil;
    [_autoMoveTimeer release];
    _autoMoveTimeer = nil;
    [_tapGesture release];
    _tapGesture = nil;
    [super dealloc];
}

- (instancetype)initWithTagManageView:(MQTagManageView *)tagManageView {
    self = [super init];
    if (self) {
        mMQTagManageView = tagManageView;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(tagManageViewTap:)];
        _tapGesture.delegate = self;
        _tapGesture.numberOfTapsRequired = 1;
        [mMQTagManageView addGestureRecognizer:_tapGesture];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tagManageViewLongPress:)];
        [mMQTagManageView addGestureRecognizer:_longPressGesture];
        self.autoScrollDir = MQTagManageAutoScrollStop;
    }
    return self;
}

- (void)setHelperEnable:(BOOL)helperEnable {
    _helperEnable = helperEnable;
    _tapGesture.enabled = helperEnable;
    _longPressGesture.enabled = helperEnable;
}

- (void)setAutoScrollDir:(MQTagManageAutoScrollDir)autoScrollDir {
    if (_autoScrollDir != autoScrollDir) {
        _autoScrollDir = autoScrollDir;
        switch (_autoScrollDir) {
            case MQTagManageAutoScrollStop:
                [self stopAutoScrollTimer];
                break;
            case MQTagManageAutoScrollLeft:
            case MQTagManageAutoScrollRight:
                [self startAutoScrollTimer];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark - GestureAction
- (void)tagManageViewTap:(UITapGestureRecognizer *)gesture  {
    if ([mMQTagManageView.delegate conformsToProtocol:@protocol(MQTagManageViewGestureHelperDelegate)]) {
        if ([mMQTagManageView.delegate respondsToSelector:@selector(tagManageView:didSelectTagItemAtIndex:)]) {
            NSInteger tapIndex = [mMQTagManageView indexOfItemAtPoint:[gesture locationInView:mMQTagManageView]];
            if (tapIndex >= 0) {
                [(id<MQTagManageViewGestureHelperDelegate>)mMQTagManageView.delegate tagManageView:mMQTagManageView didSelectTagItemAtIndex:tapIndex];
                [mMQTagManageView reloadTagItems];
            }
        }
    }
}

- (void)tagManageViewLongPress:(UILongPressGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:mMQTagManageView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //  记录长按起始位置
        NSInteger longPressIndex = [mMQTagManageView indexOfItemAtPoint:touchPoint];
        
        //  如果没有点击到tag,或者点击超范围 容错处理。
        if (longPressTag < 0 || touchPoint.x > mMQTagManageView.contentSize.width) {
            return;
        }
        
        currentLongPressIndex = longPressIndex;
        moveFromIndex = longPressIndex;
        
        longPressTag = [mMQTagManageView tagForItemAtIndex:longPressIndex];
        //  显示临时view 跟着手指移动
        self.mTempMoveTag = [[[UIImageView alloc] initWithFrame:longPressTag.frame] autorelease];
        _mTempMoveTag.image = [self imageFromItem:longPressTag];
        _mTempMoveTag.alpha = .8;
        [mMQTagManageView addSubview:_mTempMoveTag];
        //  长按的tag要隐藏
        longPressTag.hidden = YES;
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        //  容错处理
        if (touchPoint.x > mMQTagManageView.contentSize.width) {
            return;
        }
        
        _mTempMoveTag.center = CGPointMake(touchPoint.x, CGRectGetMidY(_mTempMoveTag.frame));
        
        [self exchangeIfNeeded];
        
        // 自动滚动判断
        //如果触及左边自动滚动区
        if (touchPoint.x - mMQTagManageView.contentOffset.x <= 50 &&
            touchPoint.x - mMQTagManageView.contentOffset.x >= 0) {
            self.autoScrollDir = MQTagManageAutoScrollRight;
        }
        //如果触及右边自动滚动区
        else if (touchPoint.x - mMQTagManageView.contentOffset.x >= mMQTagManageView.frame.size.width - 50 &&
                 touchPoint.x - mMQTagManageView.contentOffset.x <= mMQTagManageView.frame.size.width) {
            self.autoScrollDir = MQTagManageAutoScrollLeft;
        }
        else {
            self.autoScrollDir = MQTagManageAutoScrollStop;
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
            if ([mMQTagManageView.delegate conformsToProtocol:@protocol(MQTagManageViewGestureHelperDelegate)]) {
                if ([mMQTagManageView.delegate respondsToSelector:@selector(tagManageView:didMoveItemFromIndex:toIndex:)]) {
                    [(id<MQTagManageViewGestureHelperDelegate>)mMQTagManageView.delegate tagManageView:mMQTagManageView didMoveItemFromIndex:moveFromIndex toIndex:currentLongPressIndex];
                }
            }
            if (moveFromIndex != currentLongPressIndex) {
                [mMQTagManageView reloadTagItems];
            }
        }];
        self.autoScrollDir = MQTagManageAutoScrollStop;
    }
}

- (void)exchangeIfNeeded {
    NSInteger toIndex = [mMQTagManageView indexOfItemAtPoint:CGPointMake(_mTempMoveTag.center.x, _mTempMoveTag.center.y)];
    if (toIndex < 0) {
        return;
    }
    CGRect toTagRect = [mMQTagManageView rectOfItemAtIndex:toIndex];
    
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
    
    [mMQTagManageView moveItemAtIndex:currentLongPressIndex toIndex:toIndex complete:nil];
    
    currentLongPressIndex = toIndex;
}

- (UIImage *)imageFromItem:(UIView *)sheetItem {
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
}

- (void)stopAutoScrollTimer {
    if ([_autoMoveTimeer isValid]) {
        [_autoMoveTimeer invalidate];
    }
}

- (void)autoScroll {
    switch (_autoScrollDir)
    {
        case MQTagManageAutoScrollRight:
            if (mMQTagManageView.contentOffset.x > 0) {
                // 自动滚动，mMQTagManageView的偏移量每次调整1，但是长按的临时产生的_mTempMoveTag要回调1
                mMQTagManageView.contentOffset = CGPointMake(mMQTagManageView.contentOffset.x - 1,
                                                           mMQTagManageView.contentOffset.y);
                _mTempMoveTag.center = CGPointMake(_mTempMoveTag.center.x - 1,
                                                   _mTempMoveTag.center.y);
                [self exchangeIfNeeded];
            }
            break;
        case MQTagManageAutoScrollLeft:
            if (mMQTagManageView.contentOffset.x < mMQTagManageView.contentSize.width - mMQTagManageView.frame.size.width) {
                mMQTagManageView.contentOffset = CGPointMake(mMQTagManageView.contentOffset.x + 1,
                                                           mMQTagManageView.contentOffset.y);
                _mTempMoveTag.center = CGPointMake(_mTempMoveTag.center.x + 1,
                                                   _mTempMoveTag.center.y);
                [self exchangeIfNeeded];
            }
            break;
        case MQTagManageAutoScrollStop:
            
            break;
        default:
            break;
    }
}

@end
