
import 'package:new_chess_console/game.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("Stalemate is a win", () {
    var matcher = isCheckmated(
      stringToLayout(
        "k       "
        "  Q     "
        "        "
        "        "
        "        "
        "        "
        "        "
        "        "
      ),
      false
    );

    expect(true, matcher);
  });

  test("Checkmate", () {
    var matcher = isCheckmated(
      stringToLayout(
        "k       "
        " Q      "
        "  B     "
        "        "
        "        "
        "        "
        "        "
        "        "
      ),
      false
    );

    expect(true, matcher);
  });

  test("No  checkmate", () {
    var matcher = isCheckmated(
      stringToLayout(
        "k       "
        "   Q    "
        "        "
        "        "
        "        "
        "        "
        "        "
        "        "
      ),
      false
    );

    expect(false, matcher);
  });

  test("Queen can be captured", () {
    var matcher = isCheckmated(
      stringToLayout(
        "k       "
        " Q      "
        "        "
        "        "
        "        "
        "        "
        "        "
        "        "
      ),
      false
    );

    expect(false, matcher);
  });
}


