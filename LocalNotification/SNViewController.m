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
}

@end

@implementation SNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    allContactsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //find the UITextField view within searchBar (outlet to UISearchBar)
    //and assign self as delegate
    for (UIView *view in _contactSearchBar.subviews){
        if ([view isKindOfClass: [UITextField class]]) {
            UITextField *tf = (UITextField *)view;
            tf.delegate = self;
            break;
        }
    }
    
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
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,error);
    
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef sortedPeople =ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
    
    //RETRIEVING THE FIRST NAME AND PHONE NUMBER FROM THE ADDRESS BOOK
    
    CFIndex number = CFArrayGetCount(sortedPeople);
    NSString *firstName;
    NSString *phoneNumber ;
    
    for( int i=0;i<number;i++)
    {
        NSMutableDictionary *eachPerson =  [NSMutableDictionary dictionaryWithCapacity:0];
        ABRecordRef person = CFArrayGetValueAtIndex(sortedPeople, i);
        firstName = (__bridge NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty);
        
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        phoneNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phones, 0);
         NSLog(@"First Name %@", firstName);
        if(phoneNumber != NULL)
        {
            [eachPerson setValue:firstName forKey:@"firstName"];
            [eachPerson setValue:phoneNumber forKey:@"phoneNumber"];
            [allContactsArray addObject:eachPerson];
        }
    }
    
    NSLog(@"fetched contatcs count -%lu- %@", allContactsArray.count, allContactsArray);
    [_contactsTable reloadData];
}

#pragma mark - Tableview Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"customeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    UILabel *contactNameLbl = (UILabel *)[cell viewWithTag:1];
    contactNameLbl.text = [[allContactsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    NSUInteger count = 0;
    for (NSString *str in [array valueForKey:@"firstName"]) {
        if ([str hasPrefix:character]) {
            return count;
        }
        count++;
    }
    return 0;
}


#pragma mark - Tableview Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_contactSearchBar resignFirstResponder];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[allContactsArray objectAtIndex:indexPath.row] valueForKey:@"firstName"] message:[[allContactsArray objectAtIndex:indexPath.row] valueForKey:@"phoneNumber"] delegate:Nil cancelButtonTitle:@"Don't Call" otherButtonTitles: @"Call", nil];
    [alert show];
}

#pragma mark - Searchbar Delegate 

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - TextField Delegate Methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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
        NSString *str = [NSString stringWithFormat:@"%@", [textField.text stringByTrimmingCharactersInSet:whitespace]];
        //LogTrace(@"str length %d", [[str substringToIndex:[str length]-1] length]);
        if ( [str length] > 1)
        {
            // [str substringToIndex:[str length]-1]
           
        }
        else if ([str length] > 0 && [str length] == 1){
            
        }
    }
    else
    {
        NSString *str = [[NSString stringWithFormat:@"%@%@", textField.text, string] stringByTrimmingCharactersInSet:whitespace];
        if ([str length] > 0)
        {
            
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    // On clearing text
    [_contactsTable reloadData];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
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
