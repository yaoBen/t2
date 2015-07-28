//
//  TestViewController.h
//  westars
//
//  Created by developer on 15/6/6.
//  Copyright (c) 2015年 westars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end
