//
//  PJXMPPTool.m
//  微聊
//
//  Created by 潘阳君 on 15/6/11.
//  Copyright (c) 2015年 潘阳军. All rights reserved.
//

#import "PJXMPPTool.h"

@interface PJXMPPTool()<XMPPStreamDelegate>

@property (nonatomic,strong) XMPPStream *xmppStream;
@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *password;

@property (nonatomic,strong) NSMutableArray *messageArray;


@end

@implementation PJXMPPTool
///**
// *  懒加载
// */
//-(XMPPStream *)xmppStream
//{
//    if (_xmppStream == nil)
//    {
//        _xmppStream = [[XMPPStream alloc] init];
//        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    }
//    return _xmppStream;
//}
-(void)XMPPUserLoginWithAccount:(NSString *)account password:(NSString *)password
{
    _account = account;
    _password = password;
    
    //创建xmpp服务对象
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppStream = [delegate xmppStream];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if (![self.xmppStream isConnected])
    {
        NSString *usename = [NSString stringWithFormat:@"%@@panyangjun.local",_account];
        XMPPJID *jid = [XMPPJID jidWithString:usename resource:@"iphone"];
        NSLog(@"%@",jid);
        [self.xmppStream setMyJID:jid];
        [self.xmppStream setHostName:@"192.168.2.112"];//这里可以写panyangjun.local
        [self.xmppStream setHostPort:5222];
        NSError *error = nil;
        if (![self.xmppStream connectWithTimeout:1.0 error:&error])
        {
            NSLog(@"%@",error);
        }
    }


    
}


-(void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"成功了");
}
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSError *error = nil;
    BOOL result = [sender authenticateWithPassword:_password error:&error];
    if (result)
    {
        _status = @"success";
    }
    else
    {
        _status = @"faile";
    }
    [self.delegate PJXMPPToolLoginStatus:_status];
    
}
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"验证成功");
    //上线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    
    [self.xmppStream sendElement:presence];
    
    
}
//
////获取消息
//-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
//{
//    NSString *mess = [[message elementForName:@"body"] stringValue];
//    NSString *status = @"incoming";
//    if(mess)
//    {
//        NSDictionary *messagedict = [NSDictionary dictionaryWithObjectsAndKeys:mess,@"Text",status,@"Status",nil];
//        [self.messageArray addObject:messagedict];
////        //当前时间
////        [self.timestamps addObject:[NSDate date]];
//        
//    }
//    
//}
//- (void)sendMessage:(NSString *)mess
//{
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:mess];
//    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
//    [message addAttributeWithName:@"type" stringValue:@"chat"];
//    NSString *to = @"pan1@panyangjun.local";
//    [message addAttributeWithName:@"to" stringValue:to];
//    [message addChild:body];
//    [self.xmppStream sendElement:message];
//}
//

@end
