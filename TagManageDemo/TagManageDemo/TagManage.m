//
//  TagManage.m
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "TagManage.h"
#import "TagManageScrollView.h"

typedef NS_ENUM(NSUInteger, TagManageAutoScrollDir) {
    TagManageAutoScrollLeft,
    TagManageAutoScrollRight,
    TagManageAutoScrollStop
};

@interface TagManage()

<
TagManageScrollViewDataSource,
TagManageScrollViewDelegate,
UIGestureRecognizerDelegate
>

{
    TagManageScrollView *mTagManageScrollView;
    NSInteger currentActiveIndex;
    NSInteger totalOfTag;
    
    TagManageAutoScrollDir autoScrollDir;
    UIView *longPressTag;                               //  记录长按的tag
    NSInteger moveFromIndex;
    NSInteger currentLongPressIndex;
}

@property (retain, nonatomic) UIImageView *mTempMoveTag;
@property (retain, nonatomic) NSTimer *autoMoveTimeer;

@end

@implementation TagManage

@synthesize view = mTagManageScrollView;

- (void)dealloc {
    [mTagManageScrollView release];
    mTagManageScrollView = nil;
    [_mTempMoveTag release];
    _mTempMoveTag = nil;
    [_autoMoveTimeer release];
    _autoMoveTimeer = nil;
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        currentActiveIndex = 0;
        totalOfTag = 10;
        [self createTagManangeView];
        [self createTagManangeViewAssistView];
        [mTagManageScrollView reloadTagItems];
    }
    return self;
}

- (void)createTagManangeView {
    mTagManageScrollView = [[TagManageScrollView alloc] initWithFrame:CGRectZero];
    mTagManageScrollView.backgroundColor = [UIColor orangeColor];
    mTagManageScrollView.delegate = self;
    mTagManageScrollView.dataSource = self;
    mTagManageScrollView.gap = -25;                 //  设置间隔。负数为重叠。
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tagManageScrollViewTap:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [mTagManageScrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tagManageScrollViewTap:)];
    doubleGesture.delegate = self;
    doubleGesture.numberOfTapsRequired = 2;
    [mTagManageScrollView addGestureRecognizer:doubleGesture];
    [doubleGesture release];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tagManageScrollViewLongPress:)];
    [mTagManageScrollView addGestureRecognizer:longPress];
    [longPress release];
}

- (void)createTagManangeViewAssistView {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addButton.frame = CGRectMake(0, 0, 44, 44);
    [addButton addTarget:self
                  action:@selector(tagManageAssistViewAction:)
        forControlEvents:UIControlEventTouchUpInside];
    mTagManageScrollView.assistView = addButton;
}

#pragma mark -
#pragma mark - 对外接口
- (void)deleteTag:(NSInteger)index {
    NSLog(@"delete index = %d", currentActiveIndex);
    totalOfTag --;
    [mTagManageScrollView deleteTagItemAtIndex:currentActiveIndex complete:^{
        if (currentActiveIndex == totalOfTag) {
            currentActiveIndex = currentActiveIndex - 1;
        }
        [mTagManageScrollView reloadTagItems];
        NSLog(@"active index = %d", currentActiveIndex);
    }];
}

- (void)resetTag {
    totalOfTag = 10;
    currentActiveIndex = 0;
    [mTagManageScrollView reloadTagItems];
}

#pragma mark -
#pragma mark - 对内函数
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
            if (mTagManageScrollView.contentOffset.x > 0)
            {
                // 自动滚动，mTagManageScrollView的偏移量每次调整1，但是长按的临时产生的_mTempMoveTag要回调1
                mTagManageScrollView.contentOffset = CGPointMake(mTagManageScrollView.contentOffset.x - 1,
                                                                 mTagManageScrollView.contentOffset.y);
                _mTempMoveTag.center = CGPointMake(_mTempMoveTag.center.x - 1,
                                                   _mTempMoveTag.center.y);
                [self exchangeIfNeeded];
            }
            break;
        case TagManageAutoScrollLeft:
            
            if (mTagManageScrollView.contentOffset.x < mTagManageScrollView.contentSize.width - mTagManageScrollView.frame.size.width)
            {
                mTagManageScrollView.contentOffset = CGPointMake(mTagManageScrollView.contentOffset.x + 1,
                                                                 mTagManageScrollView.contentOffset.y);
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

#pragma mark -
#pragma mark - TagManageAssistViewAction
- (void)tagManageAssistViewAction:(UIButton *)button {
    //  add total first
    totalOfTag ++;
    [mTagManageScrollView insertTagItemAtIndex:(totalOfTag - 1) complete:^{
        currentActiveIndex = (totalOfTag - 1);
        [mTagManageScrollView reloadTagItems];
    }];
}

#pragma mark -
#pragma mark - GestureAction
- (void)tagManageScrollViewTap:(UITapGestureRecognizer *)gesture {
    
    NSInteger tapIndex = [mTagManageScrollView findTagItemIndex:[gesture locationInView:mTagManageScrollView]];
    NSLog(@"tap index = %d", tapIndex);
    //  单机
    if (gesture.numberOfTapsRequired == 1) {
        currentActiveIndex = tapIndex;
        [mTagManageScrollView reloadTagItems];
    }
    //  双击
    if (gesture.numberOfTapsRequired == 2) {
        
    }
}

- (void)tagManageScrollViewLongPress:(UILongPressGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:mTagManageScrollView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //  记录长按起始位置
        NSInteger longPressIndex = [mTagManageScrollView findTagItemIndex:touchPoint];
        
        //  如果没有点击到tag,或者点击超范围 容错处理。
        if (longPressTag < 0 || touchPoint.x > mTagManageScrollView.contentSize.width) {
            return;
        }
        
        currentLongPressIndex = longPressIndex;
        moveFromIndex = longPressIndex;
    

        longPressTag = [mTagManageScrollView tagItemAtIndex:longPressIndex];
        //  显示临时view 跟着手指移动
        self.mTempMoveTag = [[[UIImageView alloc] initWithFrame:longPressTag.frame] autorelease];
        _mTempMoveTag.image = [self imageFromItem:longPressTag];
        _mTempMoveTag.alpha = .8;
        [mTagManageScrollView addSubview:_mTempMoveTag];
        //  长按的tag要隐藏
        longPressTag.hidden = YES;
        
        //  一旦长按，要开启自动滚动timer
        [self startAutoScrollTimer];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        //  容错处理
        if (touchPoint.x > mTagManageScrollView.contentSize.width) {
            return;
        }
        
        _mTempMoveTag.center = CGPointMake(touchPoint.x, CGRectGetMidY(_mTempMoveTag.frame));
        
        [self exchangeIfNeeded];
        
        // 自动滚动判断
        //如果触及左边自动滚动区
        if (touchPoint.x - mTagManageScrollView.contentOffset.x <= 50 &&
            touchPoint.x - mTagManageScrollView.contentOffset.x >= 0)
        {
            autoScrollDir = TagManageAutoScrollRight;
        }
        //如果触及右边自动滚动区
        else if (touchPoint.x - mTagManageScrollView.contentOffset.x >= mTagManageScrollView.frame.size.width - 50 &&
                 touchPoint.x - mTagManageScrollView.contentOffset.x <= mTagManageScrollView.frame.size.width)
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
            
            //  如果起始位置，和最后长按移动到的位置不一致，要更新tag
            if (moveFromIndex != currentLongPressIndex) {
                [mTagManageScrollView reloadTagItems];
            }
        }];
        
        [self stopAutoScrollTimer];
    }
}

- (void)exchangeIfNeeded {
    NSInteger toIndex = [mTagManageScrollView findTagItemIndex:CGPointMake(_mTempMoveTag.center.x, _mTempMoveTag.center.y)];
    if (toIndex < 0) {
        return;
    }
    CGRect toTagRect = [mTagManageScrollView getTagItemRect:toIndex];
    
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
    
    [mTagManageScrollView moveTagItemAtIndex:currentLongPressIndex toIndex:toIndex complete:nil];
    
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

#pragma mark -
#pragma mark - TagManageScrollViewDataSource
- (NSInteger)numberOfVisiableTags {
    return totalOfTag;
}

- (UIView *)tagItemAtIndex:(NSInteger)index {
    UILabel *tagItem = [[[UILabel alloc] init] autorelease];
    tagItem.backgroundColor = [UIColor grayColor];
    tagItem.text = [NSString stringWithFormat:@"%d", index];
    tagItem.textAlignment = NSTextAlignmentCenter;
    tagItem.layer.cornerRadius = 22;
    tagItem.layer.borderWidth = 2;
    tagItem.layer.borderColor = [UIColor blackColor].CGColor;
    return tagItem;
}

- (CGFloat)tagManage:(TagManageScrollView *)tagManage heightForTagItemAtIndex:(NSInteger)index {
    return 44;
}

- (CGFloat)tagManage:(TagManageScrollView *)tagManage widthForTagItemAtIndex:(NSInteger)index {
    return 135;
}

- (NSInteger)getActiveTagIndex {
    return currentActiveIndex;
}

#pragma mark -
#pragma mark - TagManageScrollViewDelegate

@end
