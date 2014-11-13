//
//  Word.h
//  assignment2
//
//  Created by Alex Smith on 10/10/2014.
//  Copyright (c) 2014 Alex Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Word : NSObject
{
    //NSString that holds the object's letter value
    NSMutableString* letters;
    int size;
}

- (void)setLetters:(NSString*)l;
- (void)setSize:(int)i;
- (NSMutableString*)getWord;
- (int)getSize;
- (BOOL)hasCharacter:(char)c;

@end
