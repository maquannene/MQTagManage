TagManage 
==============
<p align="center"><img src="https://github.com/wuhanness/TagManage/blob/master/tagManageDemoShow.gif" width="570" height="61"/></p>

An easy to use TagManageView and usagea bit like as UITableView.
import the file folder "TagManageView", and implement some datasource.

#Intro
This widget main contain two parts: [view] and [gestureHelper]
#####1.TagManageView:
Provide the view base behavior, main AIP and datasource:
```objc
//API
- (void)reloadTagItems;

// insert a tag at index
- (void)insertItemAtIndex:(NSInteger)index complete:(void (^) ())complete;

// delete a tag at index
- (void)deleteItemAtIndex:(NSInteger)index complete:(void (^) ())complete;

// move a tag from fromIndex to toIndex
- (void)moveItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^) ())complete;

//DataSource
- (NSInteger)activeItemIndex:(TagManageView *)tagManageView;

- (NSInteger)numberOfItems:(TagManageView *)tagManageView;

- (UIView *)tagManageView:(TagManageView *)tagManageView tagForItemAtIndex:(NSInteger)index;

```
#####2.TagManageViewGestureHelper:
This class which extend the function of TagManageView by use TagManageView behavior（base API), the main operate delegate as follow:
```objc
//  select tagItem call-back
- (void)tagManageView:(TagManageView *)tagManageView didSelectTagItemAtIndex:(NSInteger)index;
//  move tagItem call-back
- (void)tagManageView:(TagManageView *)tagManageView didMoveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
```
#More
If you just want show something by only use TagManageView, just `TagManageView.supportGesture = NO;`, it will close gestureoperate. Even you can custom gesture then add on TagManageView like TagManageViewGestureHelper to achieve you want.

I am a junior developer, so Welcome to pointed out problem, fork and push.
Thanks.

The next step, add reuseQueue to promote efficiency and save memory.
