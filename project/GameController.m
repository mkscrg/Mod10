//
//  GameController.m
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import "GameController.h"

#import "GameView.h"
#import "Stack.h"
#import "Deck.h"
#import "Card.h"


static int numStacks;


@implementation GameController
@synthesize stackArray, theDeck, deckIsShown, deckCountIsShown;

+ (void)initialize {
  numStacks = 7;
}

- (GameController *)init {
  self = [super init];
  if (self) {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:numStacks];
    for (int i = 0; i < numStacks; i++)
      [tempArray addObject:[[Stack alloc] init]];
    stackArray = [[NSArray alloc] initWithArray:tempArray];
    theDeck = [[Deck alloc] initWithLocation:NSMakePoint(0.0, 0.0)];
    currentStack = [stackArray objectAtIndex:0];
    deckIsShown = NO;
    deckCountIsShown = NO;
  }
  return self;
}

- (void)awakeFromNib {
  [self setupGame];
  [gameView setNeedsDisplay:YES];
}

- (void)setupGame {
  [theDeck randomize];
  for (int i = 0; i < [stackArray count]*2; i++) {
    [self dealToCurrentStack];
    [self nextStack];
  }
}

- (IBAction)resetGame:(id)sender {
  for (Stack *aStack in stackArray) {
    for (Card *aCard in [aStack cardPile]) {
      [theDeck addCard:[aStack   takeCard:aCard]];
    }
  }
  [self setupGame];
  currentStack = [stackArray objectAtIndex:0];
  [gameView setNeedsDisplay:YES];
}

- (IBAction)toggleDeckIsShown:(id)sender {
  if (deckIsShown)
    deckIsShown = NO;
  else
    deckIsShown = YES;
  [gameView setNeedsDisplay:YES];
}

- (IBAction)toggleDeckCountIsShown:(id)sender {
  if (deckCountIsShown)
    deckCountIsShown = NO;
  else
    deckCountIsShown = YES;
  [gameView setNeedsDisplay:YES];
}

- (void)pickupSelectedCards {
  NSArray *selectedCards = [self selectedCards];
  for (Card *aCard in selectedCards) {
    Stack *cardStack;
    for (Stack *aStack in stackArray) {
      if ([aStack.cardPile containsObject:aCard]) {
        cardStack = aStack;
        break;
      }
    }
    [theDeck addCard:[cardStack takeCard:aCard]];
    [aCard setSelected:NO];
  }
  [gameView setNeedsDisplay:YES];
}

- (void)dealNext {
  NSArray *selectedCards = [self selectedCards];
  for (Card *aCard in selectedCards) {
    [aCard setSelected:NO];
  }
  while ([currentStack.cardPile count] == 0)
    [self nextStack];
  [self dealToCurrentStack];
  do {
    [self nextStack];
  } while ([currentStack.cardPile count] == 0);
  [gameView setNeedsDisplay:YES];
}

- (void)nextStack {
  if (currentStack == [stackArray lastObject])
    currentStack = [stackArray objectAtIndex:0];
  else
    currentStack = [stackArray objectAtIndex:
                    [stackArray indexOfObject:currentStack]+1];
}

- (void)dealToCurrentStack {
  [currentStack addCard:[theDeck takeCard:[theDeck.cardPile lastObject]]];
}

- (NSArray *)selectedCards {
  NSMutableArray *tempArray = [NSMutableArray array];
  for (Stack *aStack in stackArray) {
    for (Card *aCard in aStack.cardPile) {
      if (aCard.selected)
        [tempArray addObject:aCard];
    }
  }
  return [NSArray arrayWithArray:tempArray];
}

- (void)clickOnCard:(Card *)aCard {
  if (aCard.selected) {
    [aCard setSelected:NO];
  } else {
    Stack *cardStack;
    for (Stack *aStack in stackArray) {
      if ([aStack.cardPile containsObject:aCard]) {
        cardStack = aStack;
        break;
      }
    }
    int card1Index = [cardStack.cardPile indexOfObject:aCard];
    
    if (card1Index < 3 || card1Index > [cardStack.cardPile count]-4) {
      NSArray *selectedCards = [self selectedCards];
      if ([selectedCards count] == 0)
        [aCard setSelected:YES];
      else if ([selectedCards count] == 1 &&
          [cardStack.cardPile containsObject:[selectedCards objectAtIndex:0]])
        [aCard setSelected:YES];
      else if ([selectedCards count] == 2 &&
               [cardStack.cardPile
                containsObject:[selectedCards objectAtIndex:0]]) {
        int card2Index = [cardStack.cardPile
                          indexOfObject:[selectedCards objectAtIndex:0]];
        int card3Index = [cardStack.cardPile
                          indexOfObject:[selectedCards objectAtIndex:1]];
        if ([self tripletFromStack:cardStack
                withIndicesIsValid:card1Index :card2Index :card3Index] &&
            [self tripletWithCardsMods10:aCard
                                        :[selectedCards objectAtIndex:0]
                                        :[selectedCards objectAtIndex:1]]) {
          [aCard setSelected:YES];
          [self pickupSelectedCards];
        }
      }
    }
  }
  [gameView setNeedsDisplay:YES];
}

- (BOOL)tripletWithCardsMods10:(Card *)card1 :(Card *)card2 :(Card *)card3 {
  if ((card1.value+card2.value+card3.value)%10 == 0)
    return YES;
  else
    return NO;
}

- (BOOL)tripletFromStack:(Stack *)aStack withIndicesIsValid:(int)index1
                        :(int)index2 :(int)index3 {
  BOOL tripletIsAdjacent = NO;
  if ([self indices:index1 :index2 inStackAreAdjacent:aStack]) {
    if ([self indices:index1 :index3 inStackAreAdjacent:aStack] ||
        [self indices:index2 :index3 inStackAreAdjacent:aStack])
      tripletIsAdjacent = YES;
  } else if ([self indices:index1 :index3 inStackAreAdjacent:aStack] &&
             [self indices:index2 :index3 inStackAreAdjacent:aStack])
    tripletIsAdjacent = YES;
  if (tripletIsAdjacent) {
    if ((index1 == 0 || index1 == [aStack.cardPile count]-1) ||
        (index2 == 0 || index2 == [aStack.cardPile count]-1) ||
        (index3 == 0 || index3 == [aStack.cardPile count]-1)) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)indices:(int)index1 :(int)index2 inStackAreAdjacent:(Stack *)aStack {
  if (abs(index1-index2) == 1)
    return YES;
  else if ((index1 == 0 && index2 == [aStack.cardPile count]-1) ||
           (index2 == 0 && index1 == [aStack.cardPile count]-1))
    return YES;
  else
    return NO;
}

@end
