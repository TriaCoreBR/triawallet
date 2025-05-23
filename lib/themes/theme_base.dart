import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

final ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.green,  // Alterado de pink para green
  onPrimary: Colors.white,
  secondary: Colors.grey.shade900,
  onSecondary: Colors.white60,
  tertiary: Colors.white,
  onTertiary: Colors.black,
  surface: Colors.black,
  onSurface: Colors.white,
  error: Colors.red,
  onError: Colors.white,
);

final AppBarTheme appBarTheme = AppBarTheme(
  backgroundColor: Colors.black,
  centerTitle: true,
  titleTextStyle: TextStyle(
    fontSize: 22,
    fontFamily: "roboto",
    fontWeight: FontWeight.bold,
  ),
  iconTheme: IconThemeData(color: Colors.white),
);

final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
  ),
  filled: true,
  fillColor: colorScheme.secondary,
  hintStyle: TextStyle(color: Colors.grey.shade500),
);

final BottomNavigationBarThemeData bottomNavigationBarTheme =
    BottomNavigationBarThemeData(
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.white,
      backgroundColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );

final DropdownMenuThemeData dropdownMenuTheme = DropdownMenuThemeData(
  menuStyle: MenuStyle(
    backgroundColor: WidgetStateProperty.all(Colors.grey.shade900),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.transparent),
      ),
    ),
  ),
  inputDecorationTheme: inputDecorationTheme,
);

final PinTheme pinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(
    fontSize: 20,
    color: colorScheme.onSecondary,
    fontFamily: "roboto",
  ),
  decoration: BoxDecoration(
    border: Border.all(color: colorScheme.primary),
    borderRadius: BorderRadius.circular(8),
  ),
);

final ThemeData themeData = ThemeData(
  colorScheme: colorScheme.copyWith(
    primary: Colors.green,  // Cor primária para botões elevados
    secondary: Colors.green,  // Cor para botões de texto e links
  ),
  appBarTheme: appBarTheme,
  bottomNavigationBarTheme: bottomNavigationBarTheme,
  inputDecorationTheme: inputDecorationTheme,
  dropdownMenuTheme: dropdownMenuTheme,
  fontFamily: "roboto",
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.green,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
    ),
  ),
  useMaterial3: true,
);
