//
//  AppDelegate.h
//  微聊
//
//  Created by 潘阳君 on 15/6/7.
//  Copyright (c) 2015年 潘阳军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) XMPPStream *xmppStream;

@end

