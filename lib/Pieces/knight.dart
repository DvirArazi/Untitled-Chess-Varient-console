import '../Utils.dart';
import '../piece.dart';

class Knight extends Piece {
  const Knight(super.isWhite) : super(symbol: isWhite ? '♞' : '♘');

  @override
  List<P> getPossibleMoves(P pos, Layout layout) {
    // TODO: implement getPossibleMoves
    throw UnimplementedError();
  }
}