//
//  SNViewController.h
//  LocalNotification
//
//  Created by Ankit on 06/02/14.
//  Copyright (c) 2014 SourceN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface SNViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

@end