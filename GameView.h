//
//  GameView.h
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import <Cocoa/Cocoa.h>

@class GameController;
@class Deck;
@class Stack;
@class Card;

@interface GameView : NSView {
  IBOutlet GameController *gameCon;
  
  NSRect playRect, optionsTitleRect, option1Rect, option2Rect;
  NSSize cardSize;
  CGFloat stackGap, cardGap, foldedCardGap, cardCornerRadius, infoFontSize,
          cardFontSize, optionsFontSize;
}

- (void)calculateDrawingSpecs;

- (void)setDeckAndStackLocations;

- (void)drawOptions;

- (void)drawDeckCount;

- (void)drawCard:(Card *)aCard;

- (void)drawCardbackAtLocation:(NSPoint)aPoint;

- (void)drawCardFaceInRect:(NSRect)aRect withSuit:(NSString *)suit
               valueString:(NSString *)valueString color:(NSColor *)aColor;

- (NSString *)getUnicodeSuitSymbolString:(NSString *)suit;

- (void)drawStringInverted:(NSString *)aString
                    inRect:(NSRect)aRect
            withAttributes:(NSDictionary *)atts;

@end
