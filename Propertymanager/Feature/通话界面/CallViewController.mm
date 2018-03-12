/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of
 * the GNU General Public License as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
#import "CallViewController.h"

#import "AppDelegate.h"
#import "LookEntranceVedioViewController.h"
//
// private implementation
//
@interface CallViewController(Private)
+(BOOL) presentSession: (NgnAVSession*)session;
@end

@implementation CallViewController(Private)

#pragma mark - 来电页面跳转
+(BOOL) presentSession: (NgnAVSession*)session{

    
    if(session){
    
        //获取当前的控制器
        
        
        UIViewController * currentVC = [UIViewController currentViewController];
        
        if (![NSStringFromClass([MyRootViewController class]) isEqualToString:NSStringFromClass([[AppDelegate sharedInstance].window.rootViewController class])]) {
            NSLog(@"根页面不是 MyRootViewController");
            return NO;
        }
        
        
        if ([NSStringFromClass([AudioCallViewController class]) isEqualToString:NSStringFromClass([currentVC class])]) {
            NSLog(@"当前页面是 AudioCallViewController");
            return NO;
        }
        
        if ([NSStringFromClass([VideoCallViewController class]) isEqualToString:NSStringFromClass([currentVC class])]) {
            NSLog(@"当前页面是 VideoCallViewController");
            return NO;
        }
        
        if ([NSStringFromClass([LookEntranceVedioViewController class]) isEqualToString:NSStringFromClass([currentVC class])]) {
            NSLog(@"当前页面是 LookEntranceVedioViewController");
            return NO;
        }

        MyRootViewController * rootVC = (MyRootViewController *)[AppDelegate sharedInstance].window.rootViewController;
        ContactModel * model = [PMSipTools gainContactModelFromSipNum:session.historyEvent.remoteParty];
        NSString * name = [NSString stringWithFormat:@"%@",session.historyEvent.remoteParty];
        if (model) {
            name = model.fworkername;
        }
        if ([session.historyEvent.remoteParty isEqualToString:[UserManagerTool userManager].user_sip]) {
            session.isMyself = YES;
        }

        
        
        if(isVideoType(session.mediaType)){
            
            
            VideoCallViewController * videoCallController = [[VideoCallViewController alloc] init];
            
            videoCallController.sessionId = session.id;
            videoCallController.workname = name;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [rootVC presentViewController:videoCallController animated:YES completion:nil];
            });
            
   
            return YES;
        }
        else if(isAudioType(session.mediaType)){

            
            
            AudioCallViewController * audioCallController = [[AudioCallViewController alloc] init];
            audioCallController.sessionId = session.id;
            audioCallController.workname = name;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [rootVC presentViewController:audioCallController animated:YES completion:nil];
            });

            return YES;
        }
    }
    
    return NO;
}

@end

@implementation CallViewController

@synthesize sessionId;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

+(BOOL) makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack withName:(NSString *) name{
    if(![PMTools isNullOrEmpty:remoteUri]){
        NgnAVSession* audioSession = [[NgnAVSession makeAudioCallWithRemoteParty: remoteUri andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]] retain];
        
        if ([remoteUri isEqualToString:[UserManagerTool userManager].user_sip]) {
            audioSession.isMyself = YES;
        }
        
        if(audioSession){
            
            AudioCallViewController * audioCallController = [[AudioCallViewController alloc] init];
            audioCallController.sessionId = audioSession.id;
            audioCallController.workname = name;
            audioCallController.buttonAccept.hidden = YES;
            
            //获取当前的控制器
            MyRootViewController * rootVC = (MyRootViewController *)[AppDelegate sharedInstance].window.rootViewController;
            UIViewController * modalViewController = rootVC;
            dispatch_async(dispatch_get_main_queue(), ^{
                [modalViewController presentViewController:audioCallController animated:YES completion:nil];
                [audioSession release];
            });
   
            return YES;
        }
    }
    return NO;
}

+(BOOL) makeAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack withName:(NSString *)name{
    if(![PMTools isNullOrEmpty:remoteUri]){
        NgnAVSession* videoSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty: remoteUri
                                                                          andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]] retain];
        if ([remoteUri isEqualToString:[UserManagerTool userManager].user_sip]) {
            videoSession.isMyself = YES;
        }
        
        if(videoSession){
            
            VideoCallViewController * videoCallController = [[VideoCallViewController alloc]init];
            videoCallController.sessionId = videoSession.id;
            videoCallController.workname = name;
            videoCallController.buttonAccept.hidden = YES;
            
            //获取当前的控制器
            MyRootViewController * rootVC = (MyRootViewController *)[AppDelegate sharedInstance].window.rootViewController;
            UIViewController * modalViewController = rootVC;
            dispatch_async(dispatch_get_main_queue(), ^{
                [modalViewController presentViewController:videoCallController animated:YES completion:nil];
                [videoSession release];
            });
      
            return YES;
        }
    }
    return NO;
}



#pragma mark - 门禁解锁页面的跳转

+(BOOL) makeEntranceAudioVideoCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack withDomain_sn:(NSString *)domain_sn{
    if(![PMTools isNullOrEmpty:remoteUri]){
        NgnAVSession* videoSession = [[NgnAVSession makeAudioVideoCallWithRemoteParty: remoteUri
                                                                          andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]] retain];
        videoSession.isEntrance = YES;
        
        if(videoSession){
            
            //获取当前的控制器
            MyRootViewController * rootVC = (MyRootViewController *)[AppDelegate sharedInstance].window.rootViewController;
            UINavigationController * nav = rootVC.midViewController;
            UIViewController * modalViewController = [nav.viewControllers lastObject];
            
            [AppDelegate sharedInstance].lookEntranceViewController.sessionId = videoSession.id;
            [AppDelegate sharedInstance].lookEntranceViewController.domain_sn = domain_sn;
            [AppDelegate sharedInstance].lookEntranceViewController.sipnum = remoteUri;
            
            
            // 拨打门口机呈静音状态
            [videoSession setMute:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [modalViewController presentViewController:[AppDelegate sharedInstance].lookEntranceViewController animated:YES completion:nil];
                [videoSession release];
            });

            return YES;
        }
    }
    return NO;
}

+(BOOL) receiveIncomingCall: (NgnAVSession*)session{
    return [CallViewController presentSession:session];
}

+(BOOL) displayCall: (NgnAVSession*)session{
    if(session){
        return [CallViewController presentSession:session];
    }
    return NO;
}

- (void)dealloc {
    [super dealloc];
}
@end
