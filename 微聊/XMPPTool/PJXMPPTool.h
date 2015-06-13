//
//  PJXMPPTool.h
//  微聊
//
//  Created by 潘阳君 on 15/6/11.
//  Copyright (c) 2015年 潘阳军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@protocol PJXMPPToolDelegate
@optional
-(void)PJXMPPToolLoginStatus:(NSString *)status;
@end

@interface PJXMPPTool : NSObject

@property (nonatomic,strong) id <PJXMPPToolDelegate> delegate;
@property (nonatomic,assign) NSString *status;
/**
 *  登录账号
 *
 *  @param account  账号
 *  @param password 密码
 */
-(void)XMPPUserLoginWithAccount:(NSString *)account password:(NSString *)password;

@end
