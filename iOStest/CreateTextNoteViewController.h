//
//  CreateTextNoteViewController.h
//  iOStest
//
//  Created by Neftali Reviriego on 31/12/15.
//  Copyright © 2015 Neftali Reviriego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENSDK.h"

@interface CreateTextNoteViewController : UIViewController

@property (nonatomic, weak) ENNotebook *notebook;

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;

@property (nonatomic, weak) IBOutlet UITextView *bodyTextView;

@end
