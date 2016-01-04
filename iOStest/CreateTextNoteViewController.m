//
//  CreateTextNoteViewController.m
//  iOStest
//
//  Created by Neftali Reviriego on 31/12/15.
//  Copyright © 2015 Neftali Reviriego. All rights reserved.
//

#import "CreateTextNoteViewController.h"

@interface CreateTextNoteViewController ()

@end

@implementation CreateTextNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self configureInitialInterface];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) configureInitialInterface{

    //Round Aspect
    _bodyTextView.layer.borderWidth = 1;
    _bodyTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _bodyTextView.layer.cornerRadius = 5;
    
    //Localize Strings
    
    _bodyTextView.text = NSLocalizedString(@"Note Text ...", @"Note Text ...");
    _titleTextField.text = NSLocalizedString(@"Note Title", @"Note Title");


}



#pragma mark - Action Methods

- (IBAction)saveNoteAndClose:(id)sender
{

    ENNote * note = [[ENNote alloc] init];
    note.content = [ENNoteContent noteContentWithString:_bodyTextView.text];
    note.title = _titleTextField.text;
//    adding images in next release
//    ENResource * resource = [[ENResource alloc] initWithImage:myImage]; // myImage is a UIImage object.
//    [note addResource:resource];
    
    __weak typeof(self) weakSelf = self;
    
    [[ENSession sharedSession] uploadNote:note notebook:_notebook completion:^(ENNoteRef * noteRef, NSError * uploadNoteError) {
        if (uploadNoteError) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:[uploadNoteError localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            return;
        }

        [weakSelf.navigationController popViewControllerAnimated:YES];
        [weakSelf.delegate createTextNoteViewControllerDidCreateNote:weakSelf];
        
    }];

}


@end
