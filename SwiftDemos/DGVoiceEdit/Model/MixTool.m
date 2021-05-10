//
//  MixTool.m
//  AudioMixDemo
//
//  Created by 海涛 黎 on 2017/11/28.
//  Copyright © 2017年 Levi. All rights reserved.
//

#import "MixTool.h"
#import <AVFoundation/AVFoundation.h>
@implementation MixTool
/**
 合成音频文件（包含渐入渐出人声效果）
 
 @param toURL 合成文件后的导出路径
 @param backUrl 背景音乐文件路径
 @param audioUrl 要突出的声音文件
 @param startTime 渐入人声时间节点
 @param completed 合并文件完成
 */
+ (void)sourceComposeToURL:(NSURL *)toURL
                   backUrl:(NSURL*)backUrl
                  audioUrl:(NSURL*)audioUrl
                 startTime:(float)startTime
                 completed:(void (^)(NSError *error)) completed;{
    //  合并所有的录音文件
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //  获取音频合并音轨
    AVMutableCompositionTrack *recordAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *recordError = nil;
    AVURLAsset  *recordAudioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    //获取录音文件时长
    CMTime audioDuration = recordAudioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    //计算录音文件插入时间段
//    CMTime start = CMTimeMakeWithSeconds(startTime, 1);
    CMTime duration = CMTimeMakeWithSeconds(audioDurationSeconds,1);
    CMTimeRange audio_timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1), duration);
    
    if (CMTimeGetSeconds([[AVURLAsset alloc]initWithURL:backUrl options:nil].duration) == 0) {
        completed([[NSError alloc] initWithDomain:@"背景音频文件获取时长失败无法继续" code:100002 userInfo:nil]);
        return;
    }
    if (audioDurationSeconds == 0) {
        // 主音频的时长获取失败
        completed([[NSError alloc] initWithDomain:@"主音频文件获取时长失败无法继续" code:100001 userInfo:nil]);
        return;
    }
    
    NSArray* bgAudioMixParams = [MixTool insertBgVoice:mixComposition recordAudioAsset:recordAudioAsset backAudioUrl:backUrl];
    
    BOOL recordSuccess = [recordAudioTrack insertTimeRange:audio_timeRange ofTrack:[[recordAudioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:&recordError];
    if (!recordSuccess) {
        NSLog(@"插入音频失败: %@",recordError);
    }
    
    AVMutableAudioMix *backAudioMix = [AVMutableAudioMix audioMix];
    backAudioMix.inputParameters = bgAudioMixParams;//[NSArray arrayWithArray:audioMixParams];
    
    [MixTool exportM4AFile:mixComposition exportUrl:toURL backAudioMix:backAudioMix completionBlock:^(NSError *error) {
        if (completed) {
            completed(error);
        }
    }];
}


+(NSArray*) insertBgVoice:(AVMutableComposition*)composition recordAudioAsset:(AVURLAsset*)recordAudioAsset backAudioUrl:(NSURL*)backAudioUrl {
    
    AVURLAsset  *backAudioAsset = [[AVURLAsset alloc]initWithURL:backAudioUrl options:nil];
    
    // 判断主音频的市场是否超过背景音乐的时长  如果超过背景音乐的时长就取整获取最大循环背景音乐的资源
    float recordDuration = CMTimeGetSeconds(recordAudioAsset.duration);
    float bgDuration = CMTimeGetSeconds(backAudioAsset.duration);
  
    int count = ceilf(recordDuration / bgDuration);
    if (recordDuration < bgDuration) {
        count = 1;
    }
    
    //设置降低背景音乐参数
    NSMutableArray *audioMixParams = [NSMutableArray array];
    CMTime beginTime = kCMTimeZero;
    for (int i = 0; i < count; i ++ ) {
        NSError *error = nil;
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        float currentDuration = bgDuration * (i + 1);
        CMTime duration = backAudioAsset.duration;
        
        if (currentDuration > recordDuration) {
            // 当前循环的时长超过主音频的时长（减去不必要的时长）
            currentDuration = bgDuration - (currentDuration - recordDuration);
            duration = CMTimeMake(currentDuration , 1);
        }
        NSLog(@"当前音频所在开始时间结点:%f",currentDuration);
        
        CMTimeRange count_bg_timeRange = CMTimeRangeMake(kCMTimeZero , duration);
        
        BOOL success = [compositionAudioTrack insertTimeRange:count_bg_timeRange ofTrack:[[backAudioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime: beginTime error:&error];
        if (!success) {
            NSLog(@"插入音频失败: %@",error);
        }

        //降低此段背景音乐时间节点
        AVMutableAudioMixInputParameters *minColumeMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
        [minColumeMix setVolumeRampFromStartVolume:1. toEndVolume:0.3 timeRange:CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(2, 1))];
        [audioMixParams addObject:minColumeMix];
        beginTime = CMTimeAdd(beginTime, backAudioAsset.duration);
    }
    return audioMixParams;
}

+(void)exportM4AFile:(AVMutableComposition*)mixComposition
                exportUrl:(NSURL*)exportUrl
        backAudioMix:(AVMutableAudioMix*)backAudioMix
     completionBlock:(void(^)(NSError *error))completionBlock{
    // 创建一个导入M4A格式的音频的导出对象
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
    //  导入音视频的URL
    assetExport.outputURL = exportUrl;
    NSLog(@"音频合成输出地址:%@",exportUrl.absoluteString);
    //  导出音视频的文件格式
    assetExport.outputFileType = AVFileTypeAppleM4A;//@"com.apple.m4a-audio";
    //导出参数
    assetExport.audioMix = backAudioMix;
    //  导入出
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        //      分发到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            switch ([assetExport status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"合成失败：%@",[[assetExport error] description]);
                    completionBlock([assetExport error]);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    completionBlock([assetExport error]);
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    completionBlock(nil);
                } break;
                default: {
                    completionBlock([assetExport error]);
                } break;
            }
        });
    }];
}
@end
