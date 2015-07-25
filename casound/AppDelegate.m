//
//  AppDelegate.m
//  casound
//
//  Created by Tielman Janse van Vuuren on 2015/06/22.
//  Copyright (c) 2015 tman. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end
void audioCallback(
                                 void *                  inUserData,
                                 AudioQueueRef           inAQ,
                                 AudioQueueBufferRef     inBuffer)
{
    ;
}
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
    AudioQueueAllocateBuffer(_audioQueue, 1024, &buffer);
    NSLog(@"%d",AudioQueueStart(_audioQueue,NULL));
    //AudioQueueStop(j, true);
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    // Insert code here to tear down your application
}

@end
