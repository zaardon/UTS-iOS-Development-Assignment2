//
//  DictionaryHandler.h
//  assignment2
//
//  Created by Alex Smith on 14/10/2014.
//  Copyright (c) 2014 Alex Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"

@interface DictionaryHandler : NSObject
{
    NSMutableArray* dictList;
    NSMutableArray* foundCombinaions;
    int resultsCount;
}

- (id)init;
- (void)createDictionaryList;
- (NSMutableArray*)returnCrosswordSearchSolutionWith:(NSString*)wordSizes
                                          andLetters:(NSString*)anagram
                                          andPattern:(NSString*)pattern;

@end
