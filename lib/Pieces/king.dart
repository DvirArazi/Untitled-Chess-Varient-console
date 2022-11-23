import '../Utils.dart';
import '../piece.dart';

class King extends Piece {
  const King(super.isWhite) : super(symbol: isWhite ? '♚' : '♔');

  @override
  List<P> getPossibleMoves(P pos, Layout layout) {
    // TODO: implement getPossibleMoves
    throw UnimplementedError();
  }
}