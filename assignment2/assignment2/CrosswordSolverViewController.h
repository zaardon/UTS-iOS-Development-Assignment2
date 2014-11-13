//
//  CrosswordSolverViewController.h
//  assignment2
//
//  Created by Alex Smith on 9/10/2014.
//  Copyright (c) 2014 Alex Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"
#import "DictionaryHandler.h"

@interface CrosswordSolverViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *anagramField;
@property (weak, nonatomic) IBOutlet UITextField *patternField;
@property (weak, nonatomic) IBOutlet UITextField *sizeField;
@property (weak, nonatomic) IBOutlet UITextView *resultsTextView;
@property DictionaryHandler* dictionaryList;

- (void) handleBackgroundTap: (UITapGestureRecognizer*) sender;
- (IBAction)onDismissKeyboard:(id)sender;
- (IBAction)onSearchForResults:(id)sender;

@end
