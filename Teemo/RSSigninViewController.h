//
//  RSSigninViewController.h
//  Teemo
//
//  Created by Wu Kevin on 11/6/13.
//  Copyright (c) 2013 xbcx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSViewController.h"

@interface RSSigninViewController : RSViewController<
    UITableViewDataSource,
    UITableViewDelegate
> {
  UITableView *_tableView;
}

@end