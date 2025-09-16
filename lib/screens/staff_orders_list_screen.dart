import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/staff_order.dart';
import 'staff_orders_upsert_screen.dart';

class StaffOrdersListScreen extends StatefulWidget {
  const StaffOrdersListScreen({super.key});

  @override
  State<StaffOrdersListScreen> createState() => _StaffOrdersListScreenState();
}

class _StaffOrdersListScreenState extends State<StaffOrdersListScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Future<List<StaffOrder>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = _db.getAllStaffOrders();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureOrders = _db.getAllStaffOrders();
    });
    await _futureOrders;
  }

  Future<void> _deleteOrder(StaffOrder order) async {
    if (order.id == null) return;
    await _db.deleteStaffOrder(order.id!);
    await _refresh();
  }

  void _openCreate() async {
    final bool? changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const StaffOrdersUpsertScreen(),
      ),
    );
    if (changed == true) {
      await _refresh();
    }
  }

  void _openEdit(StaffOrder order) async {
    final bool? changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StaffOrdersUpsertScreen(existing: order),
      ),
    );
    if (changed == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Orders'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add Order'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<StaffOrder>>(
          future: _futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }
            final orders = snapshot.data ?? const <StaffOrder>[];
            if (orders.isEmpty) {
              return const Center(
                child: Text('No staff orders found. Tap + to add one.'),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order.item),
                  subtitle: Text(
                    '${order.staffName} • Qty: ${order.quantity} • '
                    '${_formatDate(order.orderDate)}',
                  ),
                  onTap: () => _openEdit(order),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete order?'),
                          content: const Text(
                            'This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _deleteOrder(order);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

