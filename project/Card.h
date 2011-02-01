//
//  Card.h
//  Mod10
//
//  Copyright 2011 Michael S. Craig
//  MIT License, http://www.opensource.org/licenses/mit-license
//

#import <Cocoa/Cocoa.h>


@interface Card : NSObject {
  NSString *suit;
  int value;
  BOOL selected;
  NSPoint location;
}

@property (readonly) NSString *suit;
@property (readonly) int value;
@property BOOL selected;
@property NSPoint location;

- (Card *)initWithSuit:(int)sui value:(int)val location:(NSPoint)loc;

- (NSString *)valueString;

@end
