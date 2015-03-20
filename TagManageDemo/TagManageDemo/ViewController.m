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

static int maxConut = 10;

@interface ViewController ()

<
MQTagManageViewDelegate,
MQTagManageViewDataSource,
MQTagManageViewGestureHelperDelegate
>

{
    NSMutableArray *dataArray;
    NSInteger activeIndex;
}

@property (retain, nonatomic) MQTagManageView *tagManageView;

@end

@implementation ViewController

- (void)dealloc {
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
        [dataArray addObject:[NSString stringWithFormat:@" Tag %d ", i]];
    }
    
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
    [dataArray addObject:[NSString stringWithFormat:@" Tag %d ", dataArray.count]];
    
    //  update interface
    [_tagManageView insertItemAtIndex:dataArray.count - 1 complete:^{
        activeIndex = dataArray.count - 1;
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
    }];
}

//  reset
- (IBAction)resetAction:(id)sender {
    //  data
    activeIndex = 0;
    [dataArray release];
    dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < maxConut; i++) {
        [dataArray addObject:[NSString stringWithFormat:@" Tag %d ", i]];
    }
    [_tagManageView reloadTagItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - MQTagManageViewDataSource
- (NSInteger)activeItemIndex:(MQTagManageView *)tagManageView {
    return activeIndex;
}

- (NSInteger)numberOfItems:(MQTagManageView *)tagManageView {
    return dataArray.count;
}

- (UIView *)tagManageView:(MQTagManageView *)tagManageView tagForItemAtIndex:(NSInteger)index {
    UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
    imageView.backgroundColor = [UIColor clearColor];
    if (index == activeIndex) {
        [imageView setImage:[UIImage imageNamed:@"tag_selected.png"]];
    }
    else {
        [imageView setImage:[UIImage imageNamed:@"tag_unselected.png"]];
    }
    
    UILabel *tagItem = [[[UILabel alloc] initWithFrame:imageView.bounds] autorelease];
    tagItem.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tagItem.backgroundColor = [UIColor clearColor];
    tagItem.text = dataArray[index];
    tagItem.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:tagItem];
    
    return imageView;
}

#pragma mark -
#pragma mark - MQTagManageViewGestureHelperDelegate
- (void)tagManageView:(MQTagManageView *)tagManageView didSelectTagItemAtIndex:(NSInteger)index {
    // update data
    activeIndex = index;
    NSLog(@"active %d", index);
}

- (void)tagManageView:(MQTagManageView *)tagManageView didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSLog(@"from %d to %d", fromIndex, toIndex);
    
    // update data
    NSObject *fromData = dataArray[fromIndex];
    [dataArray removeObjectAtIndex:fromIndex];
    [dataArray insertObject:fromData atIndex:toIndex];
    activeIndex = toIndex;
}

@end
