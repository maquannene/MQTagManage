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
  @private
    MQTagManageView *_tagManageView;
    UIView *_longPressTag;                               //  记录长按的tag
    NSInteger _moveFromIndex;
    NSInteger _currentLongPressIndex;
    NSInteger _currentActiveIndex;
}

@property (retain, nonatomic) UIImageView *mTempMoveTag;
@property (retain, nonatomic) NSTimer *autoMoveTimer;
@property (assign, nonatomic) MQTagManageAutoScrollDir autoScrollDir;

@end

@implementation MQTagManageViewGestureHelper

- (void)dealloc {
    [_mTempMoveTag release];
    _mTempMoveTag = nil;
    [_autoMoveTimer release];
    _autoMoveTimer = nil;
    [_tapGesture release];
    _tapGesture = nil;
    [super dealloc];
}

- (instancetype)initWithTagManageView:(MQTagManageView *)tagManageView {
    self = [super init];
    if (self) {
        _tagManageView = tagManageView;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(tagManageViewTap:)];
        _tapGesture.delegate = self;
        _tapGesture.numberOfTapsRequired = 1;
        [_tagManageView addGestureRecognizer:_tapGesture];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tagManageViewLongPress:)];
        [_tagManageView addGestureRecognizer:_longPressGesture];
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
    if ([_tagManageView.delegate conformsToProtocol:@protocol(MQTagManageViewGestureHelperDelegate)]) {
        if ([_tagManageView.delegate respondsToSelector:@selector(tagManageView:didSelectTagItemAtIndex:)]) {
            NSInteger tapIndex = [_tagManageView indexOfItemAtPoint:[gesture locationInView:_tagManageView]];
            if (tapIndex >= 0) {
                [(id<MQTagManageViewGestureHelperDelegate>)_tagManageView.delegate tagManageView:_tagManageView didSelectTagItemAtIndex:tapIndex];
                [_tagManageView reloadTagItems];
            }
        }
    }
}

- (void)tagManageViewLongPress:(UILongPressGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:_tagManageView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //  记录长按起始位置
        NSInteger longPressIndex = [_tagManageView indexOfItemAtPoint:touchPoint];
        
        //  如果没有点击到tag,或者点击超范围 容错处理。
        if (_longPressTag < 0 || touchPoint.x > _tagManageView.contentSize.width) {
            return;
        }
        
        _currentLongPressIndex = longPressIndex;
        _moveFromIndex = longPressIndex;
        
        _longPressTag = [_tagManageView tagForItemAtIndex:longPressIndex];
        //  显示临时view 跟着手指移动
        self.mTempMoveTag = [[[UIImageView alloc] initWithFrame:_longPressTag.frame] autorelease];
        _mTempMoveTag.image = [self imageFromItem:_longPressTag];
        _mTempMoveTag.alpha = .8;
        [_tagManageView addSubview:_mTempMoveTag];
        //  长按的tag要隐藏
        _longPressTag.hidden = YES;
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        //  容错处理
        if (touchPoint.x > _tagManageView.contentSize.width) {
            return;
        }
        
        _mTempMoveTag.center = CGPointMake(touchPoint.x, CGRectGetMidY(_mTempMoveTag.frame));
        
        [self exchangeIfNeeded];
        
        // 自动滚动判断
        //如果触及左边自动滚动区
        if (touchPoint.x - _tagManageView.contentOffset.x <= 50 &&
            touchPoint.x - _tagManageView.contentOffset.x >= 0) {
            self.autoScrollDir = MQTagManageAutoScrollRight;
        }
        //如果触及右边自动滚动区
        else if (touchPoint.x - _tagManageView.contentOffset.x >= _tagManageView.frame.size.width - 50 &&
                 touchPoint.x - _tagManageView.contentOffset.x <= _tagManageView.frame.size.width) {
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
            _mTempMoveTag.frame = _longPressTag.frame;
        } completion:^(BOOL finished) {
            _longPressTag.hidden = NO;
            [_mTempMoveTag removeFromSuperview];
            
            //  didMove delegate
            if ([_tagManageView.delegate conformsToProtocol:@protocol(MQTagManageViewGestureHelperDelegate)]) {
                if ([_tagManageView.delegate respondsToSelector:@selector(tagManageView:didMoveItemFromIndex:toIndex:)]) {
                    [(id<MQTagManageViewGestureHelperDelegate>)_tagManageView.delegate tagManageView:_tagManageView didMoveItemFromIndex:_moveFromIndex toIndex:_currentLongPressIndex];
                }
            }
            if (_moveFromIndex != _currentLongPressIndex) {
                [_tagManageView reloadTagItems];
            }
        }];
        self.autoScrollDir = MQTagManageAutoScrollStop;
    }
}

- (void)exchangeIfNeeded {
    NSInteger toIndex = [_tagManageView indexOfItemAtPoint:CGPointMake(_mTempMoveTag.center.x, _mTempMoveTag.center.y)];
    if (toIndex == NSNotFound) {
        return;
    }
    CGRect toTagRect = [_tagManageView rectOfItemAtIndex:toIndex];
    
    if (toIndex > _currentLongPressIndex && CGRectGetMidX(_mTempMoveTag.frame) < CGRectGetMidX(toTagRect)) {
        toIndex --;
    }
    if (toIndex < _currentLongPressIndex && CGRectGetMidX(_mTempMoveTag.frame) > CGRectGetMidX(toTagRect)) {
        toIndex ++;
    }
    
    if (_currentLongPressIndex == _currentActiveIndex) {
        _currentActiveIndex = toIndex;
    }
    else {
        if (toIndex == _currentActiveIndex) {
            _currentActiveIndex = _currentLongPressIndex;
        }
    }
    
    [_tagManageView moveItemAtIndex:_currentLongPressIndex toIndex:toIndex complete:nil];
    
    _currentLongPressIndex = toIndex;
}

- (UIImage *)imageFromItem:(UIView *)sheetItem {
    UIGraphicsBeginImageContextWithOptions(sheetItem.bounds.size, NO, 0.0f);
    [sheetItem.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)startAutoScrollTimer {
    self.autoMoveTimer = [NSTimer scheduledTimerWithTimeInterval:.003
                                                           target:self
                                                         selector:@selector(autoScroll)
                                                         userInfo:nil
                                                          repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoMoveTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAutoScrollTimer {
    if ([_autoMoveTimer isValid]) {
        [_autoMoveTimer invalidate];
    }
}

- (void)autoScroll {
    switch (_autoScrollDir)
    {
        case MQTagManageAutoScrollRight:
            if (_tagManageView.contentOffset.x > 0) {
                // 自动滚动，_tagManageView的偏移量每次调整1，但是长按的临时产生的_mTempMoveTag要回调1
                _tagManageView.contentOffset = CGPointMake(_tagManageView.contentOffset.x - 1,
                                                           _tagManageView.contentOffset.y);
                _mTempMoveTag.center = CGPointMake(_mTempMoveTag.center.x - 1,
                                                   _mTempMoveTag.center.y);
                [self exchangeIfNeeded];
            }
            break;
        case MQTagManageAutoScrollLeft:
            if (_tagManageView.contentOffset.x < _tagManageView.contentSize.width - _tagManageView.frame.size.width) {
                _tagManageView.contentOffset = CGPointMake(_tagManageView.contentOffset.x + 1,
                                                           _tagManageView.contentOffset.y);
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
