//
//  CreateTextNoteViewController.h
//  iOStest
//
//  Created by Neftali Reviriego on 31/12/15.
//  Copyright © 2015 Neftali Reviriego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENSDK.h"

@protocol CreateTextNoteDelegate;

@interface CreateTextNoteViewController : UIViewController

@property (nonatomic, weak) ENNotebook *notebook;

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;

@property (nonatomic, weak) IBOutlet UITextView *bodyTextView;

@property (weak, nonatomic) id<CreateTextNoteDelegate> delegate;

@end

@protocol CreateTextNoteDelegate <NSObject>

- (void) createTextNoteViewControllerDidCreateNote:(CreateTextNoteViewController*)createTextNoteViewController;

@end