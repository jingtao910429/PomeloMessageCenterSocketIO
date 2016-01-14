//
//  Pomelo.m
//  iOS client for Pomelo
//
//  Created by Johnny on 12-12-11.
//  Copyright (c) 2012 netease pomelo team. All rights reserved.
//

#import "PomeloClient.h"
#import "PomeloProtocolSocketIO.h"
#import "SocketIOJSONSerialization.h"
#import "SocketIOPacket.h"

#define ROUTE_MAP_KEY(msgid) [NSString stringWithFormat:@"ROUTE_MAP_KEY_%d",(int)msgid]

static NSString const *_connectCallback = @"__connectCallback__";
static NSString const *_disconnectCallback = @"__disconnectCallback__";

@interface PomeloClient (Private)
- (void)sendMessageWithReqId:(NSInteger)reqId andRoute:(NSString *)route andMsg:(NSDictionary *)msg;
- (void)processMessage:(NSDictionary *)msg;
- (void)processMessageBatch:(NSArray *)msgs;
@end

@implementation PomeloClient

- (id)initWithDelegate:(id<PomeloDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _reqId = 0;
        _routeMap =[[NSMutableDictionary alloc] init];
        _callbacks = [[NSMutableDictionary alloc] init];
        socketIO = [[SocketIO alloc] initWithDelegate:self];
    }
    return self;
    
}

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port
{
    [socketIO connectToHost:host onPort:port];
}
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withCallback:(PomeloCallback)callback;
{
    if (callback) {
        [_callbacks setObject:callback forKey:_connectCallback];
    }
    [socketIO connectToHost:host onPort:port];
}
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params
{
    [socketIO connectToHost:host onPort:port withParams:params];
}
- (void)disconnect
{
    [socketIO disconnect];
}

- (void)disconnectWithCallback:(PomeloCallback)callback
{
    if (callback) {
        [_callbacks setObject:callback forKey:_disconnectCallback];
    }
    [socketIO disconnect];
}
# pragma mark -
# pragma mark implement SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket
{
    PomeloCallback callback = [_callbacks objectForKey:_connectCallback];
    if (callback != nil) {
        
        callback(self,@"connect");
        [_callbacks removeObjectForKey:_connectCallback];
    }
    if ([_delegate respondsToSelector:@selector(PomeloDidConnect:)]) {
        [_delegate PomeloDidConnect:self];
    }
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    PomeloCallback callback = [_callbacks objectForKey:_disconnectCallback];
    
    if (callback != nil) {
        callback(self,@"disconnect");
        [_callbacks removeObjectForKey:_disconnectCallback];
    }
    if ([_delegate respondsToSelector:@selector(PomeloDidDisconnect:withError:)]) {
        [_delegate PomeloDidDisconnect:self withError:error];
    }
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    id data = [packet dataAsJSON];
    if ([_delegate respondsToSelector:@selector(Pomelo:didReceiveMessage:)]) {
        [_delegate Pomelo:self didReceiveMessage:data];
    }
    
    if ([data isKindOfClass:[NSArray class]]) {
        [self processMessageBatch:data];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        [self processMessage:data];
    }
}

# pragma mark -
# pragma mark main api

- (void)notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params
{
    [self sendMessageWithReqId:0 andRoute:route andMsg:params];
}

- (void)requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:(PomeloCallback)callback
{
    if (callback) {
        ++_reqId;
        NSString *key = [NSString stringWithFormat:@"%ld", (long)_reqId];
        [_callbacks setObject:[callback copy] forKey:key];
        [_routeMap setObject:route forKey:ROUTE_MAP_KEY((int)_reqId)];
        [self sendMessageWithReqId:_reqId andRoute:route andMsg:params];
    } else {
        [self notifyWithRoute:route andParams:params];
    }

}

- (void)onRoute:(NSString *)route withCallback:(PomeloCallback)callback
{
    id array = [_callbacks objectForKey:route];
    if (array == nil) {
        array = [NSMutableArray arrayWithCapacity:1];
        [_callbacks setObject:array forKey:route];
    }
    [array addObject:[callback copy]];
}

- (void)offRoute:(NSString *)route
{
    [_callbacks removeObjectForKey:route];
}

# pragma mark -
# pragma mark private methods

- (void)sendMessageWithReqId:(NSInteger)reqId andRoute:(NSString *)route andMsg:(NSDictionary *)msg
{
    NSString *msgStr = [SocketIOJSONSerialization JSONStringFromObject:msg error:nil];
    [socketIO sendMessage:[PomeloProtocolSocketIO encodeWithId:reqId andRoute:route andBody:msgStr]];
}

- (void)processMessage:(NSDictionary *)msg
{
    id msgId =  [msg objectForKey:@"id"];
    NSString *route = [_routeMap objectForKey:ROUTE_MAP_KEY([msgId intValue])];
    [_routeMap removeObjectForKey:ROUTE_MAP_KEY([msgId intValue])];
    if (msgId && msgId > 0){
        NSString *key = [NSString stringWithFormat:@"%@", msgId];
        PomeloCallback callback = [_callbacks objectForKey:key];
        if (callback != nil) {
            callback([msg objectForKey:@"body"],route);
            [_callbacks removeObjectForKey:key];
        }
    } else {
        
        NSString *msgRoute = [msg objectForKey:@"route"];
        
        NSMutableArray *callbacks = [_callbacks objectForKey:[msg objectForKey:@"route"]];
        if (callbacks != nil) {
            
            for (PomeloCallback cb in callbacks)  {
                cb([msg objectForKey:@"body"],msgRoute);
            }
        }
        
    }
}

- (void)processMessageBatch:(NSArray *)msgs route:(NSString *)route
{
    for (id msg in msgs) {
        [self processMessage:msg];
    }
}

# pragma mark - SocketIODelegate

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error {
    
    if ([_delegate respondsToSelector:@selector(PomeloDidDisconnect:withError:)]) {
        [_delegate PomeloDidDisconnect:self withError:error];
    }
    
}


- (void)dealloc
{
    socketIO = nil;
    _routeMap = nil;
    _callbacks = nil;
    _delegate = nil;
}
@end
