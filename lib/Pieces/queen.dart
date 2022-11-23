import '../Utils.dart';
import '../piece.dart';

class Queen extends Piece {
  const Queen(super.isWhite) : super(symbol: isWhite ? '♛' : '♕');

  @override
  List<P> getPossibleMoves(P pos, Layout layout) {
    // TODO: implement getPossibleMoves
    throw UnimplementedError();
  }
}