//
//  Word.m
//  assignment2
//
//  Created by Alex Smith on 10/10/2014.
//  Copyright (c) 2014 Alex Smith. All rights reserved.
//

#import "Word.h"

@implementation Word

- (void) setLetters:(NSString*)l;
{
    letters = [NSMutableString stringWithString:l];
}

- (void) setSize:(int)i;
{
    size = i;
}

- (NSMutableString*)getWord
{
    return letters;
}

- (int)getSize
{
    return size;
}

/*
 * Compares a given character against all the characters in 'letters'
 */

- (BOOL)hasCharacter:(char)c;
{
    //For each character in letters...
    for(int i = 0; i < [letters length]; i++)
    {
        //If the character exists within the letters...
        if(tolower([letters characterAtIndex:i]) == tolower(c))
        {
            //Sets read letters to a '.' character so it can find repeatable characters
            [letters replaceCharactersInRange: NSMakeRange(i,1) withString: @"."];
            return true;
        }
        //...Else, continue seearching
        else
        {
            continue;
        }
    }
    //Else, it does not match.
    return false;
}

@end
