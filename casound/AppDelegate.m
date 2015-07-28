//
//  AppDelegate.m
//  casound
//
//  Created by Tielman Janse van Vuuren on 2015/06/22.
//  Copyright (c) 2015 tman. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end
void audioCallback(
                                 void *                  inUserData,
                                 AudioQueueRef           inAQ,
                                 AudioQueueBufferRef     inBuffer)
{
    inBuffer->mAudioDataByteSize=2048;
    for(int i=0;i<128;i++)
    {
        ((SInt32*)(inBuffer->mAudioData))[i]=0x7FFFFFFF;
        //printf("%d",((SInt32*)(inBuffer->mAudioData))[i]);
    }
    for(int i=128;i<256;i++)
    {
        ((SInt32*)(inBuffer->mAudioData))[i]=0x80000001;
        //printf("%d",((SInt32*)(inBuffer->mAudioData))[i]);
    }
    for(int i=256;i<384;i++)
    {
        ((SInt32*)(inBuffer->mAudioData))[i]=0x7FFFFFFF;
        //printf("%d",((SInt32*)(inBuffer->mAudioData))[i]);
    }
    for(int i=384;i<512;i++)
    {
        ((SInt32*)(inBuffer->mAudioData))[i]=0x80000001;
        //printf("%d",((SInt32*)(inBuffer->mAudioData))[i]);
    }
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    
}

void AudioPropertyListener( void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID )
{
    CFStringRef j;
    UInt32 k=32;
    AudioQueueGetProperty(inAQ, kAudioQueueProperty_CurrentDevice, &j, &k);
    NSLog(@"%u",k);
    
    NSLog(@"%@",j);
}
@implementation AppDelegate
@synthesize audioQueue=_audioQueue;
- (AudioQueueRef)audioQueue
{
    if(_audioQueue==NULL)
    {
        AudioStreamBasicDescription inFormat;
        inFormat.mBitsPerChannel=32;
        inFormat.mBytesPerFrame=4;
        inFormat.mBytesPerPacket=4;
        inFormat.mFramesPerPacket=1;
        inFormat.mSampleRate=44100;
        inFormat.mChannelsPerFrame=1;
        inFormat.mFormatID=kAudioFormatLinearPCM;
        inFormat.mFormatFlags=kAudioFormatFlagIsSignedInteger |
        kAudioFormatFlagsNativeEndian |
        kAudioFormatFlagIsPacked;
        CFRunLoopRef q=CFRunLoopGetCurrent();
        
        AudioQueueNewOutput(&inFormat, audioCallback, NULL, q, CFRunLoopCopyCurrentMode(q), 0, &_audioQueue);
        AudioQueueBufferRef buffer;
        AudioQueueBufferRef bufferB;
        AudioQueueAllocateBuffer(_audioQueue, 2048, &buffer);
        AudioQueueAllocateBuffer(_audioQueue, 2048, &bufferB);
        audioCallback(NULL, _audioQueue, buffer);
        audioCallback(NULL, _audioQueue, bufferB);
    }
    return _audioQueue;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    AudioQueueSetParameter(self.audioQueue, kAudioQueueParam_Volume, 0.5);
    NSLog(@"%d",AudioQueueStart(self.audioQueue,NULL));
    AudioQueueAddPropertyListener ( self.audioQueue, kAudioQueueProperty_CurrentDevice, &AudioPropertyListener, self.audioQueue);
    
    CFStringRef j;
    UInt32 k=1000;
    AudioQueueGetPropertySize ( self.audioQueue, kAudioQueueProperty_CurrentDevice, &k );
    AudioQueueGetProperty(self.audioQueue, kAudioQueueProperty_CurrentDevice,(void *) &j, &k);
    NSLog(@"%u",k);
    
    NSLog(@"%s", CFStringGetCStringPtr(j, kCFStringEncodingUTF8));
    
    //AudioQueueStop(j, true);
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    AudioQueueStop(self.audioQueue, YES);
    AudioQueueDispose (                            // 1
                       self.audioQueue,                             // 2
                       true                                       // 3
                       );
    // Insert code here to tear down your application
}

@end
