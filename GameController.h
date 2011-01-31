//
//  GameController.h
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import <Cocoa/Cocoa.h>

@class GameView;
@class Deck;
@class Stack;
@class Card;


@interface GameController : NSObject {
  NSArray *stackArray;
  Deck *theDeck;
  
  Stack *currentStack;
  
  BOOL deckIsShown;
  BOOL deckCountIsShown;
  
  IBOutlet GameView *gameView;
}

@property (readonly) NSArray *stackArray;
@property (readonly) Deck *theDeck;
@property BOOL deckIsShown, deckCountIsShown;

- (void)setupGame;

- (IBAction)resetGame:(id)sender;

- (IBAction)toggleDeckIsShown:(id)sender;

- (IBAction)toggleDeckCountIsShown:(id)sender;

- (void)pickupSelectedCards;

- (void)dealNext;

- (void)nextStack;

- (void)dealToCurrentStack;

- (NSArray *)selectedCards;

- (void)clickOnCard:(Card *)aCard;

- (BOOL)tripletWithCardsMods10:(Card *)card1 :(Card *)card2 :(Card *)card3;

- (BOOL)tripletFromStack:(Stack *)aStack withIndicesIsValid:(int)index1
                        :(int)index2 :(int)index3;

- (BOOL)indices:(int)index1 :(int)index2 inStackAreAdjacent:(Stack *)aStack;

@end
