import 'dart:io';
import 'dart:math';

import 'package:chalkdart/chalk.dart';
import 'package:new_chess_console/utils.dart';
import 'package:new_chess_console/piece.dart';
import 'package:okay/okay.dart';

void play() {
  var layout = generateLayout();
  var isWhiteTurn = true;

  start(layout, isWhiteTurn);
}

void start(Layout layout, bool isWhiteTurn) {
  while (true) {
    draw(layout);

    //Break if checkmate
    //==================
    if (isCheckmated(layout, isWhiteTurn)) break;

    //Get player piece square
    //=======================
    stdout.write("${isWhiteTurn ? "White" : "Black"}'s piece square: ");
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

    var legalMovesR = getLegalMoves(layout, isWhiteTurn, x0, y0);
    if (legalMovesR.isErr) {
      switch (legalMovesR.err!) {
        case IlligalMoveError.noPiece:
          print("Invalid input: Position does not contain a piece.");
          break;
        case IlligalMoveError.wrongColor:
          print("Invalid input: First position contains a piece of the "
              "opposite color");
          break;
        case IlligalMoveError.noMoves:
          print("Invalid input: Piece has no moves.");
          break;
        default:
      }
      continue;
    }
    var legalMoves = legalMovesR.ok!;

    draw(layout, pieceSquare: P(x0, y0), legalMoves: legalMoves);

    var success = false;
    while (true) {
      //Get player move square
      //======================
      stdout.write(
          "${isWhiteTurn ? "White" : "Black"}'s move square ('x' to cancel): ");
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

      layout[x1][y1] = layout[x0][y0];
      layout[x0][y0] = null;

      //Promotion
      //=========
      if (layout[x1][y1]?.type == PieceType.pawn) {
        var capturedCounts = getCapturedCount(layout, isWhiteTurn);

        var typeOptions = <PieceType>[];
        capturedCounts.forEach((type, count) {
          if (count > 0) typeOptions.add(type);
        });
        var text = "";

        if (typeOptions.length == 1) {
          layout[x1][y1] = Piece(typeOptions[0], layout[x1][y1]!.color);
          break;
        }

        var charOptions = <String>[];
        for (int i = 0; i < typeOptions.length; i++) {
          charOptions.add(piecesMap.keys
              .firstWhere((k) => piecesMap[k]?.type == typeOptions[i]));
          text += charOptions.last;
          if (i < typeOptions.length - 1) text += "/";
        }

        if (typeOptions.isNotEmpty) {
          while (true) {
            stdout.write("Choose a piece to promote to [$text]: ");
            line = stdin.readLineSync();
            if (line == null) {
              print("Invalid input.");
              continue;
            }
            line = line.toUpperCase();
            if (!charOptions.contains(line)) {
              print("Invalid input: Not an option.");
              continue;
            }

            layout[x1][y1] =
                Piece(piecesMap[line]!.type, layout[x1][y1]!.color);
            break;
          }
        }
      }

      success = true;
      break;
    }
    if (!success) {
      continue;
    }

    isWhiteTurn = !isWhiteTurn;
  }

  print("Checkmate! ${isWhiteTurn ? "Black" : "White"} wins!");
}

Layout generateLayout() {
  Layout layout = List.generate(
      8, (_) => [null, piece('p'), null, null, null, null, piece('P'), null]);

  var rng = Random();

  layout = List.generate(
      8, (_) => [null, piece('p'), null, null, null, null, piece('P'), null]);
  layout[rng.nextInt(4) * 2][7] = Piece(PieceType.bishop, PieceColor.white);
  layout[rng.nextInt(4) * 2 + 1][7] = Piece(PieceType.bishop, PieceColor.white);
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
      if (layout[spot][7] == null) {
        if (j == crnt) break;
        j++;
      }
    }
    layout[spot][7] = pieceTypes[i];
  }
  for (int i = 0; i < 8; i++) {
    layout[i][0] = Piece(layout[i][7]!.type, PieceColor.black);
  }

  return layout;
}

void draw(Layout layout, {P? pieceSquare, List<P> legalMoves = const []}) {
  var str = "";

  var legalMovesLayout = List.generate(8, (x) => List.filled(8, false));
  for (var move in legalMoves) {
    if (!isOnBoard(move.x, move.y)) continue;
    legalMovesLayout[move.x][move.y] = true;
  }

  for (int y = 0; y < 8; y++) {
    str += '${8 - y} ';
    for (int x = 0; x < 8; x++) {
      var piece = layout[x][y];
      var isOnLight = x % 2 != y % 2;

      String p = (piece != null ? pieceToIcon(piece) : ' ') +
          (legalMovesLayout[x][y] ? '*' : ' ');

      str += chalk.hex(0x000).onHex(pieceSquare == P(x, y)
          ? 0x00FF00
          : isOnLight
              ? 0xE5E5E5
              : 0x3C81C1)(p);
    }
    str += '*\n';
  }
  str += '  A B C D E F G H';

  print('$str\n');
}

bool isOnBoard(int x, int y) {
  return x >= 0 && x < 8 && y >= 0 && y < 8;
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

List<Layout> getAllLegalLayouts(Layout layout, bool whiteTurn) {
  var layouts = <Layout>[];

  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      var movesR = getLegalMoves(layout, whiteTurn, x, y);
      if (movesR.isErr) continue;
      var moves = movesR.ok!;
      for (var move in moves) {
        var newLayout = layout.map((e) => e.toList()).toList();
        newLayout[move.x][move.y] = newLayout[x][y];
        newLayout[x][y] = null;
        layouts.add(newLayout);
      }
    }
  }

  return layouts;
}

bool isChecked(Layout layout, bool isWhiteTurn) {
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      var movesR = getLegalMoves(layout, !isWhiteTurn, x, y);
      if (movesR.isErr) continue;
      var moves = movesR.ok!;
      for (var move in moves) {
        var piece = layout[move.x][move.y];
        if (piece?.type == PieceType.king &&
            isWhiteTurn == (piece?.color == PieceColor.white)) return true;
      }
    }
  }

  return false;
}

bool isCheckmated(Layout layout, bool isWhiteTurn) {
  return !layout.any(
        (row) => row.any((piece) =>
            piece == Piece(PieceType.king, boolToColor(isWhiteTurn))),
      ) ||
      getAllLegalLayouts(layout, isWhiteTurn)
          .every((crntLayout) => isChecked(crntLayout, isWhiteTurn));
}

Result<List<P>, IlligalMoveError> getLegalMoves(
    Layout layout, bool isWhiteTurn, int x, int y) {
  var moves = <P>[];

  final s0 = layout[x][y];

  if (s0 == null) {
    return err(IlligalMoveError.noPiece);
  }
  if (isWhiteTurn != (s0.color == PieceColor.white)) {
    return err(IlligalMoveError.wrongColor);
  }

  void addLegalOptionMoves(List<P> options) {
    for (var option in options) {
      var x1 = x + option.x;
      var y1 = y + option.y;
      if (!isOnBoard(x1, y1)) continue;
      var s1 = layout[x1][y1];
      if (s1 == null || s1.color != s0.color) moves.add(P(x1, y1));
    }
  }

  void addLegalDirMoves(List<P> dirs) {
    for (int j = 0; j < dirs.length; j++) {
      for (int i = 1;; i++) {
        var xi = x + i * dirs[j].x;
        var yi = y + i * dirs[j].y;
        if (!isOnBoard(xi, yi)) break;
        var crnt = layout[xi][yi];
        if (crnt != null && crnt.color == s0.color) break;
        moves.add(P(xi, yi));
        if (crnt != null) break;
      }
    }
  }

  var rookDirs = [P(0, -1), P(-1, 0), P(1, 0), P(0, 1)];
  var bishopDirs = [P(-1, -1), P(-1, 1), P(1, -1), P(1, 1)];

  switch (s0.type) {
    case PieceType.king:
      addLegalOptionMoves(<P>[
        P(-1, -1),
        P(0, -1),
        P(1, -1),
        P(-1, 0),
        P(1, 0),
        P(-1, 1),
        P(0, 1),
        P(1, 1),
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
        P(-1, -2),
        P(1, -2),
        P(-2, -1),
        P(2, -1),
        P(-2, 1),
        P(2, 1),
        P(-1, 2),
        P(1, 2),
      ]);
      break;

    case PieceType.bishop:
      addLegalDirMoves(bishopDirs);
      break;

    case PieceType.pawn:
      var isWhite = s0.color == PieceColor.white;
      var yDir = isWhite ? -1 : 1;
      var opCons = [
        OpCon(
            P(0, 2),
            (Piece? s1) =>
                y == (isWhite ? 6 : 1) &&
                layout[x][(isWhite ? 5 : 2)] == null &&
                s1 == null),
        OpCon(P(0, 1), (Piece? s1) => s1 == null),
        OpCon(P(-1, 1), (Piece? s1) => s1 != null && s1.color != s0.color),
        OpCon(P(1, 1), (Piece? s1) => s1 != null && s1.color != s0.color),
      ];
      for (var opCon in opCons) {
        var op = P(x + opCon.op.x, y + opCon.op.y * yDir);
        if (!isOnBoard(op.x, op.y)) continue;
        var s1 = layout[op.x][op.y];
        if (opCon.con(s1)) {
          moves.add(op);
        }
      }
      break;
  }

  if (moves.isEmpty) return err(IlligalMoveError.noMoves);

  return ok(moves);
}

Map<PieceType, int> getCapturedCount(Layout layout, bool isWhiteTurn) {
  var piecesCount = {
    PieceType.queen: 1,
    PieceType.rook: 2,
    PieceType.knight: 2,
    PieceType.bishop: 2,
  };

  for (var row in layout) {
    for (var piece in row) {
      if (piece == null) continue;
      var pieceCount = piecesCount[piece.type];
      if (pieceCount != null &&
          isWhiteTurn == (piece.color == PieceColor.white)) {
        piecesCount[piece.type] = piecesCount[piece.type]! - 1;
      }
    }
  }

  return piecesCount;
}

Layout stringToLayout(String str) {
  Layout layout = List.generate(8, (_) => List.filled(8, null));

  for (int i = 0; i < 8 * 8; i++) {
    var p = piece(str[i]);
    layout[i % 8][i ~/ 8] = p;
  }

  return layout;
}
