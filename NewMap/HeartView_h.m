//
//  HeartView_h.m
//  NewMap
//
//  Created by zhidao on 16/5/21.
//  Copyright © 2016年 zhidao. All rights reserved.
//

#import "HeartView_h.h"

@implementation HeartView_h

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _heartsEmitter = [CAEmitterLayer layer];
        _heartsEmitter.emitterSize = self.frame.size;
        _heartsEmitter.emitterMode = kCAEmitterLayerVolume;
        _heartsEmitter.emitterShape = kCAEmitterLayerRectangle;
        _heartsEmitter.renderMode   = kCAEmitterLayerAdditive;
        
        CAEmitterCell *heart = [CAEmitterCell emitterCell];
        heart.name = @"heart";
        
        heart.emissionLongitude = M_PI/2.0; // up
        heart.emissionRange = 0.55 * M_PI;  // in a wide spread
        heart.birthRate		= 0.0;			// emitter is deactivated for now
        heart.lifetime		= 10.0;			// hearts vanish after 10 seconds
        
        heart.velocity		= -120;			// particles get fired up fast
        heart.velocityRange = 60;			// with some variation
        heart.yAcceleration = 20;			// but fall eventually
        
        heart.contents		= (id) [[UIImage imageNamed:@"DazHeart"] CGImage];
        heart.color			= [[UIColor colorWithRed:1.0 green:0.0 blue:0.0933 alpha:0.676885775862069] CGColor];
        heart.redRange		= 0.3;			// some variation in the color
        heart.blueRange		= 0.3;
        heart.alphaSpeed	= -0.5 / heart.lifetime;  // fade over the lifetime
        
        heart.scale			= 0.15;			// let them start small
        heart.scaleSpeed	= 0.5;			// but then 'explode' in size
        heart.spinRange		= 2.0 * M_PI;	// and send them spinning from -180 to +180 deg/s
        
        // Add everything to our backing layer
        _heartsEmitter.emitterCells = [NSArray arrayWithObject:heart];
        [self.layer addSublayer:_heartsEmitter];
        
        
        
    }
    
    return self;
}

-(void)setBegin:(BOOL)begin{
    CABasicAnimation *heartsBurst = [CABasicAnimation animationWithKeyPath:@"emitterCells.heart.birthRate"];
    heartsBurst.fromValue		= [NSNumber numberWithFloat:150.0];
    heartsBurst.toValue			= [NSNumber numberWithFloat:  0.0];
    heartsBurst.duration		= 5.0;
    heartsBurst.timingFunction	= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [self.heartsEmitter addAnimation:heartsBurst forKey:@"heartsBurst"];
}

@end
