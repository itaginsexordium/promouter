import 'package:dba/pages/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database.dart';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const  Text('Заказы'),
      ),
      body: FutureBuilder<List<Order>>(
        future: db.getAllOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return ListTile(
                title: Text('Заказ #${order.id}'),
                subtitle: Text('магазин ID: ${order.storeId}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(order: order, orderId: order.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
