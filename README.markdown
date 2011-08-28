##  Mod10
### README

Copyright 2011 Michael S. Craig
MIT License, http://www.opensource.org/licenses/mit-license

This is a simple solitaire card game called Mod10, written by me in December of
2009 and January of 2010 as a Winter Term project for Oberlin College. The full
Xcode project is included in the project directory, while Mod10.dmg includes a
universal binary compiled for the Mac OS X 10.6 development target.

### The Game

The game starts with seven stacks of two cards, face up, dealt from a
randomized deck. Play begins by dealing cards one at a time to each pile, in
order from left to right.

Upon placing each card, the player inspects the stack for groups of three cards
whose values add to a multiple of 10. The value of Aces is 1 and the value of
all face cards is 10. Groups can be made by any sequence of three cards that is
exposed on at least one end of the stack, and groups can by continuous from the
top to the bottom of a stack. For example (X marks cards in the selected
group):

    +--------+                +--------+
    |A       | X              |A       | X
    +--------+                +--------+
    |9       | X  is valid    |9       | X
    +--------+                +--------+
    |10      | X              |2       |    is valid
    +--------+                +--------+
    |4       |                |Q       |
    +--------+                +--------+
    |7       |                |J       | X
    |        |                |        |
    |        |                |        |
    |        |                |        |
    |        |                |        |
    |        |                |        |
    +--------+                +--------+

    +--------+                +--------+
    |3       |                |Q       | X
    +--------+                +--------+
    |9       |                |9       |
    +--------+                +--------+
    |7       | X              |5       |    is valid
    +--------+                +--------+
    |2       | X  is valid    |Q       | X
    +--------+                +--------+
    |A       | X              |J       | X
    |        |                |        |
    |        |                |        |
    |        |                |        |
    |        |                |        |
    |        |                |        |
    +--------+                +--------+

Clicking a card in a stack -- assuming it is one of the top or bottom three
cards -- selects it. The second card to be selected -- also by clicking -- must
be in the same stack as the first card. Clicking a third card checks the
validity of the triplet and picks up all three cards if it's valid, returning
them to the bottom of the deck.

The game can be reset by choosing New Game from the Game menu or pressing
Command-N. The options menu, as well as the buttons at the bottom left of the
game window, allow you toggle the visibility of the top card in the deck (Hide
Deck) and the visibility of the deck count (Count Deck).
