import 'package:flutter/material.dart';

import './constants.dart';

ThemeData basicTheme() => ThemeData(
      brightness: Brightness.dark,
      primaryColor: kSecondaryColor,
      secondaryHeaderColor: kSecondaryColor,
      scaffoldBackgroundColor: kBackgroundColor,
      useMaterial3: true,
      
      //cardTheme
      cardTheme: CardTheme(
        margin: const EdgeInsets.symmetric(vertical:5.0 , horizontal: 12.0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape:
              const Border(bottom: BorderSide(color: Color(242834), width: 2)),
          surfaceTintColor: kAccentColor,
          elevation: 3,
          color: kBackgroundColor
          // color: kSecondaryColor
          ),

      //appBarTheme
      appBarTheme: AppBarTheme(
          backgroundColor: kBackgroundColor,
          centerTitle: false,
          // elevation: 15,
          titleTextStyle: TextStyle(color: Colors.lightBlueAccent),
          shape:
              const Border(bottom: BorderSide(color: Colors.white, width: 1)),
          iconTheme: defaultIconThemeData),

      //bottomNavigationBarTheme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        // unselectedIconTheme: defaultIconThemeData.copyWith(size: 25.0),
        // selectedIconTheme: defaultIconThemeData.copyWith(size: 25.0),
        backgroundColor: kPrimaryColor,
        selectedItemColor: kSecondaryColor,
        unselectedItemColor: kSecondaryColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),

      drawerTheme: DrawerThemeData(backgroundColor: kBackgroundColor)
    );