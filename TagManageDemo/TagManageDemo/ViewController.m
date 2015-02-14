//
//  ViewController.m
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "ViewController.h"
#import "TagManage.h"

@interface ViewController ()

{
    TagManage *mTagManage;
}

@end

@implementation ViewController

- (void)dealloc
{
    [mTagManage release];
    mTagManage = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    mTagManage = [[TagManage alloc] init];
    [self.view addSubview:mTagManage.view];
}

- (void)viewDidLayoutSubviews {
    mTagManage.view.frame = CGRectMake(44 * 2,
                                       20,
                                       CGRectGetWidth(self.view.frame) - 44 * 4,
                                       44);
}
- (IBAction)deleteAction:(id)sender {
    [mTagManage deleteTag:0];
}
- (IBAction)resetAction:(id)sender {
    [mTagManage resetTag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
