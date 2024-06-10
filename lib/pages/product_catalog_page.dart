import 'package:dba/db/database.dart';
import 'package:dba/pages/cart_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ProductCatalogPage extends StatelessWidget {
  const ProductCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.shopping_cart_outlined),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CartPage()),
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Продукты'),
        actions: [],
      ),
      body: FutureBuilder<List<Product>>(
        future: db.getAllProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductListItem(product: product, db: db);
            },
          );
        },
      ),
    );
  }
}

class ProductListItem extends StatefulWidget {
  final Product product;
  final AppDatabase db;

  const ProductListItem({required this.product, required this.db});

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Card(
      child: ListTile(
        leading: Image.network(product.imageUrl ?? ''),
        title: Text(product.name),
        isThreeLine: true,
        dense: true,
        subtitle: Text('Цена: ${product.price}\nАртикул: ${product.partNumber}'),
        trailing: Container(
          width: 155,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.amber),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text('$quantity'),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.amber),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                   IconButton(
                    iconSize: 20,
                icon: const Icon(Icons.shopping_cart, color: Colors.amber),
                onPressed: () {
                  final cartItem = CartItemsCompanion(
                    productId: Value(product.id),
                    quantity: Value(quantity),
                  );
                  widget.db.insertCartItem(cartItem);
                },
              ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}