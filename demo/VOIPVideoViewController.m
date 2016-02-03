//
//  VOIPVideoViewController.m
//  voip_demo
//
//  Created by houxh on 15/9/7.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "VOIPVideoViewController.h"

#include <arpa/inet.h>
#import <AVFoundation/AVAudioSession.h>
#import <UIKit/UIKit.h>
#import <voipengine/VOIPEngine.h>
#import <voipengine/VOIPRenderView.h>
#import <voipengine/VOIPCapture.h>
#import <voipsession/VOIPSession.h>


@interface VOIPVideoViewController ()
@property(nonatomic) VOIPRenderView *remoteRender;
@property(nonatomic) VOIPRenderView *localRender;
@property(nonatomic) VOIPCapture *voipCapture;
@property(nonatomic) enum SessionMode sessionMode;
@end

@implementation VOIPVideoViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sessionMode = SESSION_VIDEO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 50, 100, 40)];

    [switchButton setTitle:@"切换" forState:UIControlStateNormal];
    [switchButton addTarget:self
                          action:@selector(switchCamera:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchButton];
    
    UIButton *modeButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 100, 100, 40)];
    
    [modeButton setTitle:@"摄像头开关" forState:UIControlStateNormal];
    [modeButton addTarget:self
                     action:@selector(switchMode:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:modeButton];
    
    
    self.remoteRender = [[VOIPRenderView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.remoteRender atIndex:0];
    
    self.localRender = [[VOIPRenderView alloc] initWithFrame:CGRectMake(200, 380, 72, 96)];
    [self.view insertSubview:self.localRender aboveSubview:self.remoteRender];
    
    self.localRender.hidden = YES;
    self.remoteRender.hidden = YES;
    
    
    self.voipCapture = [[VOIPCapture alloc] init];
    self.voipCapture.render = self.remoteRender;
    self.remoteRender.hidden = NO;

    [self.voipCapture startCapture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchCamera:(id)sender {
    NSLog(@"switch camera");
    [self.engine switchCamera];
}

-(void)switchMode:(id)sender {
    NSLog(@"switch mode");
    if (self.sessionMode == SESSION_VIDEO) {
        [self.engine stopCapture];
    } else if (self.sessionMode == SESSION_VOICE) {
        [self.engine startCapture];
    }
    
    
    if (self.sessionMode == SESSION_VIDEO) {
        self.sessionMode = SESSION_VOICE;
    } else {
        self.sessionMode = SESSION_VIDEO;
    }
    
    [self.voip setSessionMode:self.mode];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)dismiss {
    [super dismiss];
    [self.voipCapture stopCapture];
    self.voipCapture = nil;
}

- (enum SessionMode)mode {
    return self.sessionMode;
}

- (void)startStream {
    if (self.voip.localNatMap != nil) {
        struct in_addr addr;
        addr.s_addr = htonl(self.voip.localNatMap.ip);
        NSLog(@"local nat map:%s:%d", inet_ntoa(addr), self.voip.localNatMap.port);
    }
    if (self.voip.peerNatMap != nil) {
        struct in_addr addr;
        addr.s_addr = htonl(self.voip.peerNatMap.ip);
        NSLog(@"peer nat map:%s:%d", inet_ntoa(addr), self.voip.peerNatMap.port);
    }
    
    if (self.isP2P) {
        struct in_addr addr;
        addr.s_addr = htonl(self.voip.peerNatMap.ip);
        NSLog(@"peer address:%s:%d", inet_ntoa(addr), self.voip.peerNatMap.port);
        NSLog(@"start p2p stream");
    } else {
        NSLog(@"start stream");
    }
    
    [self.voipCapture stopCapture];
    self.voipCapture = nil;
    
    if (self.engine != nil) {
        return;
    }
    
    self.engine = [[VOIPEngine alloc] init];
    NSLog(@"relay ip:%@", self.voip.relayIP);
    self.engine.relayIP = self.voip.relayIP;
    self.engine.voipPort = self.voip.voipPort;
    self.engine.caller = self.currentUID;
    self.engine.callee = self.peerUID;
    self.engine.token = self.token;
    self.engine.isCaller = self.isCaller;
    self.engine.videoEnabled = YES;
    
    self.engine.remoteRender = self.remoteRender;
    self.engine.localRender = self.localRender;
    
    
    if (self.isP2P) {
        self.engine.calleeIP = self.voip.peerNatMap.ip;
        self.engine.calleePort = self.voip.peerNatMap.port;
    }
    
    [self.engine startStream];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.localRender.hidden = NO;
    self.remoteRender.hidden = NO;
    
    [self SetLoudspeakerStatus:YES];
}


-(void)stopStream {
    if (self.engine == nil) {
        return;
    }
    NSLog(@"stop stream");
    [self.engine stopStream];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)onMode:(enum SessionMode)mode {
    NSLog(@"session mode:%d", mode);
    
    if (mode != self.sessionMode) {
        self.sessionMode = mode;
        if (self.sessionMode == SESSION_VIDEO) {
            [self.engine startCapture];
        } else if (self.sessionMode == SESSION_VOICE) {
            [self.engine stopCapture];
        }
    }
}

@end
