import 'package:dba/db/database.dart';
import 'package:dba/pages/store_add_pagede.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Заведения'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddStorePage()));
              },
            ),
          ],
        ),
        body: StreamBuilder<List<Store>>(
          stream: db.watchAllStores(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return FutureBuilder<List<Store>>(
              future: db.getAllStores(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final stores = snapshot.data!;
                return ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return ListTile(
                      title: Text(store.name),
                      subtitle: Text('${store.address} - ${store.phone}'),
                      trailing: Switch(
                        value: store.isActive,
                        onChanged: (value) {
                          final updatedStore = Store(
                              id: store.id,
                              name: store.name,
                              address: store.address,
                              phone: store.phone,
                              isActive: value);
                          db.updateStoreInfo(updatedStore);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ));
  }
}
