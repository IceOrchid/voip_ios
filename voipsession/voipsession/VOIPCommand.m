//
//  VOIPCommand.m
//  voipsession
//
//  Created by houxh on 16/2/2.
//  Copyright © 2016年 beetle. All rights reserved.
//

#import "VOIPCommand.h"
#import <imsdk/util.h>
#define STATIC_ASSERT(COND,MSG) typedef char static_assertion_##MSG[(COND)?1:-1]

STATIC_ASSERT(sizeof(CFUUIDBytes)==16,UUIDSizeIs16Byte);

@implementation NatPortMap

@end

@implementation VOIPCommand
-(VOIPCommand*)initWithContent:(NSData*)content {
    self = [super init];
    if (self) {
        const char *p = [content bytes];
        self.cmd = readInt32(p);
        p += 4;
        if (self.cmd == VOIP_COMMAND_DIAL) {
            self.dialCount = readInt32(p);
            p += 4;
            self.mode = readInt32(p);
            p += 4;
            CFUUIDBytes uuid;
            memcpy(&uuid, p, 16);
            self.sessionID = uuid;
            p += 16;
        } else if (self.cmd == VOIP_COMMAND_ACCEPT) {
            self.natMap = [[NatPortMap alloc] init];
            self.natMap.ip = readInt32(p);
            p += 4;
            self.natMap.port = readInt16(p);
            p += 2;
            self.mode = readInt32(p);
            p += 4;
        } else if (self.cmd == VOIP_COMMAND_CONNECTED) {
            if (content.length >= 10) {
                self.natMap = [[NatPortMap alloc] init];
                self.natMap.ip = readInt32(p);
                p += 4;
                self.natMap.port = readInt16(p);
                p += 2;
            }
            if (content.length >= 14) {
                self.relayIP = readInt32(p);
                p += 4;
            }
        } else if (self.cmd == VOIP_COMMAND_REFUSE) {
            self.refuseReason = readInt32(p);
            p += 4;
        } else if (self.cmd == VOIP_COMMAND_MODE) {
            self.mode = readInt32(p);
            p += 4;
        }
    }
    return self;
}

-(NSData*)content {
    char buf[64*1024] = {0};
    char *p = buf;
    
    writeInt32(self.cmd, p);
    p += 4;
    if (self.cmd == VOIP_COMMAND_DIAL) {
        writeInt32(self.dialCount, p);
        p += 4;
        writeInt32(self.mode, p);
        p += 4;
        CFUUIDBytes uuid = self.sessionID;
        memcpy(p, &uuid, 16);
        p += 16;
        return [NSData dataWithBytes:buf length:28];
    } else if (self.cmd == VOIP_COMMAND_ACCEPT) {
        NSLog(@"nat map ip:%x", self.natMap.ip);
        writeInt32(self.natMap.ip, p);
        p += 4;
        writeInt16(self.natMap.port, p);
        p += 2;
        writeInt32(self.mode, p);
        p += 4;
        return [NSData dataWithBytes:buf length:14];
    } else if (self.cmd == VOIP_COMMAND_CONNECTED) {
        NSLog(@"nat map ip:%x", self.natMap.ip);
        writeInt32(self.natMap.ip, p);
        p += 4;
        writeInt16(self.natMap.port, p);
        p += 2;
        writeInt32(self.relayIP, p);
        p += 4;
        return [NSData dataWithBytes:buf length:14];
    } else if (self.cmd == VOIP_COMMAND_REFUSE) {
        writeInt32(self.refuseReason, p);
        p += 4;
        return [NSData dataWithBytes:buf length:8];
    } else if (self.cmd == VOIP_COMMAND_MODE) {
        writeInt32(self.mode, p);
        p += 4;
        return [NSData dataWithBytes:buf length:8];
    } else {
        return [NSData dataWithBytes:buf length:4];
    }
}
@end
