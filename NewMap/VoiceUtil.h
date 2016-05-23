//
//  VoiceUtil.h
//  NewMap
//
//  Created by zhidao on 16/5/20.
//  Copyright © 2016年 zhidao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceUtil : NSObject

+(VoiceUtil *)shared;
- (void)speekSomething:(NSString *)something;


@end
