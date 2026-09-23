import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = provider.orders;

    Widget body;
    if (provider.isLoading && orders.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (orders.isEmpty) {
      body = ListView(
        // ListView so pull-to-refresh still works when empty.
        children: const [
          SizedBox(height: 160),
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Center(child: Text('No orders yet', style: TextStyle(fontSize: 18))),
        ],
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _OrderCard(order: orders[index]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: RefreshIndicator(onRefresh: provider.load, child: body),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text('Order #${order.id}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${_formatDate(order.createdAt)} • ${order.itemCount} items'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${order.total.toStringAsFixed(2)} JOD',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.price),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(order.status, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text('${item.quantity} × ${item.productName}')),
                  Text('${item.lineTotal.toStringAsFixed(2)} JOD'),
                ],
              ),
            ),
          const Divider(),
          Text('Address: ${order.address}'),
          Text('Payment: ${order.paymentMethod}'),
          if (order.instructions.isNotEmpty)
            Text('Instructions: ${order.instructions.join(', ')}'),
        ],
      ),
    );
  }
}
