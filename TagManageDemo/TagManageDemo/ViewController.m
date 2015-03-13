//
//  ViewController.m
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "ViewController.h"
#import "TagManageView.h"
#import "TagManageView+Gesture.h"
#import "TagManageViewGestureHelper.h"

static int maxConut = 10;

@interface ViewController ()

<
TagManageViewDelegate,
TagManageViewDataSource,
TagManageViewGestureHelperDelegate
>

{
    NSMutableArray *dataArray;
    NSInteger activeIndex;
}

@property (retain, nonatomic) TagManageView *tagManageView;

@end

@implementation ViewController

- (void)dealloc
{
    [_tagManageView release];
    _tagManageView = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  data
    activeIndex = 0;
    dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < maxConut; i++) {
        [dataArray addObject:[NSString stringWithFormat:@"- %d -", i]];
    }
    
    //  tagManageView
    _tagManageView = [[TagManageView alloc] init];
    _tagManageView.backgroundColor = [UIColor orangeColor];
    _tagManageView.gap = -25;
    _tagManageView.dataSource = self;
    _tagManageView.delegate = self;
    _tagManageView.supportGesture = YES;
    [self createTagManangeViewAssistView];
    [self.view addSubview:_tagManageView];
    [_tagManageView reloadTagItems];
}

- (void)viewDidLayoutSubviews {
    _tagManageView.frame = CGRectMake(44 * 2,
                                      20,
                                      CGRectGetWidth(self.view.frame) - 44 * 4,
                                      44);
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
    [dataArray addObject:[NSString stringWithFormat:@"- %d -", dataArray.count]];
    
    //  update interface
    [_tagManageView insertItemAtIndex:dataArray.count - 1 complete:^{
        activeIndex = dataArray.count - 1;
        [_tagManageView reloadTagItems];
    }];
}

//  delete
- (IBAction)deleteAction:(id)sender {
    //  update data
    [dataArray removeObjectAtIndex:activeIndex];
    
    //  update interface
    [_tagManageView deleteItemAtIndex:activeIndex complete:^{
        if (activeIndex >= dataArray.count) {
            activeIndex = dataArray.count - 1;
        }
        [_tagManageView reloadTagItems];
    }];
}

//  reset
- (IBAction)resetAction:(id)sender {
    //  data
    activeIndex = 0;
    [dataArray release];
    dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < maxConut; i++) {
        [dataArray addObject:[NSString stringWithFormat:@"- %d -", i]];
    }
    [_tagManageView reloadTagItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - TagManageViewDataSource
- (NSInteger)activeItemIndex:(TagManageView *)tagManageView {
    return activeIndex;
}

- (NSInteger)numberOfItems:(TagManageView *)tagManageView {
    return dataArray.count;
}

- (UIView *)tagManageView:(TagManageView *)tagManageView tagForItemAtIndex:(NSInteger)index {
    UILabel *tagItem = [[[UILabel alloc] init] autorelease];
    tagItem.backgroundColor = [UIColor grayColor];
    tagItem.text = dataArray[index];
    tagItem.textAlignment = NSTextAlignmentCenter;
    tagItem.layer.cornerRadius = 22;
    tagItem.layer.borderWidth = 2;
    tagItem.layer.borderColor = [UIColor blackColor].CGColor;
    return tagItem;
}

- (CGFloat)tagManageView:(TagManageView *)tagManageView heightForItemAtIndex:(NSInteger)index {
    return 44;
}

- (CGFloat)tagManageView:(TagManageView *)tagManageView widthForItemAtIndex:(NSInteger)index {
    return 135;
}

#pragma mark -
#pragma mark - TagManageViewGestureHelperDelegate
- (void)tagManageView:(TagManageView *)tagManageView didSelectTagItemAtIndex:(NSInteger)index {
    
    // update data
    activeIndex = index;
    [tagManageView reloadTagItems];
}

- (void)tagManageView:(TagManageView *)tagManageView didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSLog(@"from %d to %d", fromIndex, toIndex);
    
    // update data
    NSObject *fromData = dataArray[fromIndex];
    [dataArray removeObjectAtIndex:fromIndex];
    [dataArray insertObject:fromData atIndex:toIndex];
    activeIndex = toIndex;
}

@end
