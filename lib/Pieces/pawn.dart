import '../Utils.dart';
import '../piece.dart';

class Pawn extends Piece {
  const Pawn(super.isWhite) : super(symbol: isWhite ? '♟︎' : '♙');

  @override
  List<P> getPossibleMoves(P pos, Layout layout) {
    // TODO: implement getPossibleMoves
    throw UnimplementedError();
  }
}