//
//  ViewController.h
//  NewMap
//
//  Created by zhidao on 16/5/18.
//  Copyright © 2016年 zhidao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrumbPath.h"
#import "CrumbPathRenderer.h"
#import "HeartView_h.h"
@interface ViewController : UIViewController

@property (nonatomic, strong) CrumbPath* crumbs;
@property (nonatomic, strong) CrumbPathRenderer* crumbPathRenderer;

@property (nonatomic, strong) MKPolygonRenderer *drawingAreaRenderer;

@property (nonatomic, strong) UILabel* disLabel;
@property (nonatomic, strong) HeartView_h* heartView;


+(ViewController *)shared;
@end

