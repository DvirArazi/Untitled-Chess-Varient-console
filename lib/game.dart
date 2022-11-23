import 'dart:web_audio';

import 'package:new_chess_console/Pieces/bishop.dart';
import 'package:new_chess_console/Pieces/king.dart';
import 'package:new_chess_console/Pieces/knight.dart';
import 'package:new_chess_console/Pieces/pawn.dart';
import 'package:new_chess_console/Pieces/queen.dart';
import 'package:new_chess_console/Pieces/rook.dart';
import 'package:new_chess_console/Utils.dart';
import 'package:new_chess_console/piece.dart';

class Game {
  Game() {
    _layout = stringToLayout('''
rnbqkbnr
pppppppp




PPPPPPPP
RNBQKBNR
''');
  }

  late Layout _layout;

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}

const Map<String, Piece> piecesMap = {
  'K': King(true),
  'Q': Queen(true),
  'R': Rook(true),
  'N': Knight(true),
  'B': Bishop(true),
  'P': Pawn(true),
  'k': King(false),
  'q': Queen(false),
  'r': Rook(false),
  'n': Knight(false),
  'b': Bishop(false),
  'p': Pawn(false),
};

Layout stringToLayout(String str) {
  Layout layout = List.filled(8, List.filled(8, null));

  str.replaceAll('\n', '');

  for (int i = 0; i < 8 * 8; i++) {
    layout[i % 8][i ~/ 8] = piecesMap[str[i]];
  }

  return layout;
}
