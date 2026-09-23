import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutterprojectfinalfr/core/validators.dart';
import 'package:flutterprojectfinalfr/models/cart_item.dart';
import 'package:flutterprojectfinalfr/models/order.dart';
import 'package:flutterprojectfinalfr/models/product.dart';
import 'package:flutterprojectfinalfr/widgets/quantity_stepper.dart';

void main() {
  const apple = Product(
    id: 1,
    categoryId: 1,
    name: 'Red Apple',
    price: 2.99,
    unit: 'kg',
    imageUrl: '',
  );

  group('Models', () {
    test('Product.fromMap reads Supabase row (int price is ok)', () {
      final p = Product.fromMap({
        'id': 7,
        'category_id': 2,
        'name': 'Tomato',
        'price': 1,
        'unit': 'kg',
        'image_url': 'x.png',
      });
      expect(p.price, 1.0);
      expect(p.priceLabel, '1.00 JOD / kg');
    });

    test('CartItem line total', () {
      const item = CartItem(product: apple, quantity: 3);
      expect(item.lineTotal, closeTo(8.97, 0.001));
    });

    test('Order.fromMap with nested items', () {
      final order = Order.fromMap({
        'id': 12,
        'created_at': '2026-09-23T10:00:00Z',
        'address': 'Amman',
        'payment_method': 'CliQ',
        'instructions': ['Leave at the door'],
        'total': 5.98,
        'status': 'pending',
        'order_items': [
          {'product_name': 'Red Apple', 'unit_price': 2.99, 'quantity': 2},
        ],
      });
      expect(order.itemCount, 2);
      expect(order.items.first.lineTotal, closeTo(5.98, 0.001));
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email('malik@test.com'), isNull);
      expect(Validators.email('malik@'), isNotNull);
    });

    test('Jordan phone', () {
      expect(Validators.jordanPhone('+962791234567'), isNull);
      expect(Validators.jordanPhone('0791234567'), isNotNull);
    });

    test('password min 10', () {
      expect(Validators.password('1234567890'), isNull);
      expect(Validators.password('short'), isNotNull);
    });
  });

  testWidgets('QuantityStepper calls + and -', (tester) async {
    int plus = 0;
    int minus = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityStepper(
            quantity: 2,
            onIncrement: () => plus++,
            onDecrement: () => minus++,
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.remove));
    expect(plus, 1);
    expect(minus, 1);
  });
}
