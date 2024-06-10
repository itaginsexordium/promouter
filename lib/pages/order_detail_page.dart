import 'package:dba/db/database.dart';
import 'package:dba/services/telegram_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({required this.order, required int orderId});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final telegramService = TelegramService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказ'),
      ),
      body: FutureBuilder<List<OrderWithProduct>>(
        future: db.getOrderWithProducts(order.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final orderWithProducts = snapshot.data!;
          if (orderWithProducts.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final store = orderWithProducts.first.store;
          final settings = orderWithProducts.first.settings;
          double total = 0;

          orderWithProducts.forEach((orderWithProduct) {
            final product = orderWithProduct.product;
            total += product.price * orderWithProduct.orderItem.quantity;
          });

          return Column(
            children: [
              Card.outlined(
                color: Colors.grey.shade700,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                        iconColor: Colors.amber,
                        isThreeLine: true,
                        leading: const Icon(
                          Icons.shopping_bag_outlined,
                        ),
                        title: Text('${store.name} - ${store.address}'),
                        subtitle: Text(
                            'Тел: ${store.phone}\nСтоймость: ${total.toStringAsFixed(2)} kgs',
                            style: const TextStyle(fontSize: 15)),
                        trailing: IconButton(
                          icon: const Icon(Icons.send_outlined),
                          onPressed: () async {
                            final message = _createOrderMessage(
                                store, orderWithProducts, settings, total);

                            try {
                              await telegramService.sendOrder(message);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Заказ отправлен в Telegram чат')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Ошибка отправки заказа./n' )));
                            }
                          },
                        )),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: orderWithProducts.length,
                  itemBuilder: (context, index) {
                    final orderWithProduct = orderWithProducts[index];
                    final product = orderWithProduct.product;
                    final itemTotal =
                        product.price * orderWithProduct.orderItem.quantity;

                    return Card(
                      child: ListTile(
                        title: Text('${product.name} - ${product.partNumber}'),
                        subtitle: Text(
                            'Количество: ${orderWithProduct.orderItem.quantity},\nцена за ед: ${product.price}c\nСтоймость: ${itemTotal.toStringAsFixed(2)}c'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _createOrderMessage(
      Store store,
      List<OrderWithProduct> orderWithProducts,
      Setting settings,
      double total) {
    final buffer = StringBuffer();
    buffer.writeln('🍥✅Новый заказ✅🍥');
    buffer.writeln('🏪Магазин: ${store.name} - ${store.address}');
    buffer.writeln('📱Контакт: ${store.phone}');
    buffer.writeln('🛒Пердметы заказа:\n');

    for (var item in orderWithProducts) {
      final product = item.product;
      final itemTotal = product.price * item.orderItem.quantity;
      buffer.writeln(
          '${product.name} - ${product.partNumber}, \nколичество: ${item.orderItem.quantity}, \nстоймость: ${itemTotal.toStringAsFixed(2)}с \n');
    }

    buffer.writeln('\n🪙итог: ${total.toStringAsFixed(2)}с');
    buffer.writeln('🙍‍♂️${settings.userName}, \n📞${settings.userPhone}');
    return buffer.toString();
  }
}
