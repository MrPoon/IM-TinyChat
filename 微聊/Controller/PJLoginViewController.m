//
//  PJLoginViewController.m
//  微聊
//
//  Created by 潘阳君 on 15/6/9.
//  Copyright (c) 2015年 潘阳军. All rights reserved.
//

#import "PJLoginViewController.h"
#import "PJNavgationController.h"
#import "ViewController.h"
#import "XMPPFramework.h"
#import "PJXMPPTool.h"

@interface PJLoginViewController ()<XMPPStreamDelegate,PJXMPPToolDelegate>
- (IBAction)login:(id)sender;
- (IBAction)regis:(id)sender;
- (IBAction)viewBackgroundTap:(UITapGestureRecognizer *)sender;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *secretField;

@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,strong) XMPPStream *xmppStream;
@property (nonatomic,strong) PJXMPPTool *xmppTool;




@end

@implementation PJLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;

    _xmppTool = [[PJXMPPTool alloc] init];
    _xmppTool.delegate = self;

    
}



- (IBAction)login:(id)sender
{
  [_xmppTool XMPPUserLoginWithAccount:self.accountField.text password:self.secretField.text];
    
 
}

- (IBAction)regis:(id)sender
{
    
}

- (IBAction)viewBackgroundTap:(UITapGestureRecognizer *)sender {
    [self.accountField resignFirstResponder];
    [self.secretField resignFirstResponder];
}
/**
 *  代理方法
 */
-(void)PJXMPPToolLoginStatus:(NSString *)status
{
    if ([_xmppTool.status isEqualToString:@"success"])
    {
        ViewController *view = [[ViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
    }
    else if([_xmppTool.status isEqualToString:@"faile"])
    {
        NSLog(@"登录失败");
    }

    
}


@end
