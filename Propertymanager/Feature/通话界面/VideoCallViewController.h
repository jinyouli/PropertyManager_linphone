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
#import "PSTAlertController.h"

@interface VideoCallViewController : CallViewController {

	
	NgnAVSession* videoSession;
	BOOL sendingVideo;
    
    BOOL isOnLine;
}

@property (nonatomic,strong) NSString * workname;

@property (retain, nonatomic) NSTimer* timerQoS;

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIView* viewLocalVideo;

@property (strong, nonatomic) iOSGLView * glViewVideoRemote;


@property (strong, nonatomic) UIView* viewTop;
@property (strong, nonatomic) UIImageView *myIconImageView;
@property (strong, nonatomic) UILabel *nameL;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) UIButton *buttonAccept;
@property (strong, nonatomic) UIButton *buttonHangup;
@property (strong, nonatomic) UIButton *handsFreeBtn;
@property (strong, nonatomic) UIButton *muteBtn;



@property (strong, nonatomic) UIView* viewToolbar;
@property (strong, nonatomic) UIButton *buttonToolBarMute;
@property (strong, nonatomic) UIButton *buttonToolBarEnd;
@property (strong, nonatomic) UIButton *buttonToolBarToggle;


@property (nonatomic,assign) BOOL isDail;

@property (strong, nonatomic) PSTAlertController *dismiss;

-(void)btnToggleClick;


@end
