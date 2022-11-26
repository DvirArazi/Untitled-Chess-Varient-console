// ignore_for_file: file_names

import 'dart:math';

import 'package:new_chess_console/piece.dart';

typedef P = Point<int>;
typedef Layout = List<List<Piece?>>;

class OpCon {
  const OpCon(this.op, this.con);

  final P op;
  final bool Function(Piece?) con;
}