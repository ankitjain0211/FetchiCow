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
}

@end

@implementation SNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,error);
    
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef sortedPeople =ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
    
    //RETRIEVING THE FIRST NAME AND PHONE NUMBER FROM THE ADDRESS BOOK
    
    CFIndex number = CFArrayGetCount(sortedPeople);
    NSString *firstName;
    NSString *phoneNumber ;
    
    for( int i=0;i<number;i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(sortedPeople, i);
        firstName = (__bridge NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty);
        
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        phoneNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phones, 0);
         NSLog(@"First Name %@", firstName);
        if(phoneNumber != NULL)
        {
            SNContacts *contact = [[SNContacts alloc] init];
            [contact setContactFirstName:firstName];
            [contact setContactNumber:phoneNumber];
            
            [allContactsArray addObject:contact];
        }
    }
    
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
    
    SNContacts *contact;
    if ([searchContactsArray count] > 0)
        contact = [searchContactsArray objectAtIndex:indexPath.row];
    else
        contact = [allContactsArray objectAtIndex:indexPath.row];
    
    UILabel *contactNameLbl = (UILabel *)[cell viewWithTag:1];
    contactNameLbl.text = contact.contactFirstName;
    
    UILabel *imgLbl = (UILabel *)[cell viewWithTag:2];
    imgLbl.text = [contactNameLbl.text substringToIndex:1];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
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
    NSLog(@"%s", __PRETTY_FUNCTION__);
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
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [searchContactsArray removeAllObjects];
    for (int i = 0; i < [allContactsArray count]; i++) {
        SNContacts *contact = [allContactsArray objectAtIndex:i];
        NSLog(@"Search %@ in contact %@", searchString, contact.contactFirstName);
        if ([[contact.contactFirstName lowercaseString] hasPrefix:[searchString lowercaseString]]) {
            NSLog(@"matching name %@", contact.contactFirstName);
            [searchContactsArray addObject:contact];
        }
    }
    [_contactsTable reloadData];
}

#pragma mark - Tableview Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_contactSearchBar resignFirstResponder];
    SNContacts *contact;
    if ([searchContactsArray count] > 0)
        contact = [searchContactsArray objectAtIndex:indexPath.row];
    else
        contact = [allContactsArray objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:contact.contactFirstName message:contact.contactNumber delegate:Nil cancelButtonTitle:@"Don't Call" otherButtonTitles: @"Call", nil];
    [alert show];
}

#pragma mark - Searchbar Delegate 

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - TextField Delegate Methods

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"%s", __PRETTY_FUNCTION__);
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

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([searchBar.text length] == 0) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
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
