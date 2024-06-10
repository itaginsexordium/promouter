
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get partNumber => text().nullable()();
}

class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get phone => text()();
  BoolColumn get isActive => boolean()();
}

class CartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().customConstraint('NOT NULL REFERENCES products(id)')();
  IntColumn get quantity => integer()();
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get storeId => integer().customConstraint('NOT NULL REFERENCES stores(id)')();
  DateTimeColumn get orderDate => dateTime().withDefault(currentDateAndTime)();
}

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().customConstraint('NOT NULL REFERENCES orders(id)')();
  IntColumn get productId => integer().customConstraint('NOT NULL REFERENCES products(id)')();
  IntColumn get quantity => integer()();
}

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userName => text().withDefault(const Constant('User'))();
  TextColumn get userPhone => text().withDefault(const Constant('1234567890'))();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db11298.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Products, Stores, CartItems, Orders, OrderItems, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection()) {
    _addInitialData();
  }

  @override
  int get schemaVersion => 1;

  Future<Setting> getSettings() => select(settings).getSingle();
  Future<List<Product>> getAllProducts() => select(products).get();
  Future<List<Store>> getAllStores() => select(stores).get();
  Stream<List<Store>> watchAllStores() => select(stores).watch();
  Future<List<CartItem>> getAllCartItems() => select(cartItems).get();
  Stream<List<CartItem>> watchAllCartItems() => select(cartItems).watch();
  Future<List<Order>> getAllOrders() => select(orders).get();
  Future<List<OrderItem>> getOrderItems(int orderId) =>
      (select(orderItems)..where((tbl) => tbl.orderId.equals(orderId))).get();

  Future<int> insertProduct(ProductsCompanion product) => into(products).insert(product);
  Future<int> insertStore(StoresCompanion store) => into(stores).insert(store);
  Future<int> insertCartItem(CartItemsCompanion cartItem) => into(cartItems).insert(cartItem);
  Future<int> insertOrder(OrdersCompanion order) => into(orders).insert(order);
  Future<int> insertOrderItem(OrderItemsCompanion orderItem) => into(orderItems).insert(orderItem);

  Future<void> deleteCartItem(CartItem cartItem) => delete(cartItems).delete(cartItem);

  Future<void> updateStoreInfo(Store store) => update(stores).replace(store);

  Future<void> updateSettings(SettingsCompanion settings) =>
      update(this.settings).replace(settings);

  Future<List<OrderWithProduct>> getOrderWithProducts(int orderId) {

    final query = (select(orderItems)
          ..where((tbl) => tbl.orderId.equals(orderId)))
        .join([
      innerJoin(products, products.id.equalsExp(orderItems.productId)),
      innerJoin(orders, orders.id.equalsExp(orderItems.orderId)),
      innerJoin(stores, stores.id.equalsExp(orders.storeId)),
      crossJoin(settings)
    ]);

    return query.map((row) {
      return OrderWithProduct(
        row.readTable(orders),
        row.readTable(orderItems),
        row.readTable(products),
        row.readTable(stores),
        row.readTable(settings),
      );
    }).get();
  }

  Future<void> createOrder(int storeId, List<CartItem> cartItemss) async {
    await transaction(() async {
      final orderId = await into(orders).insert(OrdersCompanion(
        storeId: Value(storeId),
      ));

      for (var cartItem in cartItemss) {
        await into(orderItems).insert(OrderItemsCompanion(
          orderId: Value(orderId),
          productId: Value(cartItem.productId),
          quantity: Value(cartItem.quantity),
        ));
      }

      for (var cartItem in cartItemss) {
        await delete(cartItems).delete(cartItem);
      }
    });
  }

  Future<void> _addInitialData() async {
    final productCount =
        await select(products).get().then((value) => value.length);
    final settingsCount =
        await select(settings).get().then((value) => value.length);

    if (settingsCount == 0) {
      await into(settings).insert(const SettingsCompanion(
        id:  Value(1),
        userName:  Value('Тестовый'),
        userPhone:  Value('0500000000'),
      ));
    }

    if (productCount == 0) {
      await into(products).insert( const ProductsCompanion(
        name: Value('Шоколадные батончики - Количество в упаковке: 24 шт.'),
        price: Value(480.0),
        imageUrl: Value('https://www.deloks.ru/upload/iblock/17f/6f3iumfp2yu07v8qbjqd24fj1fempe5t/shokoladnye_batonchiki_snickers_32_shtuki_po_20_g_1_full.jpg'),
        partNumber: Value('CHOCO-24'),
      ));
      await into(products).insert(const  ProductsCompanion(
        name: Value('Гранола - Количество в упаковке: 10 пакетов по 500 г'),
        price: Value(1500.0),
        imageUrl: Value('https://globus-online.kg/upload/iblock/3f7/3f77f1c7ba375f5abc5ce89cffd562d1.png'),
        partNumber: Value('GRAN-10'),
      ));
      await into(products).insert(const  ProductsCompanion(
        name: Value('Минеральная вода - Количество в упаковке: 12 бутылок по 1,5 литра'),
        price: Value(720.0),
        imageUrl: Value('https://main-cdn.sbermegamarket.ru/big1/hlr-system/-74/154/503/211/217/21/600003050613b0.jpeg'),
        partNumber: Value('WATER-12'),
      ));
      await into(products).insert(const  ProductsCompanion(
        name: Value('Печенье - Количество в упаковке: 20 пачек по 200 г'),
        price: Value(1000.0),
        imageUrl: Value('https://shop.samberi.com/upload/iblock/f69/f69a0ccb3f658050f345511ae71457f9.jpg'),
        partNumber: Value('COOKIE-20'),
      ));
      await into(products).insert(const  ProductsCompanion(
        name: Value('Чипсы  - Количество в упаковке: 24 тубуса по 150 г'),
        price: Value(1440.0),
        imageUrl: Value('https://main-cdn.sbermegamarket.ru/upload/BgpNrZVdYxQQZIdH68AUQ_65d663871d921.jpg'),
        partNumber: Value('CHIPS-24'),
      ));
      await into(products).insert(const  ProductsCompanion(
        name: Value('Зубная паста - Количество в упаковке: 12 туб по 100 мл'),
        price: Value(600.0),
        imageUrl: Value('https://may24.ru/upload/iblock/60e/60e18187e51787bbc1bd54066b2c26dc.jpg'),
        partNumber: Value('TOOTH-12'),
      ));
      await into(products).insert(const  ProductsCompanion(
        name: Value('Хлопья для завтрака - Количество в упаковке: 8 коробок по 500 г'),
        price: Value(1200.0),
        imageUrl: Value('https://ir.ozone.ru/s3/multimedia-g/c1000/6398063284.jpg'),
        partNumber: Value('CEREAL-8'),
      ));
      await into(products).insert(const  ProductsCompanion(
        name: Value('Оливковое масло - Количество в упаковке: 6 бутылок по 1 литру'),
        price: Value(3600.0),
        imageUrl: Value('https://www.ripi-test.ru/files/images/tests/2014-09-05-09b.jpg'),
        partNumber: Value('OLIVE-6'),
      ));

      await into(products).insert(const  ProductsCompanion(
        name: Value('Сок - Количество в упаковке: 12 пакетов по 1 литру'),
        price: Value(900.0),
        imageUrl: Value('https://ir.ozone.ru/s3/multimedia-u/c1000/6331933026.jpg'),
        partNumber: Value('JUICE-12'),
      ));

      await into(products).insert(const  ProductsCompanion(
        name: Value('Йогурт  - Количество в упаковке: 16 баночек по 200 мл'),
        price: Value(1280.0),
        imageUrl: Value('https://molokonadom.ru/wa-data/public/shop/products/11/75/27511/images/3021/1308.970.png'),
        partNumber: Value('YOGURT-16'),
      ));
    }
  }
}


class OrderWithShop {
  final Store store;
  final Order order;

  OrderWithShop(this.store, this.order);
}


class OrderWithProduct {
  final Order order;
  final OrderItem orderItem;
  final Product product;
  final Store store;
  final Setting settings;

  OrderWithProduct(this.order, this.orderItem, this.product, this.store, this.settings);
}
