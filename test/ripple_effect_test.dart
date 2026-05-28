import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  testWidgets('ripple effect reacts to drop changes', (WidgetTester tester) async {
    final Drop<int> source = Drop<int>(0, label: 'source');
    var fired = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RippleEffect(
          source: source,
          onRipple: () {
            fired++;
          },
          child: const SizedBox.shrink(),
        ),
      ),
    );

    source.value = 1;
    source.value = 2;
    await tester.pump();

    expect(fired, 2);
  });
}
