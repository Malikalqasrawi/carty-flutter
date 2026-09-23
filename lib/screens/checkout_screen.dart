import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _paymentMethods = [
    'Cash on Delivery',
    'Credit Card',
    'Debit Card',
    'CliQ',
  ];

  static const _instructionOptions = [
    "Don't ring the bell",
    'Leave at the door',
    'Call me on arrival',
    'Leave with neighbor',
    'Contactless delivery',
  ];

  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _payment = _paymentMethods.first;
  final Set<String> _instructions = {};

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final orders = context.read<OrderProvider>();
    final cart = context.read<CartProvider>();

    final orderId = await orders.placeOrder(
      address: _addressController.text.trim(),
      paymentMethod: _payment,
      instructions: _instructions.toList(),
    );

    if (!mounted) return;

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error ?? 'Order failed')),
      );
      return;
    }

    cart.clearLocal(); // the database already emptied the cart

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.price, size: 56),
        title: const Text('Order placed!'),
        content: Text('Your order #$orderId is on its way.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    // Back to Home, then open "My Orders".
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.pushNamed(AppRoutes.orders);
  }

  Widget _section({required IconData icon, required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final placing = context.watch<OrderProvider>().isPlacing;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(
              icon: Icons.location_on_outlined,
              title: 'Delivery address',
              child: TextFormField(
                controller: _addressController,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Please enter your full address'
                    : null,
                decoration: const InputDecoration(
                  hintText: 'e.g. Amman, Khalda, Street 10, Building 5',
                ),
              ),
            ),
            const SizedBox(height: 12),

            _section(
              icon: Icons.payment_outlined,
              title: 'Payment method',
              // RadioGroup holds the selected value for all the radios inside it.
              child: RadioGroup<String>(
                groupValue: _payment,
                onChanged: (value) {
                  if (value != null) setState(() => _payment = value);
                },
                child: Column(
                  children: [
                    for (final method in _paymentMethods)
                      RadioListTile<String>(
                        value: method,
                        title: Text(method),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            _section(
              icon: Icons.delivery_dining_outlined,
              title: 'Delivery instructions',
              child: Column(
                children: [
                  for (final option in _instructionOptions)
                    CheckboxListTile(
                      value: _instructions.contains(option),
                      title: Text(option),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) => setState(() {
                        if (checked == true) {
                          _instructions.add(option);
                        } else {
                          _instructions.remove(option);
                        }
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _section(
              icon: Icons.receipt_outlined,
              title: 'Order summary',
              child: Column(
                children: [
                  for (final item in cart.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('${item.quantity} × ${item.product.name}')),
                          Text('${item.lineTotal.toStringAsFixed(2)} JOD'),
                        ],
                      ),
                    ),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Text(
                        '${cart.totalPrice.toStringAsFixed(2)} JOD',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: (placing || cart.isEmpty) ? null : _placeOrder,
            child: placing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Place order', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
