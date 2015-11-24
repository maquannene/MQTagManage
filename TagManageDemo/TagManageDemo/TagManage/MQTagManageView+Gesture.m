//
//  MQTagManageView+Gesture.m
//  MQTagManageDemo
//
//  Created by 马权 on 3/13/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "MQTagManageView+Gesture.h"
#import "MQTagManageViewGestureHelper.h"
#import <objc/runtime.h>

static char MQTagManageViewGestureHelperKey;

@interface MQTagManageView ()

@property (nonatomic, retain) MQTagManageViewGestureHelper *mGestureHelper;

@end

@implementation MQTagManageView (Gesture)

- (MQTagManageViewGestureHelper *)mGestureHelper {
    MQTagManageViewGestureHelper *gestureHelper = objc_getAssociatedObject(self, &MQTagManageViewGestureHelperKey);
    if (!gestureHelper) {
        gestureHelper = [[MQTagManageViewGestureHelper alloc] initWithTagManageView:self];
        objc_setAssociatedObject(self, &MQTagManageViewGestureHelperKey, gestureHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [gestureHelper release];
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
