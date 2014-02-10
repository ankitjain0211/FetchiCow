//
//  SNViewController.m
//  LocalNotification
//
//  Created by Ankit on 06/02/14.
//  Copyright (c) 2014 SourceN. All rights reserved.
//

#import "SNViewController.h"


@interface SNViewController ()
{
    NSDate *dateTime;
    NSMutableArray *allContactsArray;
    NSMutableArray *searchContactsArray;
    NSString *callToNumber;
    NSArray *alphabeticArray;
}

@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *alphabeticView;

@end

@implementation SNViewController

-(void)viewWillAppear:(BOOL)animated {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"NAVIGATE_BACK"] isEqualToString:@"YES"]) {
        SNLogTrace(@"%s", __PRETTY_FUNCTION__);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test" message:[NSString stringWithFormat:@"Inside ViewDidLoad"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
- (void)viewDidLoad
{
    SNLogTrace(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
     alphabeticArray = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    allContactsArray = [[NSMutableArray alloc] initWithCapacity:0];
    searchContactsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Get contacts
    [self getContacts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Address Book Method 
-(void)getContacts {
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                [self addContactToAddressBook];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied!", @"Access Denied!") message:@"Please goto settings and turn on the access." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self addContactToAddressBook];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied!", @"Access Denied!") message:@"Please goto settings and turn on the access." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)addContactToAddressBook {
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, nil, kABPersonSortByFirstName);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for(int i = 0; i < numberOfPeople; i++) {
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonCompositeNameFormatFirstNameFirst));
        NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        //NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        //NSLog(@"\n Name:%@ ", firstName);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        NSString *phoneNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        if(phoneNumber != NULL)
        {
            SNContacts *contact = [[SNContacts alloc] init];
            [contact setContactFirstName:firstName];
            [contact setContactNumber:phoneNumber];
            [contact setContactImage:imgData];
            
            [allContactsArray addObject:contact];
        }
        
       
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [allContactsArray count]; i++) {
        SNContacts *contact = [allContactsArray objectAtIndex:i];
        [tempArray addObject:contact.contactFirstName];
    }
    
    NSMutableArray *tempArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [alphabeticArray count]; i++) {
        for (NSString *str in tempArray) {
            if ([str hasPrefix:[alphabeticArray objectAtIndex:i]]) {
                [tempArray1 addObject:[alphabeticArray objectAtIndex:i]];
                break;
            }
        }
    }
    
    [self addButtonsOnAlphabeticViewAndSkip:tempArray1];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    //[rightUtilityButtons sw_addUtilityButtonWithColor:
     //[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] title:@"Favorite"];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            SNLogTrace(@"left button 0 was pressed");
            break;
        case 1:
            SNLogTrace(@"left button 1 was pressed");
            break;
        case 2:
            SNLogTrace(@"left button 2 was pressed");
            break;
        case 3:
            SNLogTrace(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.contactsTable indexPathForCell:cell];
            SNContacts *contact;
            if ([searchContactsArray count] > 0)
                contact = [searchContactsArray objectAtIndex:cellIndexPath.row];
            else
                contact = [allContactsArray objectAtIndex:cellIndexPath.row];
            
            callToNumber = contact.contactNumber;
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"DONE" destructiveButtonTitle:Nil otherButtonTitles:@"CALL", @"MESSAGE", nil];
            [actionSheet showInView:self.view];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            SNLogTrace(@"Delete button was pressed");
            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"Delete Delete Delete" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            [alertTest show];
            
            [cell hideUtilityButtonsAnimated:YES];
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - Actionsheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SNLogTrace(@"Button index %ld", (long)buttonIndex);
    switch (buttonIndex) {
        case 0:
        {
            NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel://%@",callToNumber]];
            [[UIApplication sharedApplication] openURL:url];
        }
        break;
        
        case 1:
        {
            if([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                controller.body = @"";
                [controller setRecipients:[NSArray arrayWithObject:callToNumber]];
                controller.messageComposeDelegate = self;
                [self presentViewController:controller animated:YES completion:nil];
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TaxiForSure" message:@"You cannot send SMS from this device" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }
        break;
            
        default:
            break;
    }
}

#pragma mark - MessageViewController delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
        {
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancelled" message:@"User cancelled sending the SMS"
            //                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            //            [alert show];
        }
            break;
        case MessageComposeResultFailed:
        {
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Error occured while sending the SMS"
            //                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            //            [alert show];
        }
            break;
        case MessageComposeResultSent:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TaxiForSure" message:@"Message sent successfully"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Tableview Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UMTableViewCell *cell = [self.contactsTable dequeueReusableCellWithIdentifier:@"UMCell" forIndexPath:indexPath];
    
    UMTableViewCell __weak *weakCell = cell;
    
    [cell setAppearanceWithBlock:^{
        //weakCell.leftUtilityButtons = [self leftButtons];
        weakCell.rightUtilityButtons = [self rightButtons];
        weakCell.delegate = self;
        weakCell.containingTableView = tableView;
    } force:NO];
    
    [cell setCellHeight:cell.frame.size.height];
    
    SNContacts *contact;
    if ([searchContactsArray count] > 0)
        contact = [searchContactsArray objectAtIndex:indexPath.row];
    else
        contact = [allContactsArray objectAtIndex:indexPath.row];

    UILabel *contactNameLbl = (UILabel *)[cell.contentView viewWithTag:1];
    //contactNameLbl.text = [allContactsArray objectAtIndex:indexPath.row];
    contactNameLbl.text = contact.contactFirstName;
    
    UILabel *imgLbl = (UILabel *)[cell.contentView viewWithTag:2];
    UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
    [imgTap setNumberOfTapsRequired:1];
    [imgLbl setUserInteractionEnabled:YES];
    [imgLbl addGestureRecognizer:imgTap];
    imgLbl.text = [[contactNameLbl.text substringToIndex:1] uppercaseString];
    
    if (contact.contactImage && [contact.contactImage length] > 0) {
        UIImageView *contactBgImage = (UIImageView *)[cell.contentView viewWithTag:3];
        [contactBgImage setImage:[UIImage imageWithData:contact.contactImage]];
        contactBgImage.layer.cornerRadius = contactBgImage.bounds.size.width / 2;
        [self applyTwoCornerMask:contactBgImage.layer withRadius:15];
        [imgLbl setHidden:YES];
    } else {
        UIImageView *contactBgImage = (UIImageView *)[cell.contentView viewWithTag:3];
        [contactBgImage setImage:[UIImage imageNamed:@"circle"]];
        [imgLbl setHidden:NO];
    }
    

    return cell;
}
-(void) applyTwoCornerMask: (CALayer *) layer withRadius: (CGFloat) radius {
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = layer.bounds;
    [mask setFillColor:[[UIColor blackColor] CGColor]];
    
    CGFloat width = layer.bounds.size.width;
    CGFloat height = layer.bounds.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, width, 0);
    CGPathAddLineToPoint(path, NULL, width, height - radius);
    CGPathAddCurveToPoint(path, NULL, width, height, width - radius, height, width - radius, height);
    CGPathAddLineToPoint(path, NULL, 0, height);
    CGPathAddLineToPoint(path, NULL, 0, radius);
    CGPathAddCurveToPoint(path, NULL, 0, 0, radius, 0, radius, 0);
    CGPathCloseSubpath(path);
    [mask setPath:path];
    CGPathRelease(path);
    
    layer.mask = mask;
}

-(void)imageTapped{
    SNLogTrace(@"%s", __PRETTY_FUNCTION__);
    if ([searchContactsArray count] > 0) {
        return;
    }
    [self.alphabeticView setHidden:NO];
}

- (void)alphabetTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    SNLogTrace(@"Alphabetic tapped was %@", btn.titleLabel.text);
    NSInteger newRow = [self indexForFirstChar:btn.titleLabel.text inArray:allContactsArray];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newRow inSection:0];
    [_contactsTable scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self.alphabeticView setHidden:YES];
}

-(void)addButtonsOnAlphabeticViewAndSkip:(NSArray *)alphabeticArray1
{
    SNLogTrace(@"%s", __PRETTY_FUNCTION__);
    int yValue = 20;
    int xValue = -64;
    
    for (int i = 0; i < [alphabeticArray1 count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(alphabetTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[alphabeticArray1 objectAtIndex:i] forState:UIControlStateNormal];
        
        if (i%4 == 0 && i != 0) {
            //SNLogTrace(@"if loop having i value %d", i);
            xValue = 13;
            yValue = yValue + 64 + 6;
        } else {
            //SNLogTrace(@"else loop having i value %d", i);
            xValue = xValue + 64 + 13;
        }
        
        button.frame = CGRectMake(xValue, yValue, 64.0f, 64.0f);
        [self.alphabeticView addSubview:button];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([searchContactsArray count] > 0) {
        return [searchContactsArray count];
    }
    return [allContactsArray count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    NSInteger newRow = [self indexForFirstChar:title inArray:allContactsArray];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newRow inSection:0];
    [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    return index;
}

// Return the index for the location of the first item in an array that begins with a certain character
- (NSInteger)indexForFirstChar:(NSString *)character inArray:(NSArray *)array
{
    SNLogTrace(@"%s", __PRETTY_FUNCTION__);
    NSUInteger count = 0;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [array count]; i++) {
        SNContacts *contact = [allContactsArray objectAtIndex:i];
        [tempArray addObject:contact.contactFirstName];
    }
    
    for (NSString *str in tempArray) {
        if ([str hasPrefix:character]) {
            return count;
        }
        count++;
    }
    return 0;
}


-(void)searchString:(NSString *)searchString {
    SNLogTrace(@"%s", __PRETTY_FUNCTION__);
    [searchContactsArray removeAllObjects];
    for (int i = 0; i < [allContactsArray count]; i++) {
        SNContacts *contact = [allContactsArray objectAtIndex:i];
        SNLogTrace(@"Search %@ in contact %@", searchString, contact.contactFirstName);
        if ([[contact.contactFirstName lowercaseString] hasPrefix:[searchString lowercaseString]]) {
            SNLogTrace(@"matching name %@", contact.contactFirstName);
            [searchContactsArray addObject:contact];
        }
    }
    [_contactsTable reloadData];
}

#pragma mark - Searchbar Delegate 

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    SNLogTrace(@"%s", __PRETTY_FUNCTION__);
    BOOL isBackButton;
    
    if (range.location != NSNotFound)
    {
        // String was found
        if (range.length == 0)
        {
            isBackButton = NO;
        }
        else
        {
            isBackButton = YES;
        }
    }
    else
    {
        // String not found
        isBackButton = NO;
    }
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    if (isBackButton)
    {
        NSString *str = [NSString stringWithFormat:@"%@", [searchBar.text stringByTrimmingCharactersInSet:whitespace]];
        //LogTrace(@"str length %d", [[str substringToIndex:[str length]-1] length]);
        if ( [str length] > 1)
        {
            [self searchString:[str substringToIndex:[str length]-1]];
            // [str substringToIndex:[str length]-1]
            
        }
        else if ([str length] > 0 && [str length] == 1){
            [self searchString:str];
        }
    }
    else
    {
        NSString *str = [[NSString stringWithFormat:@"%@%@", searchBar.text, text] stringByTrimmingCharactersInSet:whitespace];
        if ([str length] > 0)
        {
            [self searchString:str];
        }
    }
    return YES;
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    SNLogTrace(@"%s", __PRETTY_FUNCTION__);
    if ([searchBar.text length] == 0) {
        SNLogTrace(@"%s", __PRETTY_FUNCTION__);
        // On clearing text
        [searchContactsArray removeAllObjects];
        [_contactsTable reloadData];
    }
}


/*
- (IBAction)datePicker:(id)sender {
    UIDatePicker * date = (UIDatePicker *)sender;
    dateTime = date.date;
}
- (IBAction)setLocalNotificationTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Awesome!" message:@"Your notification has been set" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = dateTime;
    notification.alertBody = [NSString stringWithFormat:@"Time now is %@", dateTime];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    NSDictionary *userInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"OK", @"status", nil];
    notification.userInfo = userInfoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
*/

@end
