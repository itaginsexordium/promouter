import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database.dart';
import 'order_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int? _selectedStoreId;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Store>>(
            future: db.getAllStores(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final stores = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Выберите магазин'),
                  value: _selectedStoreId,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStoreId = newValue;
                    });
                  },
                  items: stores.map((store) {
                    return DropdownMenuItem<int>(
                      enabled: store.isActive,
                      value: store.id,
                      child: Text(
                        store.name,
                        style: TextStyle(
                            color: store.isActive
                                ? Colors.amber
                                : Colors.deepOrange),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<CartItem>>(
              stream: db.watchAllCartItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cartItems = snapshot.data!;
                return ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    return ListTile(
                      title: Text('Product ID: ${cartItem.productId}'),
                      subtitle: Text('Quantity: ${cartItem.quantity}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          db.deleteCartItem(cartItem);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_shopping_cart),
        onPressed: () async {
          if (_selectedStoreId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Пожалуйста, выберите магазин')),
            );
            return;
          }

          final cartItems = await db.getAllCartItems();
          if (cartItems.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Корзина пуста')),
            );
            return;
          }

          await db.createOrder(_selectedStoreId!, cartItems);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заказ создан')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderPage()),
          );
        },
      ),
    );
  }
}
