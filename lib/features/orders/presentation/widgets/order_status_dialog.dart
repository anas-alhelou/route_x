// lib/features/orders/presentation/widgets/order_status_dialog.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusDialog extends StatelessWidget {
  const OrderStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  final OrderStatusType currentStatus;
  final ValueChanged<OrderStatusType> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: OrderStatusType.values.map((status) {
          final isSelected = status == currentStatus;
          return ListTile(
            title: Text(status.name.toUpperCase()),
            trailing: isSelected ? const Icon(Icons.check, color: AppColors.brandMain) : null,
            onTap: () {
              onStatusSelected(status);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
