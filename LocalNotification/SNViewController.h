//
//  SNViewController.h
//  LocalNotification
//
//  Created by Ankit on 06/02/14.
//  Copyright (c) 2014 SourceN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>
#import "SNContacts.h"
#import "SWTableViewCell.h"
#import "UMTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SNViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UISearchBarDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *contactsTable;

- (IBAction)alphabetTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backbtn;

@end
