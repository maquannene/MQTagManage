TagManage 
==============
拥有:增加，删除，移动，切换，功能。
####demo中界面基本功能逻辑放置在TagManageScrollView类中。
主要的Api如下所示：
```objc
// 在指定的index 位置增加一个标签
- (void)insertTagItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
// 删除指定的index 位置的标签
- (void)deleteTagItemAtIndex:(NSInteger)index complete:(void (^) ())complete;
// 移动移动一个标签到另一个位置
- (void)moveTagItemAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex complete:(void (^) ())complete;
```
####通过加入控制类（controller层），可以功能性扩展，具体在TagManage中。
在controller层TagManage中，对view层TagManageScrollView增加手势，后期可做到：
* 点击切换activeTag
* 长按交换位置
* 长按自动滚动
