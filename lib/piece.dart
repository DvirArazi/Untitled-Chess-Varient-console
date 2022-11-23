import 'dart:ffi';
import 'dart:math';

import 'package:new_chess_console/Utils.dart';

abstract class Piece {
  const Piece(this.isWhite, {required this.symbol});

  final bool isWhite;
  final String symbol;

  List<P> getPossibleMoves(P pos, Layout layout);
  @override
  String toString() {
    return symbol;
  }
}
