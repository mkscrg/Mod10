//
//  Deck.h
//  CLIMod10
//
//  Created by Michael Craig on 12/29/09.
//  Copyright 2009 Michael Craig. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Stack.h"


@interface Deck : Stack

- (Deck *)initWithLocation:(NSPoint)aPoint;

- (void)randomize;

@end
