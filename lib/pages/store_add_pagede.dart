
import 'package:dba/db/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStorePage extends StatefulWidget {
  const AddStorePage({super.key});

  @override
  _AddStorePageState createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _address;
  String? _phone;
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание заведения'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Наименование'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Адресс'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите адресс';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'контактный телефон'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста введите контактный телефон';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value;
                },
              ),
              SwitchListTile(
                title: const Text('Активный'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final store = StoresCompanion(
                      name: Value(_name!),
                      address: Value(_address!),
                      phone: Value(_phone!),
                      isActive: Value(_isActive),
                    );
                    db.insertStore(store);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Добавить магазин'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}