//
//  Deck.m
//  CLIMod10
//
//  Created by Michael Craig on 12/29/09.
//  Copyright 2009 Michael Craig. All rights reserved.
//

#import "Deck.h"

#import "Card.h"


@implementation Deck

- (Deck *)initWithLocation:(NSPoint)aPoint {
  self = [super init];
  if (self) {
    for (int i = 0; i < 4; i++) {
      for (int j = 1; j <= 13; j++) {
        [cardPile addObject:[[Card alloc] initWithSuit:i
                                                 value:j
                                              location:aPoint]];
      }
    }
  }
  return self;
}

- (void)addCard:(Card *)card {
  [cardPile insertObject:card atIndex:0];
}

- (void)randomize {
  NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:52];
  int rand;
  int size = [cardPile count];

  for (int i = 0; i < size; i++) {
    rand = arc4random()%[cardPile count];
    [tempArray addObject:[self takeCard:[cardPile objectAtIndex:rand]]];
  }

  [cardPile release];
  cardPile = tempArray;
  [cardPile retain];
}

@end
