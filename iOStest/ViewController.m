//
//  ViewController.m
//  iOStest
//
//  Created by Neftali Reviriego on 30/12/15.
//  Copyright © 2015 Neftali Reviriego. All rights reserved.
//

#import "ViewController.h"
#import <ENSDK.h>
#import "SVProgressHUD.h"
#import "NoteListResultViewController.h"

NSString *const pushNoteListSegueID = @"pushNoteList";

@interface ViewController ()

@property (nonatomic, strong) NSArray *notebookList;
@property (nonatomic, strong) UIBarButtonItem *createNewNotebookItem;
@property (nonatomic) BOOL creatingBusinessNotebook;
@property (nonatomic, strong) UIBarButtonItem * loginItem;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.loginItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(logInOrLogOut)];
    self.navigationItem.rightBarButtonItem = _loginItem;
    [self updateLoginItem];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self update];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLoginItem {
    BOOL loggedIn = [[ENSession sharedSession] isAuthenticated];
    [self.loginItem setTitle:(loggedIn? NSLocalizedString(@"Logout", @"Logout"): NSLocalizedString(@"Login", @"Login"))];
}


- (void)logInOrLogOut {
    if ([[ENSession sharedSession] isAuthenticated]) {
        [[ENSession sharedSession] unauthenticate];
        [self update];
    } else {
        [[ENSession sharedSession] authenticateWithViewController:self
                                               preferRegistration:NO
                                                       completion:^(NSError *authenticateError) {
                                                           if (!authenticateError) {
                                                               [self update];
                                                           } else if (authenticateError.code != ENErrorCodeCancelled) {
                                                               [[[UIAlertView alloc] initWithTitle:nil
                                                                                           message:@"Could not authenticate."
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:nil
                                                                                 otherButtonTitles:@"OK", nil] show];
                                                           }
                                                       }];
    }
}



- (void)update
{
    if ([[ENSession sharedSession] isAuthenticated]) {
        [self.navigationItem setTitle:[[ENSession sharedSession] userDisplayName]];
    } else {
        [self.navigationItem setTitle:nil];
    }
    [self updateLoginItem];
    
    [self reloadNotebooks];
}

- (void)reloadNotebooks {
    
    if ([[ENSession sharedSession] isAuthenticated]) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        __weak typeof(self) weakSelf = self;
        [[ENSession sharedSession] listNotebooksWithCompletion:^(NSArray *notebooks, NSError *listNotebooksError) {
            [SVProgressHUD dismiss];
            if (listNotebooksError) {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:[listNotebooksError localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
                return;
            }
            
            weakSelf.notebookList = notebooks;
            [weakSelf.tableView reloadData];
        }];
    }
    else{
        
        self.notebookList = [NSArray array];
        [self.tableView reloadData];
    }
    
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![[ENSession sharedSession] isAuthenticated]) {
    
        return 0;
    }
    return [self.notebookList count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notebook"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notebook"];
    }
    NSString *nameToDisplay;
    if (indexPath.row == 0) {
        nameToDisplay = NSLocalizedString(@"All Notes", @"All Notes");
        nameToDisplay = [NSString stringWithFormat:@"* %@", nameToDisplay];
    }
    else{
    
        ENNotebook *notebook = [self.notebookList objectAtIndex:indexPath.row - 1];
        nameToDisplay = notebook.name;
        if (notebook.isBusinessNotebook) {
            nameToDisplay = [NSString stringWithFormat:@"🏢 %@", nameToDisplay];
        } else if (notebook.isShared) {
            nameToDisplay = [NSString stringWithFormat:@"👥 %@", nameToDisplay];
        } else {
            nameToDisplay = [NSString stringWithFormat:@"👤 %@", nameToDisplay];
        }

    }
    [cell.textLabel setText:nameToDisplay];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ENNotebook *notebook = nil;
    if (indexPath.row > 0) {
        notebook = [self.notebookList objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:pushNoteListSegueID sender:notebook];
//    NoteListResultViewController *resultVC = [[NoteListResultViewController alloc] initWithNoteSearch:nil notebook:notebook];
//    [self.navigationController pushViewController:resultVC animated:YES];
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [(NoteListResultViewController*)segue.destinationViewController setNoteSearch:nil notebook:sender];
    
}
@end
