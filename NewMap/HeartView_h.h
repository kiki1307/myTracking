//
//  HeartView_h.h
//  NewMap
//
//  Created by zhidao on 16/5/21.
//  Copyright © 2016年 zhidao. All rights reserved.
//

#import "CustomUIView.h"
@class CAEmitterLayer;
@interface HeartView_h : CustomUIView


@property (nonatomic, strong) CAEmitterLayer* heartsEmitter;
@property (nonatomic, assign) BOOL begin;
@end
