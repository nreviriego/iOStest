//
//  ViewAppNotesViewController.m
//  evernote-sdk-ios
//
//  Created by Ben Zotto on 5/22/14.
//  Copyright (c) 2014 Evernote Corporation. All rights reserved.
//

#import "NoteListResultViewController.h"
#import "NoteDetailViewController.h"
#import "SVProgressHUD.h"
#import "CommonUtils.h"
#import "CreateTextNoteViewController.h"

NSString *const pushCreateTextNoteSegueID = @"pushCreateTextNote";

@interface NoteListResultViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) ENNoteSearch *noteSearch;
@property (nonatomic, strong) ENNotebook *notebookToSearch;
@property (nonatomic, strong) NSArray * findNotesResults;
@property (nonatomic, strong) NSMutableDictionary * thumbnails;
@end

@implementation NoteListResultViewController

- (void)setNoteSearch:(ENNoteSearch *)search notebook:(ENNotebook *)notebook{
    self.noteSearch = search;
    self.notebookToSearch = notebook;
}

- (void)loadView
{
    [super loadView];
    
    self.thumbnails = [[NSMutableDictionary alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Notes";
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    [[ENSession sharedSession] findNotesWithSearch:self.noteSearch
                                        inNotebook:self.notebookToSearch
                                           orScope:ENSessionSearchScopeAll
                                         sortOrder:ENSessionSortOrderRecentlyCreated
                                        maxResults:0
                                        completion:^(NSArray *findNotesResults, NSError *findNotesError) {
                                            [SVProgressHUD dismiss];
                                            if (!findNotesResults) {
                                                if ([findNotesError.domain isEqualToString:ENErrorDomain] &&
                                                    findNotesError.code == ENErrorCodePermissionDenied) {
                                                    [CommonUtils showSimpleAlertWithMessage:@"Permission denied for note find. Maybe your app only has read access?"];
                                                } else {
                                                    [CommonUtils showSimpleAlertWithMessage:@"Error searching for notes"];
                                                }
                                                NSLog(@"findNotesError: %@", findNotesError);
                                            } else if (findNotesResults.count == 0) {
                                                [CommonUtils showSimpleAlertWithMessage:@"No notes found."];
                                            } else {
                                                self.findNotesResults = findNotesResults;
                                                [self.tableView reloadData];
                                            }
                                        }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.findNotesResults) {
        return self.findNotesResults.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    ENSessionFindNotesResult * result = self.findNotesResults[indexPath.row];
    cell.textLabel.text = result.title;
    UIImage * knownThumbnail = self.thumbnails[result.noteRef];
    if (knownThumbnail) {
        cell.imageView.image = knownThumbnail;
    } else {
        [[ENSession sharedSession] downloadThumbnailForNote:result.noteRef
                                               maxDimension:100
                                                 completion:^(UIImage *thumbnail, NSError *downloadNoteThumbnailError) {
                                                     if (thumbnail) {
                                                         self.thumbnails[result.noteRef] = thumbnail;
                                                         [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                     }
                                                 }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENSessionFindNotesResult * result = self.findNotesResults[indexPath.row];
    NoteDetailViewController * vc = [[NoteDetailViewController alloc] init];
    vc.noteRef = result.noteRef;
    vc.noteTitle = result.title;
    [self.navigationController pushViewController:vc animated:YES];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [(CreateTextNoteViewController*)segue.destinationViewController setNotebook:_notebookToSearch];
}
@end
