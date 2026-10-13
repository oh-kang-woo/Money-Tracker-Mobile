import 'package:flutter/material.dart';
// Sesuaikan path import ini dengan lokasi file home_view.dart milikmu
import 'views/home_view.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug di pojok kanan atas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Memanggil HomeView dari folder views sebagai halaman utama
      home: const HomeView(), 
    );
  }
}