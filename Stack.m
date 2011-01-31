//
//  Stack.m
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import "Stack.h"

#import "Card.h"


@implementation Stack

- (Stack *)init {
  self = [super init];
  if (self)
    cardPile = [[NSMutableArray alloc] initWithCapacity:52];
  return self;
}

- (void)dealloc {
  if (cardPile)
    [cardPile release];
  return [super dealloc];
}

- (NSArray *)cardPile {
  return [NSArray arrayWithArray:cardPile];
}

- (void)addCard:(Card *)card {
  [cardPile addObject:card];
}

- (Card *)takeCard:(Card *)card {
  [cardPile removeObject:card];
  return card;
}

@end
