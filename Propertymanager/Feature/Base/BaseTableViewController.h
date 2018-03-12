//
//  BaseTableViewController.h
//  PropertyManager
//
//  Created by Momo on 16/12/23.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableview;

@end
