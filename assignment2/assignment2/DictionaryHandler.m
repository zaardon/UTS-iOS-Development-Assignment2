//
//  DictionaryHandler.m
//  assignment2
//
//  Created by Alex Smith on 14/10/2014.
//  Copyright (c) 2014 Alex Smith. All rights reserved.
//

#import "DictionaryHandler.h"

@implementation DictionaryHandler
- (id)init;
{
    dictList = [[NSMutableArray alloc]init];
    foundCombinaions = [[NSMutableArray alloc]init];
    resultsCount = 0;
    return self;
}

- (void)resetResultCount
{
    resultsCount = 0;
}

- (NSMutableArray*)returnCrosswordSearchSolutionWith:(NSString*)wordSizes
                                          andLetters:(NSString*)anagram
                                          andPattern:(NSString*)pattern
{
    [self resetResultCount];    //Resets the result count
    [self resetSolutions];  //Resets any found solutions
    
    NSMutableArray* foundResults = [[NSMutableArray alloc]init];
    NSString* emptyString = @"";
    
    if([pattern isEqualToString:emptyString])
    {
        pattern = [self returnBlankPatternThatMatchesLengthOf:anagram];
    }
    
    //Generate a list of results
    [self generateSolutionWith:wordSizes andLetters:anagram andPattern:pattern
              andCurrentAnswer:emptyString];
    //Return a cleaned version of the results
    foundResults = [self returnCleanSolution];
    
    return foundResults;
    
}

- (NSString*)returnBlankPatternThatMatchesLengthOf:(NSString*)anagram
{
    NSMutableString* noPattern = [NSMutableString string];
    
    //Returns an NSString filled with '-', based on the provided anagram's length
    for(int i = 0; i< [anagram length]; i++)
    {
        [noPattern appendString:@"-"];
    }
    
    return noPattern;
}

- (NSMutableArray*)returnCleanSolution
{
    NSMutableArray* cleanSolution = [[NSMutableArray alloc]init];
    int numberOfCombinations = 0;
    int const MAXCOMBINATIONS = 100;
    
    //For each combination in solutions...
    for(NSString* combination in foundCombinaions)
    {
        //If there are already 100 found combinations...
        if(numberOfCombinations == MAXCOMBINATIONS)
        {
            break;
        }
        //Creates a string that removes the space character from the front of the sentence
        NSString* tempCombination = [NSString stringWithFormat:@"%@",
                                     [combination substringFromIndex:1]];
        [cleanSolution addObject:tempCombination];
        numberOfCombinations++;
    }
    
    return cleanSolution;
}

- (void)resetSolutions
{
    foundCombinaions = [[NSMutableArray alloc]init];
}

- (void)createDictionaryList
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* fileName = [[NSBundle mainBundle] pathForResource:@"dict" ofType:@"txt"];
    
    //If the file exists with the given location/name...
    if([self fileExistsWith:fm withFilePath:fileName])
    {
        //Get the file's data.
        NSString* data = [NSString stringWithContentsOfFile:fileName
                                                   encoding:NSUTF8StringEncoding error:nil];
        
        //Create an array that holds each line of the provided file.
        NSArray* lines = [data componentsSeparatedByCharactersInSet:
                          [NSCharacterSet newlineCharacterSet]];
        
        //For each line in the array of lines...
        for (NSString* line in lines)
        {
            //Create a word object and add it to the word list.
            Word *word = [[Word alloc] init];
            [word setLetters:line ];
            [word setSize:[line length]];
            [dictList addObject:word];
        }
    }
}

- (BOOL)fileExistsWith:(NSFileManager*)fm withFilePath:(NSString*)path;
{
    //Checks if the file exists at a path
    if([fm fileExistsAtPath:path] == NO)
    {
        return false;
    }
    return true;
}

- (NSMutableArray*)returnDictionaryWithWordSize:(int)wordLength
{
    NSMutableArray* dictionaryFromSizes = [[NSMutableArray alloc]init];
    
    //For each word in the dictionary...
    for(Word* word in dictList)
    {
        //If the word size equals the one provided...
        if([word getSize] == wordLength)
        {
            //Add that word to the new dictionary list
            Word* temp = [[Word alloc] init];
            [temp setLetters:[word getWord]];
            [dictionaryFromSizes addObject:temp];
        }
    }
    return dictionaryFromSizes;
}

- (void)generateSolutionWith:(NSString*)numbers andLetters:(NSString*)letters andPattern:
                             (NSString*)pattern andCurrentAnswer: (NSString*)answer
{
    //Sets the max combination number
    int const MAXCOMBINATIONS = 100;
    //Gets the first number from the word size list
    int n = [[numbers componentsSeparatedByString:@","][0] intValue];
    //Gets the current part of the pattern by the size of the first word
    NSString* patternToUse = [self returnPartOfPattern:pattern withWordSize:n];
    
    //Filters the dictionary to only return words of the correct size
    NSMutableArray* customDict = [self returnDictionaryWithWordSize:n];
    //Filters the dictionary to only return words that match the current pattern
    customDict = [self returnDictionaryWithWordPattern:patternToUse andDictionary:customDict];
    //Filters the dictionary to only return words that match the available letters
    customDict = [self returnDictionaryWithAnagram:letters andDictionary:customDict];
    
    NSString* remainingNumbers = [self returnRemainingNumbers:numbers];
    NSString* remainingPatterns = [self returnRemainingPattern:pattern WithWordSize:n];
    
    //If there is only one word left to do...
    if([numbers componentsSeparatedByString:@","].count == 1)
    {
        //Return a list of words that match the letters of that word
        NSMutableArray* newList = [self returnWordsThatMatchWith:letters andDictionary:customDict];
        
        //For each word found...
        for(Word* word in newList)
        {
            //Add it to the possible solutions
            NSString* sentence = [NSString stringWithFormat:@"%@ %@", answer, [word getWord]];
            [foundCombinaions addObject:sentence];
            resultsCount++;
        }
    }
    //If the results that are found total less than 100...
    else if(resultsCount < MAXCOMBINATIONS)
    {
        //For each word in the current list...
        for(Word* word in customDict)
        {
            //Hold the remaining letters
            NSString* remainingLetters = [self returnLettersRemainingFrom:letters
                                                                     with:[word getWord]];
            //Holds the current answer combined with the new found word
            NSString* potentialAnswer = [NSString stringWithFormat:@"%@ %@",answer,[word getWord]];
            //Calls itself with the remaining letters, numbers, patterns and potential answer
            [self generateSolutionWith:remainingNumbers andLetters:remainingLetters
                            andPattern:remainingPatterns andCurrentAnswer:potentialAnswer];
        }
    }
}

- (NSMutableArray*)returnWordsThatMatchWith:(NSString*)letters andDictionary:(NSMutableArray*)dict
{
    NSMutableArray* newDictionary = [[NSMutableArray alloc]init];
    
    //For each word in the given dictionary...
    for (Word* word in dict)
    {
        BOOL matches = true;
        //Makes a temporary word to store in the list of words
        Word* tempWord = [[Word alloc] init];
        [tempWord setLetters: [word getWord]];
        
        //For each character in the search word...
        for(int i = 0 ; i < [letters length]; i++)
        {
            //If the search word's character exists in the list word...
            if([word hasCharacter:[letters characterAtIndex:i]])
            {
                continue;
            }
            //Else, the words do not match as an anagram.
            else
            {
                matches = false;
                break;
            }
        }
        
        if(matches)
        {
            //Add it to the temporary word list.
            [newDictionary addObject:tempWord];
        }
    }
    
    return newDictionary;
}

- (NSMutableArray*)returnDictionaryWithWordPattern:(NSString*)pattern
                                     andDictionary:(NSMutableArray*)dictionary;
{
    NSMutableArray* newDictionary = [[NSMutableArray alloc]init];
    
    //For each word object in the given dictionary...
    for(Word* word in dictionary)
    {
        BOOL matches = true;
        
        //For each character in the pattern...
        for(int i = 0; i < [pattern length]; i++)
        {
            //If the character exists in the SAME index of the pattern and dictionary word...
            if([[word getWord]characterAtIndex:i] == tolower([pattern characterAtIndex:i]))
            {
                continue;
            }
            //... Or if the pattern's character is an '-'...
            else if([pattern characterAtIndex:i] == '-')
            {
                continue;
            }
            //Else, the words do not match as a pattern.
            else
            {
                matches = false;
                break;
            }
        }
        
        if(matches)
        {
            //Add it to the new dictionary.
            [newDictionary addObject:word];
        }
    }
    
    return newDictionary;
}

- (NSMutableArray*)returnDictionaryWithAnagram:(NSString*)anagram
                                 andDictionary:(NSMutableArray*)dictionary
{
    //If the anagram is blank...
    if([anagram isEqual:@""])
    {
        return dictionary;
    }
    
    NSMutableArray* newDictionary = [[NSMutableArray alloc]init];
    
    //For each word object in the given dictionary...
    for (Word* word in dictionary)
    {
        //Makes a temporary word to store in the list of words
        Word* anagramWord = [[Word alloc]init];
        [anagramWord setLetters:anagram];
        BOOL matches = true;
        
        //For each character in the search word...
        for(int i = 0 ; i < [[word getWord] length]; i++)
        {
            //If the anagram has the character from dictionary word...
            if([anagramWord hasCharacter:[[word getWord]characterAtIndex:i]])
            {
                continue;
            }
            //Else, the words do not match as an anagram.
            else
            {
                matches = false;
                break;
            }
        }
        
        if(matches)
        {
            //Add it to the temporary word list.
            [newDictionary addObject:word];
        }
    }
    
    return newDictionary;
}

- (NSString*)returnPartOfPattern:(NSString*)pattern withWordSize:(int)wordSize
{
    //Returns the first 'wordSize' characters of a given pattern
    NSString* newPattern = [pattern substringToIndex:wordSize];
    
    return newPattern;
}

- (NSString*)returnRemainingPattern:(NSString*)pattern WithWordSize:(int)wordSize
{
    //Returns the last 'wordSize' characters of a given pattern
    NSString* newPattern = [pattern substringFromIndex:wordSize];
    
    return newPattern;
}

- (NSString*)returnLettersRemainingFrom:(NSString*)existingLetters with:(NSString*)usedWord
{
    Word* word = [[Word alloc] init];
    [word setLetters:usedWord];
    NSMutableString* letters = [NSMutableString stringWithString:existingLetters];
    
    //For each character in the word...
    for(int j = 0; j < [[word getWord] length]; j++)
    {
        //For each character in the letters list...
        for(int i = 0; i < [letters length]; i++)
        {
            //Remove the letter if it matches the character from the word
            if([[word getWord] characterAtIndex:j] == [letters characterAtIndex:i])
            {
                [letters replaceCharactersInRange:NSMakeRange(i, 1) withString:@""];
                break;
            }
        }
    }
    
    return letters;
}

- (NSString*)returnRemainingNumbers:(NSString*)wordSizes
{
    NSArray* sizeList = [wordSizes componentsSeparatedByString:@","];
    NSMutableString* remaining = [NSMutableString stringWithString:@""];
    
    for(int i = 1; i < sizeList.count; i++)
    {
        //Returns a comma for each entry except for the last number.
        //Ternary if statement ensures that there is no comma after the last number.
        [remaining appendFormat:@"%@%@",sizeList[i],i == sizeList.count -1?@"":@","];
    }
    
    return remaining;
}

@end
