//
//  ViewController.m
//  ChatMessageTableViewController
//
//  Created by Yongchao on 21/11/13.
//  Copyright (c) 2013 Yongchao. All rights reserved.
//

#import "ViewController.h"
#import "PJNavgationController.h"
#import "XMPPFramework.h"

@interface ViewController () <JSMessagesViewDelegate, JSMessagesViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,XMPPStreamDelegate>

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (nonatomic,strong) UIImage *willSendImage;
@property (strong, nonatomic) NSMutableArray *timestamps;

@property (nonatomic,strong) XMPPStream *xmppStream;

@end

@implementation ViewController

@synthesize messageArray;


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"@pan1";
    self.delegate = self;
    self.dataSource = self;
    self.navigationController.navigationBarHidden = NO;
    self.messageArray = [NSMutableArray array];
    self.timestamps = [NSMutableArray array];
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppStream = [delegate xmppStream];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    [self.messageArray addObject:[NSDictionary dictionaryWithObject:text forKey:@"Text"]];
    //当前时间
    [self.timestamps addObject:[NSDate date]];
    
    if((self.messageArray.count - 1) % 2)
        [JSMessageSoundEffect playMessageSentSound];
    else
        [JSMessageSoundEffect playMessageReceivedSound];
    
    [self finishSend];
    [self sendMessage:text];
}

- (void)cameraPressed:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = messageArray[indexPath.row];
    NSString *status = [dict objectForKey:@"Status"];
    if ([status isEqualToString:@"incoming"])
    {
        return JSBubbleMessageTypeIncoming;
    }
    else
    {
        return JSBubbleMessageTypeOutgoing;
    }
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]){
        return JSBubbleMediaTypeText;
    }else if ([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"]){
        return JSBubbleMediaTypeImage;
    }
    
    return -1;
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    /*
     JSMessagesViewTimestampPolicyAll = 0,
     JSMessagesViewTimestampPolicyAlternating,
     JSMessagesViewTimestampPolicyEveryThree,
     JSMessagesViewTimestampPolicyEveryFive,
     JSMessagesViewTimestampPolicyCustom
     */
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /*
     JSMessagesViewAvatarPolicyIncomingOnly = 0,
     JSMessagesViewAvatarPolicyBoth,
     JSMessagesViewAvatarPolicyNone
     */
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleCircle;
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat

     */
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]){
        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"];
    }
    return nil;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImage *)avatarImageForIncomingMessage
{
    return [UIImage imageNamed:@"demo-avatar-jobs"];
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return [UIImage imageNamed:@"demo-avatar-woz"];
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"]){
        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"];
    }
    return nil;
    
}

#pragma UIImagePicker Delegate

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Chose image!  Details:  %@", info);
    
    self.willSendImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.messageArray addObject:[NSDictionary dictionaryWithObject:self.willSendImage forKey:@"Image"]];
    [self.timestamps addObject:[NSDate date]];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    
	
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

//获取消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *mess = [[message elementForName:@"body"] stringValue];
    NSString *status = @"incoming";
    if(mess)
    {
        NSDictionary *messagedict = [NSDictionary dictionaryWithObjectsAndKeys:mess,@"Text",status,@"Status",nil];
        [self.messageArray addObject:messagedict];
        //当前时间
        [self.timestamps addObject:[NSDate date]];
        
    }
    [self finishSend];

}
- (void)sendMessage:(NSString *)mess
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:mess];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    NSString *to = @"pan1@panyangjun.local";
    [message addAttributeWithName:@"to" stringValue:to];
    [message addChild:body];
    [self.xmppStream sendElement:message];
}
@end
