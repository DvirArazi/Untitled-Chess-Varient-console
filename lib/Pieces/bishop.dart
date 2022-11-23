import '../Utils.dart';
import '../piece.dart';

class Bishop extends Piece {
  const Bishop(super.isWhite) : super(symbol: isWhite ? '♝' : '♗');

  @override
  List<P> getPossibleMoves(P pos, Layout layout) {
    // TODO: implement getPossibleMoves
    throw UnimplementedError();
  }
}