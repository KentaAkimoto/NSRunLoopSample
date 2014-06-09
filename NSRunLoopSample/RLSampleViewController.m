//
//  RLSampleViewController.m
//  NSRunLoopSample
//
//  Created by 秋元　健太 on 2014/06/01.
//  Copyright (c) 2014年 kentaakimoto. All rights reserved.
//

#import "RLSampleViewController.h"

@interface RLSampleViewController ()

@property (nonatomic,weak) NSTimer *timer;
@property (nonatomic,weak) NSTimer *timerB;
@property (nonatomic,assign) NSUInteger fireCount;

@end

@implementation RLSampleViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fireCount = 0;
    
    // タイマーを作成
    _timer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
//    _timerB = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(timerFireMethodB:) userInfo:nil repeats:YES];
    
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
    
    // タイマーをどのモードでセットするか
#warning タイマーをどのモードでセットするか
    [myRunLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
//    [myRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
//    [myRunLoop addTimer:_timer forMode:@"OREORE_MODE"];

//    [myRunLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
//    [myRunLoop addTimer:_timer forMode:UITrackingRunLoopMode];
    

//    [myRunLoop addTimer:_timerB forMode:NSRunLoopCommonModes];

    
    // 実行ループオブザーバを作成して、実行ループに接続します。
    CFRunLoopObserverContext context = {0, CFBridgingRetain(self), NULL, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
    if (observer)
    {
        CFRunLoopRef cfLoop = [myRunLoop getCFRunLoop];

#warning オブザーバをどのモードでセットするか ＝ どのモードを監視するか
//        CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopDefaultMode);
        CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopCommonModes);

    }
    
#warning 自分でrunloopをまわす場合
    NSInteger loopCount = 5;
    do {
        NSLog(@"runUntilDate");
        //[myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [myRunLoop runMode:@"OREORE_MODE" beforeDate:[NSDate distantFuture]]; // 制限しておく日時(beforeDate)には、適当な値を設定(distantFuture) 終了日時を指定できないので、明示的にstopさせる必要あり
        loopCount--;
    } while (loopCount);
    NSLog(@"while loop end------------------------------------");
}

/**
 * RunLoopのアクティビティ毎に呼ばれる
 */
void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    /*
    // 参考：アクティビティの値
    kCFRunLoopEntry = (1UL << 0),
    kCFRunLoopBeforeTimers = (1UL << 1),
    kCFRunLoopBeforeSources = (1UL << 2),
    kCFRunLoopBeforeWaiting = (1UL << 5),
    kCFRunLoopAfterWaiting = (1UL << 6),
    kCFRunLoopExit = (1UL << 7),
    kCFRunLoopAllActivities = 0x0FFFFFFFU
    */
    
    NSMutableArray *flags = [@[] mutableCopy];
    flags[0] = @((activity >> 0) & 1);
    flags[1] = @((activity >> 1) & 1);
    flags[2] = @((activity >> 2) & 1);
    flags[3] = @((activity >> 5) & 1);
    flags[4] = @((activity >> 6) & 1);
    flags[5] = @((activity >> 7) & 1);
    
    NSString *mode = (__bridge NSString *)(CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent()));
    
    RLSampleViewController *obj = (__bridge RLSampleViewController *)info;
    NSLog(@"[%@][%@]myRunLoopObserver activity:%@",[NSThread currentThread],mode ,[obj convertString:flags]);
}

- (NSString *) convertString:(NSArray*) array{
    NSMutableString *results = [NSMutableString string];
    for (NSNumber *flag in array) {
        [results appendFormat:@"%d",[flag boolValue]];
    }
    return results;
}

/**
 * タイマー発火で呼ばれる
 */
- (void)timerFireMethod:(NSTimer *)timer{
    self.fireCount++;
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];

    NSLog(@"[%@][%@] timerFireMethod %lu",[NSThread currentThread], myRunLoop.currentMode, (unsigned long) _fireCount);
    
    // オレオレRunLoopを止める場合
    if ([myRunLoop.currentMode isEqualToString:@"OREORE_MODE"]) {
        NSLog(@"stop runloop");
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

/**
 * タイマー発火で呼ばれる(時間がかかる処理)
 */
- (void)timerFireMethodB:(NSTimer *)timer{
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];

//    dispatch_queue_t queue = dispatch_queue_create("my.queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(queue, ^(){
        NSLog(@"[%@][%@] timerFireMethodB",[NSThread currentThread], myRunLoop.currentMode);
        [NSThread sleepForTimeInterval:2];
//    });
}

@end
