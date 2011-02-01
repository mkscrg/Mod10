//
//  GameView.m
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import "GameView.h"

#import "GameController.h"
#import "Deck.h"
#import "Stack.h"
#import "Card.h"


// the x- and y-inset for playRect, as a fraction of the view's width
static CGFloat playRectInset;

// the height of each card, as a fraction of the width of each card
static CGFloat cardHeight;

// the total amount of horizontal space between cards, as a fractinon the width
// of each card
static CGFloat totalHSpace;

// the vertical gap between cards in a stack, as a fraction of the height of
// each card, also in the folded stack configuration
static CGFloat relativeCardGap;
static CGFloat relativeFoldedCardGap;

// the x- and y-radius of the rounded corners of each card, as a fraction of the
// width of each card
static CGFloat relativeCardCornerRadius;

// the size of the font used to show each card's suit and value, as a fraction
// of the height of each card
static CGFloat relativeCardFontSize;

// background color for the main window
static NSColor *backgroundColor;

// various colors and other parameters used in drawing cards
static NSColor *deckOutlineColor;
static NSColor *cardStrokeColor;
static CGFloat cardStrokeWidth;
static NSColor *unselectedCardFillColor;
static NSColor *unselectedCSCardInfoFGColor;
static NSColor *unselectedDHCardInfoFGColor;
static NSColor *selectedCardFillColor;
static NSColor *selectedCSCardInfoFGColor;
static NSColor *selectedDHCardInfoFGColor;

// alignments used for drawing text
static NSMutableParagraphStyle *rightAligned;
static NSMutableParagraphStyle *centerAligned;
static NSMutableParagraphStyle *leftAligned;


@implementation GameView

+ (void)initialize {
  playRectInset = 10.0/640.0;
  cardHeight = 7.0/5.0;
  totalHSpace = 1.5;
  relativeCardGap = 0.17;
  relativeFoldedCardGap = 0.05;
  relativeCardCornerRadius = 0.03;
  relativeCardFontSize = 0.12;
  
  backgroundColor = [NSColor colorWithCalibratedRed:0.255 green:0.557
                                               blue:0.255 alpha:1.0];
  [backgroundColor retain];
  
  deckOutlineColor = [NSColor yellowColor];
  cardStrokeColor = [NSColor blackColor];
  cardStrokeWidth = 0;
  unselectedCardFillColor = [NSColor whiteColor];
  unselectedCSCardInfoFGColor = [NSColor blackColor];
  unselectedDHCardInfoFGColor = [NSColor redColor];
  selectedCardFillColor = [NSColor blackColor];
  selectedCSCardInfoFGColor = [NSColor whiteColor];
  selectedDHCardInfoFGColor = [NSColor cyanColor];

  rightAligned = [[NSMutableParagraphStyle alloc] init];
  [rightAligned setAlignment:NSRightTextAlignment];
  centerAligned = [[NSMutableParagraphStyle alloc] init];
  [centerAligned setAlignment:NSCenterTextAlignment];
  leftAligned = [[NSMutableParagraphStyle alloc] init];
  [leftAligned setAlignment:NSLeftTextAlignment];
}

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self calculateDrawingSpecs];
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [self calculateDrawingSpecs];
  [self setDeckAndStackLocations];
  
  [backgroundColor set];
  NSRectFill([self bounds]);
  
  NSRect deckRect = NSMakeRect(playRect.origin.x, playRect.origin.y,
                               cardSize.width, cardSize.height);
  NSBezierPath *deckOutline = [NSBezierPath
                               bezierPathWithRoundedRect:deckRect
                               xRadius:cardCornerRadius
                               yRadius:cardCornerRadius];
  [deckOutline setLineWidth:cardSize.width/10];
  [deckOutlineColor set];
  [deckOutline stroke];
  
  [[NSColor blackColor] set];
  [self drawOptions];
  
  if (gameCon.deckCountIsShown)
    [self drawDeckCount];
  
  if (gameCon.deckIsShown) {
    for (Card *aCard in gameCon.theDeck.cardPile) {
      [self drawCard:aCard];
    }
  } else {
    if ([[gameCon.theDeck cardPile] count] != 0) {
      Card *deckCard = [[[gameCon theDeck] cardPile] objectAtIndex:0];
      [self drawCardbackAtLocation:deckCard.location];
    }
  }

  
  for (Stack *aStack in gameCon.stackArray) {
    for (Card *aCard in aStack.cardPile) {
      [self drawCard:aCard];
    }
  }  
}

- (void)calculateDrawingSpecs {
  playRect = NSInsetRect([self bounds], playRectInset*[self bounds].size.width,
                         playRectInset*[self bounds].size.width);
  float numColumns = [gameCon.stackArray count]+1.0;
  cardSize.width = playRect.size.width/(totalHSpace+numColumns);
  cardSize.height = cardSize.width * cardHeight;
  stackGap = playRect.size.width*totalHSpace/(totalHSpace+numColumns)/
             (numColumns-0.5);
  cardGap = cardSize.height*relativeCardGap;
  foldedCardGap = cardSize.height*relativeFoldedCardGap;
  cardCornerRadius = cardSize.width*relativeCardCornerRadius;
  cardFontSize = cardSize.height*relativeCardFontSize;
  optionsFontSize = cardSize.width/6;
  optionsTitleRect = NSMakeRect(playRect.origin.x, playRect.origin.y+
                                playRect.size.height-optionsFontSize*9/2,
                                cardSize.width, optionsFontSize*7/4);
  option1Rect = NSMakeRect(playRect.origin.x,
                           optionsTitleRect.origin.y+optionsFontSize*2,
                           optionsFontSize, optionsFontSize);
  option2Rect = NSMakeRect(playRect.origin.x,
                           option1Rect.origin.y+option1Rect.size.height+
                           optionsFontSize/2, optionsFontSize,
                           optionsFontSize);
}

- (void)setDeckAndStackLocations {
  for (Card *aCard in gameCon.theDeck.cardPile) {
    [aCard setLocation:NSMakePoint(playRect.origin.x, playRect.origin.y)];
  }
  
  NSPoint stackOrigin;
  stackOrigin.y = playRect.origin.y;
  for (int i = 0; i < [gameCon.stackArray count]; i++) {
    Stack *aStack = [gameCon.stackArray objectAtIndex:i];
    stackOrigin.x = playRect.origin.x+stackGap*0.5+(i+1)*(cardSize.width+
                                                          stackGap);
    CGFloat yAdjust = 0;
    for (Card *aCard in aStack.cardPile) {
      if (aCard !=  [aStack.cardPile objectAtIndex:0])
        yAdjust += cardGap;
      [aCard setLocation:NSMakePoint(stackOrigin.x, stackOrigin.y+yAdjust)];
    }
    Card *lastCard = [aStack.cardPile lastObject];
    if (lastCard.location.y+cardSize.height >
        playRect.origin.y+playRect.size.height) {
      CGFloat overDistance = lastCard.location.y+cardSize.height -
                             (playRect.origin.y+playRect.size.height);
      int necessaryFolds = (int) (overDistance/(cardGap-foldedCardGap))+1;
      int startIndex = ([aStack.cardPile count]-necessaryFolds)/2;
      Card *aCard = [aStack.cardPile objectAtIndex:startIndex-1];
      CGFloat locationY = aCard.location.y;
      for (int i = startIndex; i < [aStack.cardPile count]; i++) {
        if (i < startIndex+necessaryFolds)
          locationY += foldedCardGap;
        else
          locationY += cardGap;
        aCard = [aStack.cardPile objectAtIndex:i];
        [aCard setLocation:NSMakePoint(aCard.location.x, locationY)];
      }
    }
  }
}

- (void)drawOptions {
  NSDictionary *optionsTitleAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSFont fontWithName:@"Futura-Medium"
                                                    size:optionsFontSize*5/4],
                                    NSFontAttributeName,
                                    leftAligned, NSParagraphStyleAttributeName,
                                    nil];
  [@"Options:" drawInRect:optionsTitleRect withAttributes:optionsTitleAtts];
  
  NSDictionary *optionsAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSFont fontWithName:@"Futura-Medium"
                                               size:optionsFontSize*0.75],
                               NSFontAttributeName,
                               leftAligned, NSParagraphStyleAttributeName, nil];
  
  NSFrameRectWithWidth(option1Rect, option1Rect.size.width/10);
  if (!gameCon.deckIsShown)
    NSRectFill(option1Rect);
  NSRect option1TextRect = NSMakeRect(option1Rect.origin.x+
                                      option1Rect.size.width*1.5,
                                      option1Rect.origin.y-optionsFontSize/6,
                                      cardSize.width-option1Rect.size.width*1.5,
                                      option1Rect.size.height);
  [@"Hide deck" drawInRect:option1TextRect withAttributes:optionsAtts];
  
  NSFrameRectWithWidth(option2Rect, option2Rect.size.width/10);
  if (gameCon.deckCountIsShown)
    NSRectFill(option2Rect);
  NSRect option2TextRect = NSMakeRect(option2Rect.origin.x+
                                      option2Rect.size.width*1.5,
                                      option2Rect.origin.y-optionsFontSize/6,
                                      cardSize.width-option2Rect.size.width*1.5,
                                      option2Rect.size.height);
  [@"Count deck" drawInRect:option2TextRect withAttributes:optionsAtts];
}

- (void)drawDeckCount {
  NSMutableString *countString = [NSMutableString
                                  stringWithString:@"cards in deck: "];
  NSNumber *count = [NSNumber numberWithInt:[[gameCon.theDeck cardPile] count]];
  [countString appendString:[count stringValue]];
  NSDictionary *countAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSFont fontWithName:@"Futura-Medium"
                                             size:optionsFontSize],
                             NSFontAttributeName,
                             leftAligned, NSParagraphStyleAttributeName, nil];
  NSRect countRect = NSMakeRect(playRect.origin.x,
                                playRect.origin.y+cardSize.height+
                                optionsFontSize*2,
                                cardSize.width, optionsFontSize*8/3);
  [countString drawInRect:countRect withAttributes:countAtts];
}

- (void)drawCard:(Card *)aCard {
  NSColor *cardFillColor, *cardInfoFGColor;
  if (aCard.selected) {
    cardFillColor = selectedCardFillColor;
    if (aCard.suit == @"Cl" || aCard.suit == @"Sp")
      cardInfoFGColor = selectedCSCardInfoFGColor;
    else
      cardInfoFGColor = selectedDHCardInfoFGColor;
  } else {
    cardFillColor = unselectedCardFillColor;
    if (aCard.suit == @"Cl" || aCard.suit == @"Sp")
      cardInfoFGColor = unselectedCSCardInfoFGColor;
    else
      cardInfoFGColor = unselectedDHCardInfoFGColor;
  }
  
  NSRect cardRect;
  cardRect.size = cardSize;
  cardRect.origin = aCard.location;
  NSBezierPath *cardPath = [NSBezierPath
                            bezierPathWithRoundedRect:cardRect
                                              xRadius:cardCornerRadius
                                              yRadius:cardCornerRadius];
  [cardFillColor set];
  [cardPath fill];
  [cardStrokeColor set];
  [cardPath setLineWidth:cardStrokeWidth];
  [cardPath stroke];
  
  NSRect valueRect = NSInsetRect(cardRect,
                                 cardCornerRadius*0.5, cardCornerRadius*1.2);
  valueRect.size.width = cardFontSize*1.27;
  NSDictionary *valueAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSFont labelFontOfSize:cardFontSize],
                             NSFontAttributeName,
                             centerAligned, NSParagraphStyleAttributeName,
                             cardInfoFGColor, NSForegroundColorAttributeName,
                             nil];
  [[aCard valueString] drawInRect:valueRect withAttributes:valueAtts];
  NSRect suitRect = NSInsetRect(valueRect, 0, cardFontSize*1.2);
  NSDictionary *suitAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSFont labelFontOfSize:cardFontSize*5/6],
                            NSFontAttributeName,
                            centerAligned, NSParagraphStyleAttributeName,
                            cardInfoFGColor, NSForegroundColorAttributeName,
                            nil];
  NSString *suitString = [self getUnicodeSuitSymbolString:[aCard suit]];
  [suitString drawInRect:suitRect withAttributes:suitAtts];
  
  NSRect faceRect = NSInsetRect(cardRect, valueRect.size.width*0.75+
                                valueRect.origin.x-cardRect.origin.x,
                                valueRect.origin.y-cardRect.origin.y);
  
  valueRect.origin.x = cardRect.origin.x*2+cardRect.size.width-
                        valueRect.origin.x-valueRect.size.width;
  suitRect.origin.x = valueRect.origin.x;
  [self drawStringInverted:[aCard valueString] inRect:valueRect
            withAttributes:valueAtts];
  [self drawStringInverted:suitString inRect:suitRect withAttributes:suitAtts];

  [self drawCardFaceInRect:faceRect withSuit:aCard.suit
               valueString:[aCard valueString] color:cardInfoFGColor];
}

- (void)drawCardbackAtLocation:(NSPoint)aPoint {
  NSRect cardRect;
  cardRect.size = cardSize;
  cardRect.origin = aPoint;
  NSBezierPath *cardPath = [NSBezierPath
                            bezierPathWithRoundedRect:cardRect
                            xRadius:cardCornerRadius
                            yRadius:cardCornerRadius];
  [[NSColor magentaColor] set];
  [cardPath fill];
  [cardStrokeColor set];
  [cardPath setLineWidth:cardStrokeWidth];
  [cardPath stroke];
  
  unichar symbols[5];
  symbols[0] = 0x2663;
  symbols[1] = 0x2662;
  symbols[2] = 0x000a;
  symbols[3] = 0x2661;
  symbols[4] = 0x2660;
  NSString *suitsString = [NSString stringWithCharacters:symbols length:5];
  NSDictionary *suitsAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSFont labelFontOfSize:cardRect.size.height/4],
                             NSFontAttributeName,
                             centerAligned, NSParagraphStyleAttributeName,
                             [NSColor greenColor],
                             NSForegroundColorAttributeName, nil];
  [suitsString drawInRect:NSInsetRect(cardRect, 0, cardRect.size.height*0.2)
           withAttributes:suitsAtts];
}

- (void)drawCardFaceInRect:(NSRect)aRect withSuit:(NSString *)suit
               valueString:(NSString *)valueString
                     color:(NSColor *)aColor {
  CGFloat fontSize;
  if (valueString == @"A") {
    fontSize = aRect.size.height*0.4;
  } else {
    fontSize = aRect.size.height/6;
  }
  
  NSString *suitString = [self getUnicodeSuitSymbolString:suit];
  
  NSDictionary *atts = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSFont labelFontOfSize:fontSize],
                        NSFontAttributeName,
                        centerAligned, NSParagraphStyleAttributeName,
                        aColor, NSForegroundColorAttributeName, nil];

  NSTextStorage *storage = [[NSTextStorage alloc] initWithString:suitString
                                                      attributes:atts];
  NSLayoutManager *layout = [[NSLayoutManager alloc] init];
  NSTextContainer *contain = [[NSTextContainer alloc] init];
  [storage addLayoutManager:layout];
  [layout addTextContainer:contain];
  
  [layout glyphRangeForTextContainer:contain];
  
  NSRect symRect;
  symRect = [layout usedRectForTextContainer:contain];
  symRect.origin = NSMakePoint(aRect.origin.x+
                                  (aRect.size.width-symRect.size.width)/2,
                                  aRect.origin.y+
                                  (aRect.size.height-symRect.size.height)/2);
  
  CGFloat yAdjust = fontSize*0.18;
  
  if (valueString == @"A") {
    symRect.origin.y += yAdjust;
    [suitString drawInRect:symRect withAttributes:atts];
  } else if (valueString == @"2" || valueString == @"3") {
    if (valueString == @"3") {
      symRect.origin.y += yAdjust;
      [suitString drawInRect:symRect withAttributes:atts];
    }
    symRect.origin.y = aRect.origin.y+yAdjust;
    [suitString drawInRect:symRect withAttributes:atts];
    symRect.origin.y = aRect.origin.y+aRect.size.height-
                       symRect.size.height-yAdjust;
    [self drawStringInverted:suitString inRect:symRect withAttributes:atts];
  } else if (valueString == @"4" || valueString == @"5" ||
             valueString == @"6" || valueString == @"7" ||
             valueString == @"8" || valueString == @"9" ||
             valueString == @"10") {
    if (valueString == @"5" || valueString == @"9") {
      symRect.origin.y += yAdjust;
      [suitString drawInRect:symRect withAttributes:atts];
    }
    if (valueString == @"10") {
      symRect.origin.y = aRect.origin.y+(aRect.size.height/2-
                                         symRect.size.height)/2+yAdjust;
      [suitString drawInRect:symRect withAttributes:atts];
      symRect.origin.y = aRect.origin.y+(aRect.size.height*3/2-
                                         symRect.size.height)/2-yAdjust;
      [self drawStringInverted:suitString inRect:symRect withAttributes:atts];
    }
    if (valueString == @"6" || valueString == @"7" || valueString == @"8") {
      symRect.origin.y += yAdjust;
      symRect.origin.x = aRect.origin.x;
      [suitString drawInRect:symRect withAttributes:atts];
      symRect.origin.x += aRect.size.width-symRect.size.width;
      [suitString drawInRect:symRect withAttributes:atts];
      if (valueString == @"7" || valueString == @"8") {
        symRect.origin = NSMakePoint(aRect.origin.x+
                                     (aRect.size.width-symRect.size.width)/2,
                                     aRect.origin.y+
                                     (aRect.size.height*2/3-
                                      symRect.size.height)/2+yAdjust);
        [suitString drawInRect:symRect withAttributes:atts];
        if (valueString == @"8") {
          symRect.origin.y = aRect.origin.y+(aRect.size.height*4/3-
                                             symRect.size.height)/2-yAdjust;
          [self drawStringInverted:suitString inRect:symRect
                    withAttributes:atts];
        }
      }
    }
    if (valueString == @"9" || valueString == @"10") {
      symRect.origin = NSMakePoint(aRect.origin.x,
                                   aRect.origin.y+symRect.size.height+
                                   (aRect.size.height-symRect.size.height*4)/3+
                                   yAdjust);
      [suitString drawInRect:symRect withAttributes:atts];
      symRect.origin.x += aRect.size.width-symRect.size.width;
      [suitString drawInRect:symRect withAttributes:atts];
      symRect.origin.y += symRect.size.height+
                          (aRect.size.height-symRect.size.height*4)/3-yAdjust*2;
      [self drawStringInverted:suitString inRect:symRect withAttributes:atts];
      symRect.origin.x = aRect.origin.x;
      [self drawStringInverted:suitString inRect:symRect withAttributes:atts];
    }
    symRect.origin = NSMakePoint(aRect.origin.x, aRect.origin.y+yAdjust);
    [suitString drawInRect:symRect withAttributes:atts];
    symRect.origin.x += aRect.size.width-symRect.size.width;
    [suitString drawInRect:symRect withAttributes:atts];
    symRect.origin.y = aRect.origin.y+aRect.size.height-
                       symRect.size.height-yAdjust;
    [self drawStringInverted:suitString inRect:symRect withAttributes:atts];
    symRect.origin.x = aRect.origin.x;
    [self drawStringInverted:suitString inRect:symRect withAttributes:atts];
  } else if (valueString == @"J" || valueString == @"Q" ||
             valueString == @"K") {
    symRect.origin = NSMakePoint(aRect.origin.x+aRect.size.width-
                                 symRect.size.width, aRect.origin.y+yAdjust);
    [suitString drawInRect:symRect withAttributes:atts];
    symRect.origin.x -= aRect.size.width-symRect.size.width;
    symRect.origin.y += aRect.size.height-symRect.size.height-yAdjust*2;
    [self drawStringInverted:suitString inRect:symRect withAttributes:atts];
    CGFloat faceFontSize = aRect.size.height/2;
    NSDictionary *faceValueAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                                   centerAligned, NSParagraphStyleAttributeName,
                                   [NSFont fontWithName:@"Futura-Medium"
                                                   size:faceFontSize],
                                   NSFontAttributeName,
                                   aColor, NSForegroundColorAttributeName, nil];
    NSRect faceValueRect;
    faceValueRect.size = NSMakeSize(faceFontSize,faceFontSize*4/3);
    faceValueRect.origin = NSMakePoint(aRect.origin.x+
                                       (aRect.size.width-
                                        faceValueRect.size.width)/2,
                                       aRect.origin.y+
                                       (aRect.size.height-
                                        faceValueRect.size.height)/2);
//    NSFrameRect(faceValueRect);
//    NSFrameRect(NSInsetRect(faceValueRect, faceValueRect.size.width*0.48, 0));
//    NSFrameRect(NSInsetRect(faceValueRect, 0, faceValueRect.size.height*0.48));
    faceValueRect.origin.x += faceFontSize*0.018;
    faceValueRect.origin.y += faceFontSize*0.018;
    [valueString drawInRect:faceValueRect withAttributes:faceValueAtts];
  }

}

- (NSString *)getUnicodeSuitSymbolString:(NSString *)suit {
  unichar symbol[1];
  if (suit == @"Cl")
    symbol[0] = 0x2663;
  else if (suit == @"Di")
    symbol[0] = 0x2666;
  else if (suit == @"Sp")
    symbol[0] = 0x2660;
  else if (suit == @"He")
    symbol[0] = 0x2665;
  else
    symbol[0] = 0xFF1F;
  NSString *symbolString = [NSString stringWithCharacters:symbol length:1];
  return symbolString;
}

- (void)drawStringInverted:(NSString *)aString
                    inRect:(NSRect)aRect
            withAttributes:(NSDictionary *)atts {
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform rotateByDegrees:180];
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  
  NSRect invertedRect;
  invertedRect.origin = NSMakePoint(-(aRect.origin.x+aRect.size.width),
                                    -(aRect.origin.y+aRect.size.height));
  invertedRect.size = aRect.size;
  
  [context saveGraphicsState];
  [transform concat];
  
  [aString drawInRect:invertedRect withAttributes:atts];  
  
  [context restoreGraphicsState];
}

- (void)mouseDown:(NSEvent *)theEvent {
  NSPoint whereClick = [self convertPoint:[theEvent locationInWindow]
                                 fromView:nil];
  
  if ([gameCon.theDeck.cardPile count] != 0) {
    Card *deckCard = [[gameCon.theDeck cardPile] lastObject];
    NSRect deckRect;
    deckRect.origin = deckCard.location;
    deckRect.size = cardSize;
    if ([self mouse:whereClick inRect:deckRect]) {
      [gameCon dealNext];
      return;
    }
  }
  
  if ([self mouse:whereClick inRect:option1Rect]) {
    if (gameCon.deckIsShown == NO)
      [gameCon setDeckIsShown:YES];
    else
      [gameCon setDeckIsShown:NO];
    [self setNeedsDisplay:YES];
    return;
  }
  
  if ([self mouse:whereClick inRect:option2Rect]) {
    if (gameCon.deckCountIsShown == NO)
      [gameCon setDeckCountIsShown:YES];
    else
      [gameCon setDeckCountIsShown:NO];
    [self setNeedsDisplay:YES];
    return;
  }
  
  BOOL searching = YES;
  for (Stack *aStack in gameCon.stackArray) {
    if (!searching)
      break;
    for (int i = [aStack.cardPile count]-1; i >= 0; i--) {
      Card *aCard = [aStack.cardPile objectAtIndex:i];
      NSRect cardRect;
      cardRect.origin = aCard.location;
      cardRect.size = cardSize;
      if ([self mouse:whereClick inRect:cardRect]) {
        [gameCon clickOnCard:aCard];
        searching = NO;
        break;
      }
    }
  }
}

- (BOOL)isFlipped {
  return YES;
}

@end
