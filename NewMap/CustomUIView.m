//
//  CustomUIView.m
//  UAVGS
//
//  Created by liupengbo on 9/19/14.
//  Copyright (c) 2014 BoLooMo International Group Limited. All rights reserved.
//

#import "CustomUIView.h"

@implementation CustomUIView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(_testHits){
        return nil;
    }
    if(!self.passThroughViews
       || (self.passThroughViews && self.passThroughViews.count == 0)){
        return self;
    } else {
        
        UIView *hitView = [super hitTest:point withEvent:event];
        
        if (hitView == self) {
            //Test whether any of the passthrough views would handle this touch
            _testHits = YES;
            CGPoint superPoint = [self.superview convertPoint:point fromView:self];
            UIView *superHitView = [self.superview hitTest:superPoint withEvent:event];
            _testHits = NO;
            
            if ([self isPassThroughViews:superHitView]) {
                hitView = superHitView;
            }
        }
        
        return hitView;
    }
}
- (BOOL)isPassThroughViews:(UIView *)view{
    if (self.passThroughViews==nil) {
        return NO;
    }
    if ([self.passThroughViews containsObject:view]) {
        return YES;
    }
    return [self isPassThroughViews:view.superview];
}
- (void)dealloc{
    self.passThroughViews = nil;
}
@end
