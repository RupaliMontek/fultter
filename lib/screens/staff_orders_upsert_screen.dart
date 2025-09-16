import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/staff_order.dart';

class StaffOrdersUpsertScreen extends StatefulWidget {
  final StaffOrder? existing;
  const StaffOrdersUpsertScreen({super.key, this.existing});

  @override
  State<StaffOrdersUpsertScreen> createState() => _StaffOrdersUpsertScreenState();
}

class _StaffOrdersUpsertScreenState extends State<StaffOrdersUpsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();

  late final TextEditingController _staffController;
  late final TextEditingController _itemController;
  late final TextEditingController _quantityController;
  DateTime _orderDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _staffController = TextEditingController(text: widget.existing?.staffName ?? '');
    _itemController = TextEditingController(text: widget.existing?.item ?? '');
    _quantityController = TextEditingController(
      text: widget.existing?.quantity.toString() ?? '',
    );
    _orderDate = widget.existing?.orderDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _staffController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final int quantity = int.parse(_quantityController.text);
    final StaffOrder payload = StaffOrder(
      id: widget.existing?.id,
      staffName: _staffController.text.trim(),
      item: _itemController.text.trim(),
      quantity: quantity,
      orderDate: _orderDate,
    );

    if (widget.existing == null) {
      await _db.insertStaffOrder(payload);
    } else {
      await _db.updateStaffOrder(payload);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Staff Order' : 'Add Staff Order'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _staffController,
                decoration: const InputDecoration(
                  labelText: 'Staff Name',
                  hintText: 'Enter staff name',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Staff name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: 'Item',
                  hintText: 'Enter item name',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Item is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Quantity is required';
                  final int? parsed = int.tryParse(v);
                  if (parsed == null || parsed <= 0) return 'Enter a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Order Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_formatDate(_orderDate)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final DateTime now = DateTime.now();
                        final DateTime first = DateTime(now.year - 2);
                        final DateTime last = DateTime(now.year + 2);
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          firstDate: first,
                          lastDate: last,
                          initialDate: _orderDate,
                        );
                        if (picked != null) {
                          setState(() => _orderDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: const Text('Pick'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Save Changes' : 'Create Order'),
              ),
            ],
          ),
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

