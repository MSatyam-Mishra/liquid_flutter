import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquidx/liquidx.dart';

void main() {
  testWidgets('watch drop rebuilds only when selected value changes', (
    WidgetTester tester,
  ) async {
    final Drop<int> count = Drop<int>(0, label: 'count');
    var builds = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WatchDrop<int, bool>(
          source: count,
          select: (int value) => value.isEven,
          builder: (BuildContext context, bool isEven, Widget? child) {
            builds++;
            return Text(isEven ? 'even' : 'odd');
          },
        ),
      ),
    );

    expect(find.text('even'), findsOneWidget);
    expect(builds, 1);

    count.value = 2;
    await tester.pump();
    expect(builds, 1);

    count.value = 3;
    await tester.pump();
    expect(builds, 2);
    expect(find.text('odd'), findsOneWidget);
  });
}
