//
//  TagManage.m
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "TagManage.h"
#import "TagManageScrollView.h"

@interface TagManage()

<
TagManageScrollViewDataSource,
TagManageScrollViewDelegate,
UIGestureRecognizerDelegate
>

{
    TagManageScrollView *mTagManageScrollView;
    NSInteger currentActiveTag;
    NSInteger totalOfTag;
}

@end

@implementation TagManage

@synthesize view = mTagManageScrollView;

- (void)dealloc {
    [mTagManageScrollView release];
    mTagManageScrollView = nil;
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        currentActiveTag = 0;
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
    totalOfTag --;
    [mTagManageScrollView deleteTagItemAtIndex:currentActiveTag complete:^{
        if (currentActiveTag == totalOfTag) {
            currentActiveTag = currentActiveTag - 1;
        }
        [mTagManageScrollView reloadTagItems];
    }];
}

- (void)resetTag {
    totalOfTag = 10;
    currentActiveTag = 0;
    [mTagManageScrollView reloadTagItems];
}

#pragma mark -
#pragma mark - TagManageAssistViewAction
- (void)tagManageAssistViewAction:(UIButton *)button {
    //  add total first
    totalOfTag ++;
    [mTagManageScrollView insertTagItemAtIndex:(totalOfTag - 1) complete:^{
        currentActiveTag = (totalOfTag - 1);
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
        currentActiveTag = tapIndex;
        [mTagManageScrollView reloadTagItems];
    }
    //  双击
    if (gesture.numberOfTapsRequired == 2) {
        
    }
}

- (void)tagManageScrollViewLongPress:(UIGestureRecognizer *)gesture {
    
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
    return currentActiveTag;
}

#pragma mark -
#pragma mark - TagManageScrollViewDelegate

@end
