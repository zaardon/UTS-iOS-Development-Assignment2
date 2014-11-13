//
//  CrosswordSolverViewController.m
//  assignment2
//
//  Created by Alex Smith on 9/10/2014.
//  Copyright (c) 2014 Alex Smith. All rights reserved.
//

#import "CrosswordSolverViewController.h"

@interface CrosswordSolverViewController ()

@end

@implementation CrosswordSolverViewController
@synthesize anagramField;
@synthesize patternField;
@synthesize sizeField;
@synthesize resultsTextView;
@synthesize dictionaryList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Declares and loads the dictionary
    dictionaryList = [[DictionaryHandler alloc] init];
    [dictionaryList createDictionaryList];
    
    //A tap recogniser to handle background tapping
    UITapGestureRecognizer* tapRecogniser = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(handleBackgroundTap:)];
    tapRecogniser.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecogniser];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSearchForResults:(id)sender
{
    [self resignAllFirstResponders];    //Hides the keyboard when the search button is pressed
    NSString* anagram = [anagramField.text lowercaseString];
    NSString* pattern = [patternField.text lowercaseString];
    NSString* wordSizes = sizeField.text;
    NSMutableArray* crosswordResults = [[NSMutableArray alloc] init];
    
    //If the word size is NOT correct...
    if(![self wordSizeIsCorrect])
    {
        [self printError:@"Error: Word Size field does not contain correct input"];
    }
    //If the pattern/anagram size is correct...
    else if([self anagramOrPatternHaveCorrectSizes])
    {
        //If the pattern/anagram fields are the correct format...
        if([self anagramFieldIsCorrect] && [self patternFieldIsCorrect])
        {
            crosswordResults = [dictionaryList returnCrosswordSearchSolutionWith:wordSizes
                                                                      andLetters:anagram
                                                                      andPattern:pattern];
            //If there are results...
            if([crosswordResults count] != 0)
            {
                //Place each found result onto the text view, starting on a new line for each one
                [resultsTextView setText:[crosswordResults componentsJoinedByString:@"\n"]];
            }
            else
            {
                [resultsTextView setText:@"No results found!"];
            }
        }
        else
        {
            [self printError:@"Error: Incorrect format in Pattern and/or Anagram field"];
        }
    }
    else
    {
        [self printError:
         @"Error: Check if the total number of characters are the same in the required fields"];
    }
}

- (void)printError:(NSString*)errorMessage
{
    //Displays an UI alart for a given error message
    UIAlertView *alartMessage = [[UIAlertView alloc] initWithTitle:@"Crossword Solver"
                                                           message:errorMessage
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
    
    [alartMessage show];
}

- (bool)wordSizeHasCorrectCharacters
{
    NSString* wordSizes = sizeField.text;
    int lastDigit = ([wordSizes length] - 1);
    
    //If the first character is not a number...
    if(!isdigit([wordSizes characterAtIndex:0]))
    {
        return false;
    }
    
    //If the last character is not a number...
    if(!isdigit([wordSizes characterAtIndex:lastDigit]))
    {
        return false;
    }
    
    //For each character in the size field...
    for(int i = 0; i < [wordSizes length]; i++)
    {
        //Check if the character is a number...
        if(isdigit([wordSizes characterAtIndex:i]))
        {
            continue;
        }
        //... Or is an ',' character...
        else if([wordSizes characterAtIndex:i] == ',')
        {
            //...Aswell, check if there are repeating ','s in a row...
            if([wordSizes characterAtIndex:i] == [wordSizes characterAtIndex:i-1])
            {
                return false;
            }
            
            continue;
        }
        //Else, the characters are an incorrect format.
        else
        {
            return false;
        }
    }
    return true;
}

- (bool)wordSizeIsCorrect
{
    int const MAXWORDSIZECOMBINED = 120;
    int const MAXWORDSIZE = 30;
    int const MAXNUMBEROFWORDS = 4;
    NSString* wordSizes = sizeField.text;
    
    if([wordSizes length] == 0)
    {
        return false;
    }
    else if([self totalLettersInWordSizeField] > MAXWORDSIZECOMBINED)
    {
        return false;
    }
    else if([self numberOfWordsToFind] > MAXNUMBEROFWORDS)
    {
        return false;
    }
    else if(![self wordsNotGreaterThanSpecification: MAXWORDSIZE])
    {
        return false;
    }
    else if(![self wordSizeHasCorrectCharacters])
    {
        return false;
    }
    else
    {
        return true;
    }
}

- (int)numberOfWordsToFind
{
    NSString* wordSizes = sizeField.text;
    int numberOfSizes = 0;
    
    //For each character in the word size field...
    for(int i = 0; i < [wordSizes length]; i++)
    {
        if(isdigit([wordSizes characterAtIndex:i]))
        {
            continue;
        }
        //If it finds a ',', an individual number has been found.
        else if ([wordSizes characterAtIndex:i] == ',')
        {
            numberOfSizes++;
        }
    }
    //Adds the final number, or only number, when a ',' is not used in the pattern
    numberOfSizes++;
    
    return numberOfSizes;
}

- (int)totalLettersInWordSizeField
{
    NSString* wordSizes = sizeField.text;
    NSMutableString* tempNumber = [[NSMutableString alloc]init];
    int totalLetters = 0;
    
    //For each character in the word size field...
    for(int i = 0; i < [wordSizes length]; i++)
    {
        if(isdigit([wordSizes characterAtIndex:i]))
        {
            //If a number is found, add it to the temporary number string
            [tempNumber appendFormat:@"%c",[wordSizes characterAtIndex:i]];
        }
        else if ([wordSizes characterAtIndex:i] == ',')
        {
            //If the ',' divider is found, add the temporary number to the total amount of letters
            totalLetters = totalLetters + [tempNumber intValue];
            tempNumber = [[NSMutableString alloc] init];
        }
    }
    //Adds the final number's characters, or only number, when a ',' is not used in the pattern
    totalLetters = totalLetters + [tempNumber intValue];
    
    return totalLetters;
}

- (bool)wordsNotGreaterThanSpecification:(int)maxNumber
{
    NSString* wordSizes = sizeField.text;
    NSMutableString* tempNumber = [[NSMutableString alloc]init];
    
    //For each character in the word size field...
    for(int i = 0; i < [wordSizes length]; i++)
    {
        if(isdigit([wordSizes characterAtIndex:i]))
        {
            //If a number is found, add it to the temporary number string
            [tempNumber appendFormat:@"%c",[wordSizes characterAtIndex:i]];
        }
        else if ([wordSizes characterAtIndex:i] == ',')
        {
            //If the ',' divider is found, checks the temporary number's size
            if([tempNumber intValue] > maxNumber)
            {
                return false;
            }
            tempNumber = [[NSMutableString alloc] init];
        }
    }
    //Checks the final number's characters, or only number, when a ',' is not used in the pattern
    if([tempNumber intValue] > maxNumber)
    {
        return false;
    }
    
    return true;
    
}

- (bool)anagramFieldIsCorrect
{
    NSString* anagram = anagramField.text;
    //If the anagram is blank...
    if([anagram isEqualToString:@""])
    {
        return true;
    }
    
    //For each character in the anagram...
    for(int i = 0; i < [anagram length]; i++)
    {
        //If the character is an alphabetical character...
        if(isalpha([anagram characterAtIndex:i]))
        {
            continue;
        }
        //Else, the characters are an incorrect format.
        else
        {
            return false;
        }
    }
    return true;
}

- (bool)patternFieldIsCorrect
{
    NSString* pattern = patternField.text;
    
    //If the pattern is blank...
    if([pattern isEqualToString:@""])
    {
        return true;
    }
    
    //For each character in the pattern...
    for(int i = 0; i < [pattern length]; i++)
    {
        //Check if the character is an alphabetical character...
        if(isalpha([pattern characterAtIndex:i]))
        {
            continue;
        }
        //... Or is an '-' character...
        else if([pattern characterAtIndex:i] == '-')
        {
            continue;
        }
        //Else, the characters are an incorrect format.
        else
        {
            return false;
        }
    }
    return true;
}

- (bool)anagramOrPatternHaveCorrectSizes
{
    NSString* anagram = anagramField.text;
    NSString* pattern = patternField.text;
    
    //If an anagram exists, but a pattern does not..
    if([pattern length] == 0 && [anagram length] != 0)
    {
        //...Does the anagram's length equal the required word sizes total?
        if([anagram length] != [self totalLettersInWordSizeField])
        {
            return false;
        }
        
        return true;
    }
    //If the pattern exists, but an anagram does not...
    else if([pattern length] != 0 && [anagram length] == 0)
    {
        //...Does the pattern's length equal the required word sizes total?
        if([pattern length] != [self totalLettersInWordSizeField])
        {
            return false;
        }
        
        return true;
    }
    //If both a pattern and anagram exist...
    else if([pattern length] != 0 && [anagram length] != 0)
    {
        //...Do they both equal the required word sizes total?
        if([pattern length] != [self totalLettersInWordSizeField] ||
           [anagram length] != [self totalLettersInWordSizeField])
        {
            return false;
        }
        
        return true;
    }
    else
    {
        return false;
    }
}

- (IBAction)onDismissKeyboard:(id)sender
{
    [self resignAllFirstResponders];
}

- (void)handleBackgroundTap:(UITapGestureRecognizer *)sender
{
    [self resignAllFirstResponders];
}

- (void)resignAllFirstResponders
{
    //Collectively resigns all the first responders of the UI
    [anagramField resignFirstResponder];
    [patternField resignFirstResponder];
    [sizeField resignFirstResponder];
}

@end
