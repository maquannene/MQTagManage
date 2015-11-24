//
//  ViewController.m
//  MQTagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "ViewController.h"
#import "MQTagManageView.h"
#import "MQTagManageView+Gesture.h"
#import "MQTagManageViewGestureHelper.h"

static BOOL kDifferentWidth = 1;

static NSInteger maxCount = 40;

@interface ViewController ()

<
MQTagManageViewDelegate,
MQTagManageViewDataSource,
MQTagManageViewGestureHelperDelegate
>

{
    NSInteger _activeIndex;
}

@property (retain, nonatomic) MQTagManageView *tagManageView;
@property (retain, nonatomic) NSMutableArray *dataArray;
@property (retain, nonatomic) NSMutableArray *widthArray;

@end

@implementation ViewController

- (void)dealloc {
    [_tagManageView release];
    _tagManageView = nil;
    [_dataArray release];
    _dataArray = nil;
    [_widthArray release];
    _widthArray = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createData];
    
    //  tagManageView
    _tagManageView = [[MQTagManageView alloc] initWithFrame:CGRectMake(44 * 2,
                                                                       20,
                                                                       CGRectGetWidth(self.view.frame) - 44 * 4,
                                                                       44)];
    _tagManageView.gap = 0;
    _tagManageView.dataSource = self;
    _tagManageView.tagManageDelegate = self;
    _tagManageView.supportGesture = YES;
    [self createTagManangeViewAssistView];
    [self.view addSubview:_tagManageView];
}

- (void)createData {
    //  data
    NSInteger total = arc4random() % maxCount + 10;
    _activeIndex = arc4random() % total;
    self.dataArray = [[[NSMutableArray alloc] init] autorelease];
    self.widthArray = [[[NSMutableArray alloc] init] autorelease];
    for (int i = 0; i < total; i++) {
        @autoreleasepool {
            [self.dataArray addObject:[NSString stringWithFormat:@" Tag %d ", i]];
            if (kDifferentWidth) {
                [self.widthArray addObject:@(arc4random() % 85 + 85)];
            }
            else {
                [self.widthArray addObject:@(135)];
            }
        }
    }
}

- (void)createTagManangeViewAssistView {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addButton.frame = CGRectMake(0, 0, 44, 44);
    [addButton addTarget:self
                  action:@selector(tagManageAssistViewAction:)
        forControlEvents:UIControlEventTouchUpInside];
    _tagManageView.assistView = addButton;
}

//  add
- (void)tagManageAssistViewAction:(UIButton *)button {
    //  update data
    [_dataArray addObject:[NSString stringWithFormat:@" Tag %lu ", (unsigned long)_dataArray.count]];
    if (kDifferentWidth) {
        [self.widthArray addObject:@(arc4random() % 85 + 85)];
    }
    else {
        [self.widthArray addObject:@(135)];
    }
    //  update interface
    [_tagManageView insertItemAtIndex:_dataArray.count - 1 complete:^{
        _activeIndex = _dataArray.count - 1;
    }];
}

//  delete
- (IBAction)deleteAction:(id)sender {
    ((UIButton *)sender).userInteractionEnabled = NO;
    //  update data
    [_dataArray removeObjectAtIndex:_activeIndex];
    [_widthArray removeObjectAtIndex:_activeIndex];
    //  update interface
    [_tagManageView deleteItemAtIndex:_activeIndex complete:^{
        if (_activeIndex >= _dataArray.count) {
            _activeIndex = _dataArray.count - 1;
        }
        ((UIButton *)sender).userInteractionEnabled = YES;
    }];
}

//  reset
- (IBAction)resetAction:(id)sender {
    //  data
    [self createData];
    [_tagManageView reloadTagItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - MQTagManageViewDataSource
- (CGFloat)tagManageView:(MQTagManageView *)tagManageView widthForItemAtIndex:(NSInteger)index {
    NSNumber *num = _widthArray[index];
    CGFloat width = [num floatValue];
    return width;
}

- (NSInteger)activeItemIndex:(MQTagManageView *)tagManageView {
    return _activeIndex;
}

- (NSInteger)numberOfItems:(MQTagManageView *)tagManageView {
    return _dataArray.count;
}

- (UIView *)tagManageView:(MQTagManageView *)tagManageView tagForItemAtIndex:(NSInteger)index {
    UIView *view = [tagManageView dequeueReusableTag:index];
    if (!view) {
        view = [[[UIView alloc] init] autorelease];
        UILabel *tagItem = [[[UILabel alloc] initWithFrame:view.bounds] autorelease];
        tagItem.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tagItem.backgroundColor = [UIColor clearColor];
        tagItem.textAlignment = NSTextAlignmentCenter;
        tagItem.tag = 999;
        [view addSubview:tagItem];
    }
    
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 10;
    if (index == _activeIndex) {
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = [UIColor colorWithRed:70/255.0 green:179/255.0 blue:114/255.0 alpha:1].CGColor;
    }
    else {
        view.backgroundColor = [UIColor colorWithRed:70/255.0 green:179/255.0 blue:114/255.0 alpha:1];
        view.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    UILabel *tagItem = (UILabel *)[view viewWithTag:999];
    NSString *text = [NSString stringWithFormat:@"%@", _dataArray[index]];
    tagItem.text = text;
    return view;
}

#pragma mark -
#pragma mark - MQTagManageViewGestureHelperDelegate
- (void)tagManageView:(MQTagManageView *)tagManageView didSelectTagItemAtIndex:(NSInteger)index {
    // update data
    _activeIndex = index;
    NSLog(@"active %ld", (long)index);
}

- (void)tagManageView:(MQTagManageView *)tagManageView willMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    // update dataSource
    NSObject *fromData = [_dataArray[fromIndex] retain];
    [_dataArray removeObjectAtIndex:fromIndex];
    [_dataArray insertObject:fromData atIndex:toIndex];
    [fromData release];
    _activeIndex = toIndex;
    
    NSNumber *fromWidthNumber = [_widthArray[fromIndex] retain];
    [_widthArray removeObjectAtIndex:fromIndex];
    [_widthArray insertObject:fromWidthNumber atIndex:toIndex];
    [fromWidthNumber release];
}

- (void)tagManageView:(MQTagManageView *)tagManageView didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    //  Finish move
}

@end
