# Untitled Chess Variant (Console app)
A simple terminal interface for playing a unique variant of chess I've come up with.
The program is a precursor for a Multi-platform Flutter app currently in development.

## Running the program
- Install the [Dart SDK](https://dart.dev/get-dart)
- Clone this project and enter the cloned folder
- Run the project with `dart run`

## Rules
The rules of the game are the same as ragular chess, apart from several exeptions:
1. The configuration of the board is randomized for each game, with the 1st rank shuffled and the 8th mirroring it.
2. Stalemate is a win. The player with no legal moves loses.
3. No castling.
4. No en passant.
5. Pawns can be promoted only to previously captured pieces of the same color. If no pieces of the same color were captured, the pawn cannot be promoted.
6. No checks. A player may choose to leave their king in danger.
