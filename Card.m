//
//  Card.m
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import "Card.h"


static NSArray *suitArray;
static NSArray *valueArray;

@implementation Card
@synthesize suit, selected, location;

+ (void)initialize {
  suitArray = [[NSArray alloc] initWithObjects:
               @"Cl", @"Di", @"Sp", @"He", nil];
  valueArray = [[NSArray alloc] initWithObjects:
                @"A", @"2", @"3", @"4", @"5", @"6", @"7",
                @"8", @"9", @"10", @"J", @"Q", @"K", nil];
}

- (Card *)initWithSuit:(int)sui value:(int)val location:(NSPoint)loc {
  self = [super init];
  if (self) {
    suit = [suitArray objectAtIndex:sui];
    value = val;
    selected = NO;
    location = loc;
  }
  return self;
}

- (int)value {
  if (value > 10)
    return 10;
  else
    return value;
}

- (NSString *)valueString {
  return [valueArray objectAtIndex:value-1];
}

@end
