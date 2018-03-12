//
//  MyNewsTableViewController.h
//  idoubs
//
//  Created by Momo on 16/6/21.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseNewsTableViewController.h"
#import "iOSNgnStack.h"


@interface MyNewsTableViewController : BaseNewsTableViewController
{
    
@private
    NSMutableArray* messages;
    NgnContact *pickedContact;
    NgnPhoneNumber *pickedNumber;
}

@end
