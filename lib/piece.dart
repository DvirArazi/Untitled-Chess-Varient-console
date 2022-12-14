import 'dart:core';

import 'package:equatable/equatable.dart';

enum PieceType { king, queen, rook, knight, bishop, pawn }

enum PieceColor { white, black }

class Piece extends Equatable{
  const Piece(this.type, this.color);

  final PieceType type;
  final PieceColor color;
  
  @override
  List<Object?> get props => [type, color];
}

class IconPair {
  const IconPair(this.white, this.black);

  final String white;
  final String black;
}

const Map<PieceType, IconPair> iconsMap = {
  PieceType.king: IconPair('♔', '♚'),
  PieceType.queen: IconPair('♕', '♛'),
  PieceType.rook: IconPair('♖', '♜'),
  PieceType.knight: IconPair('♘', '♞'),
  PieceType.bishop: IconPair('♗', '♝'),
  PieceType.pawn: IconPair('♙', '♟︎'),
};

const Map<String, Piece> piecesMap = {
    'K': Piece(PieceType.king, PieceColor.white),
    'Q': Piece(PieceType.queen, PieceColor.white),
    'R': Piece(PieceType.rook, PieceColor.white),
    'N': Piece(PieceType.knight, PieceColor.white),
    'B': Piece(PieceType.bishop, PieceColor.white),
    'P': Piece(PieceType.pawn, PieceColor.white),
    'k': Piece(PieceType.king, PieceColor.black),
    'q': Piece(PieceType.queen, PieceColor.black),
    'r': Piece(PieceType.rook, PieceColor.black),
    'n': Piece(PieceType.knight, PieceColor.black),
    'b': Piece(PieceType.bishop, PieceColor.black),
    'p': Piece(PieceType.pawn, PieceColor.black),
  };

Piece? piece(String char) {
  return piecesMap[char];
}

String pieceToIcon(Piece piece) {
  var pair = iconsMap[piece.type]!;

  return (piece.color == PieceColor.white)// != isOnLight
      ? pair.white
      : pair.black;
}

PieceColor boolToColor(bool b) {
  return b ? PieceColor.white : PieceColor.black;
}
