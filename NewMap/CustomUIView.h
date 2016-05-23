//
//  CustomUIView.h
//  UAVGS
//
//  Created by liupengbo on 9/19/14.
//  Copyright (c) 2014 BoLooMo International Group Limited. All rights reserved.
//
//  CustomUIView 可以实现透明区域不拦截触摸的操作
//  如果某个UIView被 CustomUIView覆盖，只要将被覆盖的UIView
//  加入到passThroughViews中即可使被覆盖的UIView接受到触摸事件
#import <UIKit/UIKit.h>

@interface CustomUIView : UIView
@property (nonatomic,retain) NSArray * passThroughViews;
@property BOOL testHits;
- (BOOL) isPassThroughViews:(UIView *) view;
@end
