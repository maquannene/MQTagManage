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

static BOOL kDifferentWidth = 0;

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
    _tagManageView.gap = -25;
    _tagManageView.dataSource = self;
    _tagManageView.delegate = self;
    _tagManageView.supportGesture = YES;
    [self createTagManangeViewAssistView];
    [self.view addSubview:_tagManageView];
}

- (void)createData {
    //  data
    NSInteger total = arc4random() % maxCount;
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
    [_dataArray addObject:[NSString stringWithFormat:@" Tag %d ", _dataArray.count]];
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
    //  update data
    [_dataArray removeObjectAtIndex:_activeIndex];
    [_widthArray removeObjectAtIndex:_activeIndex];
    //  update interface
    [_tagManageView deleteItemAtIndex:_activeIndex complete:^{
        if (_activeIndex >= _dataArray.count) {
            _activeIndex = _dataArray.count - 1;
        }
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
    UIImageView *imageView = [tagManageView dequeueReusableTag:index];
    if (!imageView) {
        imageView = [[[UIImageView alloc] init] autorelease];
        UILabel *tagItem = [[[UILabel alloc] initWithFrame:imageView.bounds] autorelease];
        tagItem.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tagItem.backgroundColor = [UIColor clearColor];
        tagItem.textAlignment = NSTextAlignmentCenter;
        tagItem.tag = 999;
        [imageView addSubview:tagItem];
    }
    imageView.backgroundColor = [UIColor clearColor];
    if (index == _activeIndex) {
        [imageView setImage:[UIImage imageNamed:@"tag_selected.png"]];
    }
    else {
        [imageView setImage:[UIImage imageNamed:@"tag_unselected.png"]];
    }
    
    UILabel *tagItem = (UILabel *)[imageView viewWithTag:999];
    NSString *text = [NSString stringWithFormat:@"%@", _dataArray[index]];
    tagItem.text = text;
    return imageView;
}

#pragma mark -
#pragma mark - MQTagManageViewGestureHelperDelegate
- (void)tagManageView:(MQTagManageView *)tagManageView didSelectTagItemAtIndex:(NSInteger)index {
    // update data
    _activeIndex = index;
    NSLog(@"active %d", index);
}

- (void)tagManageView:(MQTagManageView *)tagManageView didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSLog(@"from %d to %d", fromIndex, toIndex);

    // update data
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

@end
