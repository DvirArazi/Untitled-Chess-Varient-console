import '../Utils.dart';
import '../piece.dart';

class Rook extends Piece {
  const Rook(super.isWhite) : super(symbol: isWhite ? '♜' : '♖');

  @override
  List<P> getPossibleMoves(P pos, Layout layout) {
    var moves = <P>[];
    for (int x = pos.x + 1; x < 8; x++) {
      if (layout[x][pos.y] == null) break;
      moves.add(P(x, pos.y));
    }
    for (int x = pos.x - 1; x >= 0; x--) {
      if (layout[x][pos.y] == null) break;
      moves.add(P(x, pos.y));
    }
    for (int y = pos.y + 1; y < 8; y++) {
      if (layout[pos.x][y] == null) break;
      moves.add(P(pos.x, y));
    }
    for (int y = pos.y - 1; y >= 0; y--) {
      if (layout[pos.x][y] == null) break;
      moves.add(P(pos.x, y));
    }

    return moves;
  }
}