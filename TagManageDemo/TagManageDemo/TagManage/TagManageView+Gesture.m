//
//  TagManageView+Gesture.m
//  TagManageDemo
//
//  Created by 马权 on 3/13/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "TagManageView+Gesture.h"
#import "TagManageViewGestureHelper.h"
#import <objc/runtime.h>

static char TagManageViewGestureHelperKey;

@interface TagManageView ()

@property (retain, nonatomic) TagManageViewGestureHelper *mGestureHelper;

@end

@implementation TagManageView (Gesture)

- (TagManageViewGestureHelper *)mGestureHelper {
    TagManageViewGestureHelper *gestureHelper = objc_getAssociatedObject(self, &TagManageViewGestureHelperKey);
    if (!gestureHelper) {
        gestureHelper = [[TagManageViewGestureHelper alloc] initWithTagManageView:self];
        objc_setAssociatedObject(self, &TagManageViewGestureHelperKey, gestureHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gestureHelper;
}

- (void)setSupportGesture:(BOOL)supportGesture {
    self.mGestureHelper.helperEnable = supportGesture;
}

- (BOOL)supportGesture {
    return self.mGestureHelper.helperEnable;
}

@end
