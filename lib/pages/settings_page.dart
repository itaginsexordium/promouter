
import 'package:drift/drift.dart' hide Column;
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _userPhone;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    var _dbViewerOpen = false;  



    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки')
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.data_array, color: Colors.amber,),
        onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DriftDbViewer(db)));
      },),
      body: FutureBuilder<Setting>(
        future: db.getSettings().catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load settings: $error'),
          ));
          return null;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Настройки не найдено'));
          }

          final settings = snapshot.data!;
          _userName = _userName ?? settings.userName;
          _userPhone = _userPhone ?? settings.userPhone;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _userName,
                    decoration: const InputDecoration(labelText: 'Ф.И.О'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста введите ваше Ф.И.О';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userName = value;
                    },
                  ),
                  TextFormField(
                    initialValue: _userPhone,
                    decoration:  const InputDecoration(labelText: 'Номер телефона'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста введите ваш номер телефона';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userPhone = value;
                    },
                  ),
                  const SizedBox(height: 50.0,),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final updatedSettings = SettingsCompanion(
                          id: const Value(1),
                          userName: Value(_userName!),
                          userPhone: Value(_userPhone!),
                        );
                        db.updateSettings(updatedSettings).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Настройки обновлены успешно')),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Не удалось обновить настройки: $error')),
                          );
                        });
                      }
                    },
                    child: const Text('сохранить'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
