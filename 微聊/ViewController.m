//
//  ViewController.m
//  微聊
//
//  Created by 潘阳君 on 15/6/7.
//  Copyright (c) 2015年 潘阳军. All rights reserved.
//

#import "ViewController.h"
#import "XMPPFramework.h"

@interface ViewController ()<XMPPStreamDelegate>
@property (nonatomic,strong) XMPPStream *xmppStream;
- (IBAction)login:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}


- (IBAction)login:(UIButton *)sender
{
    //链接openfire服务器
    [self connect];
}
-(void)connect
{
    //创建xmpp服务对象
    if (self.xmppStream == nil)
    {
        self.xmppStream = [[XMPPStream alloc] init];
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    if (![self.xmppStream isConnected])
    {
        NSString *usename = [NSString stringWithFormat:@"wangwu@panyangjun.local"];
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
    [sender authenticateWithPassword:@"lang123" error:&error];
    
}
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"验证成功");
}
@end
