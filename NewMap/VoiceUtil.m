//
//  VoiceUtil.m
//  NewMap
//
//  Created by zhidao on 16/5/20.
//  Copyright © 2016年 zhidao. All rights reserved.
//

#import "VoiceUtil.h"
#import <AVFoundation/AVFoundation.h>
@implementation VoiceUtil

+(VoiceUtil *)shared
{
    static VoiceUtil *sharedVoiceUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedVoiceUtil = [[VoiceUtil alloc] init];
    });
    return sharedVoiceUtil;
}

- (void)speekSomething:(NSString *)something
{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:something];
    utterance.rate *= 1.0;//音速
    //音高
    utterance.pitchMultiplier = 1;
    //获取系统语音
    NSString *preferredLang = @"en-US";
//    if ([[self getCurrentLanguage] isEqualToString: @"zh-Hans-CN"]
//        || [[self getCurrentLanguage] isEqualToString: @"zh-Hans"])
//    {
//        preferredLang = @"zh-CN";
//    }else{
//        preferredLang = @"en-US";
//    }
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[NSString stringWithFormat:@"%@",preferredLang]];
    utterance.voice = voice;
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
    
}
- (NSString *)getCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}


@end
