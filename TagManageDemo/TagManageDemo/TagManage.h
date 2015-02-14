//
//  TagManage.h
//  TagManageDemo
//
//  Created by 马权 on 2/14/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagManage : NSObject

@property (retain, nonatomic) UIView *view;

//  临时接口
- (void)deleteTag:(NSInteger)index;

- (void)resetTag;

@end
