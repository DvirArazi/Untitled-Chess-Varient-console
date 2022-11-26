import 'dart:io';
import 'dart:math';

import 'package:chalkdart/chalk.dart';
import 'package:new_chess_console/utils.dart';
import 'package:new_chess_console/piece.dart';

class Game {
  Game() {
    var rng = Random();

    _layout = List.generate(8, (_) => 
      [null, piece('p'), null, null, null, null, piece('P'), null]
    );
    _layout[rng.nextInt(4) * 2][7] = Piece(PieceType.bishop, PieceColor.white);
    _layout[rng.nextInt(4) * 2 + 1][7] =
        Piece(PieceType.bishop, PieceColor.white);
    var pieceTypes = [
      piece('K'),
      piece('Q'),
      piece('R'),
      piece('R'),
      piece('N'),
      piece('N'),
    ];
    for (int i = 0; i < 6; i++) {
      var crnt = rng.nextInt(6 - i);
      var spot = 0;
      for (int j = 0;; spot++) {
        if (_layout[spot][7] == null) {
          if (j == crnt) break;
          j++;
        }
      }
      _layout[spot][7] = pieceTypes[i];
    }
    for (int i = 0; i < 8; i++) {
      _layout[i][0] = Piece(_layout[i][7]!.type, PieceColor.black);
    }

    whiteTurn = true;
  }

  late Layout _layout;
  late bool whiteTurn;

  void play() {
    while (true) {
      draw();
      stdout.write("${whiteTurn ? "White" : "Black"}'s piece square: ");
      var line = stdin.readLineSync();
      if (line == null) {
        print("Invalid input.");
        continue;
      }
      if (line.length != 2) {
        print("Invalid input: Input must contain 2 characters.");
        continue;
      }

      var x0 = charToX(line[0]);
      var y0 = charToY(line[1]);
      if (x0 == null || y0 == null) {
        print("Invalid input: Format needs to be [A-H][1-8].");
        continue;
      }

      var s0 = _layout[x0][y0];

      if (s0 == null) {
        print("Invalid input: Position does not contain a piece.");
        continue;
      }

      if ((s0.color == PieceColor.white) != whiteTurn) {
        print("""Invalid input: First position contains a piece of the opposite 
color.""");
        continue;
      }

      var legalMoves = getLegalMoves(x0, y0);

      if (legalMoves.isEmpty) {
        print("Invalid input: Piece has no moves.");
        continue;
      }

      draw(pieceSquare: P(x0, y0), legalMoves: legalMoves);

      var success = false;
      while(true) {
        stdout.write(
          "${whiteTurn ? "White" : "Black"}'s move square ('x' to cancel): "
        );
        line = stdin.readLineSync();
        if (line == null) {
          print("Invalid input.");
          continue;
        }
        if (line == 'x') {
          break;
        }
        if (line.length != 2) {
          print("Invalid input: Input must contain 2 characters.");
          continue;
        }
        
        var x1 = charToX(line[0]);
        var y1 = charToY(line[1]);
        if (x1 == null || y1 == null) {
          print("Invalid input: Format needs to be [A-H][1-8].");
          continue;
        }

        if (!legalMoves.contains(P(x1, y1))) {
          print("Invalid input: Illigal move.");
          continue;
        }

        _layout[x1][y1] = _layout[x0][y0];
        _layout[x0][y0] = null;

        success = true;
        break;
      }
      if (!success) {
        continue;
      }

      whiteTurn = !whiteTurn;
    }
  }

  bool isMoveLegal(int x0, int y0, int x1, int y1) {
    var s0 = _layout[x0][y0];
    var s1 = _layout[x1][y1];

    if (s0 == null ||
        (s0.color == PieceColor.white) != whiteTurn ||
        (s1 != null && s1.color == s0.color)) {
      return false;
    }

    bool isDirMoveLegal(List<P> dirs) {
      for (int j = 0; j < dirs.length; j++) {
        for (int i = 1;; i++) {
          var xi = x0 + i * dirs[j].x;
          var yi = y0 + i * dirs[j].y;
          if (!isOnBoard(xi, yi)) break;
          var crnt = _layout[xi][yi];
          if (crnt != null && crnt.color == s0.color) break;
          if (xi == x1 && yi == y1) return true;
        }
      }
      return false;
    }

    var rookDirs = [P(0, -1), P(-1, 0), P(1, 0), P(0, 1)];
    var bishopDirs = [P(-1, -1), P(-1, 1), P(1, -1), P(1, 1)];

    switch (s0.type) {
      case PieceType.king:
        var options = <P>[
          P(-1, -1),
          P(0, -1),
          P(1, -1),
          P(-1, 0),
          P(1, 0),
          P(-1, 1),
          P(0, 1),
          P(1, 1)
        ];

        if (options.contains(P(x0 - x1, y0 - y1))) {
          return true;
        }

        return false;

      case PieceType.queen:
        return isDirMoveLegal(rookDirs + bishopDirs);

      case PieceType.rook:
        return isDirMoveLegal(rookDirs);

      case PieceType.knight:
        var options = <P>[
          P(-1, -2),
          P(1, -2),
          P(-2, -1),
          P(-2, 1),
          P(2, -1),
          P(2, 1),
          P(-1, 2),
          P(1, 2),
        ];

        if (options.contains(P(x0 - x1, y0 - y1))) {
          return true;
        }

        return false;

      case PieceType.bishop:
        return isDirMoveLegal(bishopDirs);

      case PieceType.pawn:
        var isWhite = s0.color == PieceColor.white;
        var yDir = isWhite ? -1 : 1;
        var diff = P(x1 - x0, y1 - y0);

        if ((diff == P(0, yDir) && s1 == null) ||
            ((diff == P(-1, yDir) || diff == P(1, yDir)) && s1 != null) ||
            (diff == P(0, 2 * yDir) && y0 == (isWhite ? 6 : 1) && s1 == null)) {
          return true;
        }

        return false;
    }
  }

  List<P> getLegalMoves(int x, int y) {
    var moves = <P>[];

    var s0 = _layout[x][y]!;

    void addLegalOptionMoves(List<P> options) {
      for (var option in options) {
        var x1 = x + option.x;
        var y1 = y + option.y;
        if (!isOnBoard(x1, y1)) continue;
        var s1 = _layout[x1][y1];
        if (s1 == null || s1.color != s0.color) moves.add(P(x1, y1));
      }
    }

    void addLegalDirMoves(List<P> dirs) {
      for (int j = 0; j < dirs.length; j++) {
        for (int i = 1;; i++) {
          var xi = x + i * dirs[j].x;
          var yi = y + i * dirs[j].y;
          if (!isOnBoard(xi, yi)) break;
          var crnt = _layout[xi][yi];
          if (crnt != null && crnt.color == s0.color) break;
          moves.add(P(xi, yi));
        }
      }
    }
    var rookDirs = [P(0, -1), P(-1, 0), P(1, 0), P(0, 1)];
    var bishopDirs = [P(-1, -1), P(-1, 1), P(1, -1), P(1, 1)];

    switch (s0.type) {
      case PieceType.king:
        addLegalOptionMoves(<P>[
          P(-1, -1), P( 0, -1), P( 1, -1), P(-1,  0),
          P( 1,  0), P(-1,  1), P( 0,  1), P( 1,  1),
        ]);
        break;

      case PieceType.queen:
        addLegalDirMoves(rookDirs + bishopDirs);
        break;

      case PieceType.rook:
        addLegalDirMoves(rookDirs);
        break;

      case PieceType.knight:
      addLegalOptionMoves(<P>[
          P(-1, -2), P( 1, -2), P(-2, -1), P( 2, -1),
          P(-2,  1), P( 2,  1), P(-1,  2), P( 1,  2),
        ]);
        break;

      case PieceType.bishop:
        addLegalDirMoves(rookDirs + bishopDirs);
        break;

      case PieceType.pawn:
        var isWhite = s0.color == PieceColor.white;
        var yDir = isWhite ? -1 : 1;
        var opCons = [
          OpCon(P(0, 2), (
            Piece? s1) => y == (isWhite ? 6 : 1) &&
            _layout[x][(isWhite ? 5 : 2)] == null &&
            s1 == null
          ),
          OpCon(P(0, 1), (Piece? s1) => s1 == null),
          OpCon(P(-1, 1), (Piece? s1) => s1 != null && s1.type != s0.type),
          OpCon(P(-1, 1), (Piece? s1) => s1 != null && s1.type != s0.type),
        ];
        for (var opCon in opCons) {
          var op = P(opCon.op.x, opCon.op.y * yDir);
          var s1 = _layout[x + op.x][y + op.y];
          if (opCon.con(s1)) {
            moves.add(P(x, y) + op);
          }
        }
        break;
    }

    return moves;
  }

  void draw({P? pieceSquare, List<P> legalMoves = const []}) {
    var str = "";

    var legalMovesLayout = List.generate(8, (x)=>List.filled(8, false));
    for (var move in legalMoves) {
      if (!isOnBoard(move.x, move.y)) continue;
      legalMovesLayout[move.x][move.y] = true;
    }

    for (int y = 0; y < _layout.length; y++) {
      str += '${8 - y} ';
      for (int x = 0; x < _layout[0].length; x++) {
        var piece = _layout[x][y];
        var isOnLight = x % 2 != y % 2;

        String p = 
          (piece != null ? pieceToIcon(piece, isOnLight) : ' ') +
          (legalMovesLayout[x][y] ? '*' : ' ');

        str += chalk.hex(0x000).onHex(
          pieceSquare == P(x, y) ? 0x00FF00 : isOnLight ? 0xE5E5E5 : 0x3C81C1
        )(p);
      }
      str += '*\n';
    }
    str += '  A B C D E F G H';

    print('$str\n');
  }
}

int toCode(String char) {
  return char.codeUnitAt(0);
}

int? charToX(String char) {
  var code = toCode(char);

  if (code >= toCode('a') && code <= toCode('h')) {
    return code - toCode('a');
  } else if (code >= toCode('A') && code <= toCode('H')) {
    return code - toCode('A');
  }

  return null;
}

int? charToY(String char) {
  var digit = toCode(char) - toCode('1');

  if (digit >= 0 && digit <= 8) {
    return 7 - digit;
  }

  return null;
}

bool isOnBoard(int x, int y) {
  return x >= 0 && x < 8 && y >= 0 && y < 8;
}

// Layout stringToLayout(String str) {
//   Layout layout = List.generate(8, (_) => List.filled(8, null));

//   str = str.replaceAll('\n', '');

//   for (int i = 0; i < 8 * 8; i++) {
//     layout[i % 8][i ~/ 8] = piecesMap[str[i]];
//   }

//   return layout;
// }