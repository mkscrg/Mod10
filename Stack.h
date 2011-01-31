//
//  Stack.h
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import <Cocoa/Cocoa.h>

@class Card;


@interface Stack : NSObject {
  NSMutableArray *cardPile;
}

- (NSMutableArray *)cardPile;

- (void)addCard:(Card *)card;

- (Card *)takeCard:(Card *)card;

@end
