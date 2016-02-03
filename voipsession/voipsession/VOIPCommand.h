//
//  VOIPCommand.h
//  voipsession
//
//  Created by houxh on 16/2/2.
//  Copyright © 2016年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>
enum EVOIPCommand {
    //语音通话
    VOIP_COMMAND_DIAL = 1,
    VOIP_COMMAND_ACCEPT = 2,
    VOIP_COMMAND_CONNECTED = 3,
    VOIP_COMMAND_REFUSE = 4,
    VOIP_COMMAND_REFUSED = 5,
    VOIP_COMMAND_HANG_UP = 6,
    VOIP_COMMAND_RESET = 7,
    
    //通话中
    VOIP_COMMAND_TALKING = 8,

    
    VOIP_COMMAND_MODE = 10
};

@interface NatPortMap : NSObject
@property(nonatomic) int32_t ip;
@property(nonatomic) int16_t port;
@end

@interface VOIPCommand : NSObject
-(VOIPCommand*)initWithContent:(NSData*)content;

@property(nonatomic, readonly) NSData *content;

@property(nonatomic, assign) int32_t cmd;
@property(nonatomic, assign) int32_t dialCount;//VOIP_COMMAND_DIAL,
@property(nonatomic, assign) CFUUIDBytes sessionID;//VOIP_COMMAND_DIAL,

@property(nonatomic, assign) int32_t mode;//VOIP_COMMAND_DIAL, VOIP_COMMAND_ACCEPT

@property(nonatomic) NatPortMap *natMap;//VOIP_COMMAND_ACCEPT，VOIP_COMMAND_CONNECTED
@property(nonatomic) int32_t relayIP;//VOIP_COMMAND_CONNECTED, 中转服务器ip地址

@property(nonatomic, assign) int32_t refuseReason; //VOIP_COMMAND_REFUSE

@end
