// Mengimpor pustaka Flutter untuk pengembangan UI.
import 'package:flutter/material.dart';

// Mengimpor pustaka http untuk melakukan permintaan HTTP.
import 'package:http/http.dart' as http;

// Mengimpor pustaka dart:convert untuk mengonversi data.
import 'dart:convert';

// Mengimpor pustaka flutter_bloc untuk mengimplementasikan manajemen state dengan BLoC.
import 'package:flutter_bloc/flutter_bloc.dart';

// Model untuk merepresentasikan data universitas.
class University {
  String name; // Nama universitas.
  String website; // Situs web universitas.

  University(
      {required this.name,
      required this.website}); // Konstruktor dengan parameter wajib.

  // Metode factory untuk membuat objek University dari JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Mengambil nilai 'name' dari JSON.
      website: json['web_pages'][0], // Mengambil nilai 'web_pages' dari JSON.
    );
  }
}

// Cubit untuk mengelola negara yang dipilih.
class CountryCubit extends Cubit<String> {
  CountryCubit()
      : super("Indonesia"); // Negara awal yang dipilih adalah Indonesia.

  // Metode untuk memperbarui negara yang dipilih.
  void selectCountry(String country) {
    emit(country); // Mengirimkan negara yang dipilih sebagai state baru.
  }
}

// Fungsi utama untuk menjalankan aplikasi Flutter.
void main() {
  runApp(MyApp());
}

// Kelas MyApp yang merupakan root dari aplikasi.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities App', // Judul aplikasi.
      home: BlocProvider(
        // Memberikan BlocProvider untuk menyediakan Bloc kepada widget turunannya.
        create: (context) =>
            CountryCubit(), // Membuat instance dari CountryCubit.
        child:
            UniversityList(), // Menampilkan UniversityList sebagai halaman utama.
      ),
    );
  }
}

// Kelas UniversityList yang menampilkan daftar universitas.
class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final countryCubit = BlocProvider.of<CountryCubit>(
        context); // Mendapatkan instance dari CountryCubit.
    return Scaffold(
      // Membuat tata letak dasar aplikasi.
      appBar: AppBar(
        // Menampilkan bilah aplikasi di bagian atas.
        title: Text('Daftar Universitas di ASEAN'), // Judul bilah aplikasi.
      ),
      body: Column(
        // Membuat tata letak kolom untuk menempatkan widget secara vertikal.
        children: [
          // Combo box untuk memilih negara ASEAN.
          BlocBuilder<CountryCubit, String>(
            // Membangun widget yang bergantung pada state dari CountryCubit.
            builder: (context, state) {
              // Membangun widget berdasarkan state dari CountryCubit.
              return DropdownButton<String>(
                // Membuat dropdown button untuk memilih negara ASEAN.
                value: state, // Nilai saat ini yang dipilih dalam dropdown.
                onChanged: (String? newValue) {
                  // Aksi yang dipicu ketika nilai dropdown berubah.
                  countryCubit.selectCountry(
                      newValue!); // Memperbarui negara yang dipilih saat pengguna memilih dari combo box.
                },
                items: aseanCountries // Daftar negara ASEAN.
                    .map<DropdownMenuItem<String>>((String value) {
                  // Mengonversi daftar negara menjadi widget DropdownMenuItem.
                  return DropdownMenuItem<String>(
                    value: value,
                    child:
                        Text(value), // Menampilkan teks negara pada dropdown.
                  );
                }).toList(),
              );
            },
          ),
          Expanded(
            // Widget Expanded untuk menyesuaikan bagian tubuh dengan ruang yang tersedia.
            child:
                UniversityListView(), // Menampilkan UniversityListView untuk menampilkan daftar universitas.
          ),
        ],
      ),
    );
  }
}

// Kelas UniversityListView yang menampilkan daftar universitas berdasarkan negara yang dipilih.
class UniversityListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryCubit, String>(
      // Membangun widget yang bergantung pada state dari CountryCubit.
      builder: (context, country) {
        // Membangun widget berdasarkan state dari CountryCubit.
        return FutureBuilder<List<University>>(
          // Membangun widget berdasarkan hasil future.
          future: fetchData(
              country), // Future untuk mengambil data universitas berdasarkan negara yang dipilih.
          builder: (context, snapshot) {
            // Membangun widget berdasarkan snapshot.
            if (snapshot.hasData) {
              // Jika data berhasil diambil.
              return ListView.builder(
                // Menampilkan daftar universitas.
                itemCount: snapshot.data!.length, // Jumlah item dalam daftar.
                itemBuilder: (context, index) {
                  // Membangun item daftar berdasarkan indeks.
                  return ListTile(
                    // Menampilkan informasi universitas sebagai ListTile.
                    title: Text(snapshot
                        .data![index].name), // Menampilkan nama universitas.
                    subtitle: Text(snapshot.data![index]
                        .website), // Menampilkan situs web universitas.
                  );
                },
              );
            } else if (snapshot.hasError) {
              // Jika terjadi kesalahan dalam mengambil data.
              return Center(
                // Menampilkan pesan kesalahan.
                child: Text('${snapshot.error}'),
              );
            }
            return Center(
              // Menampilkan indikator loading jika data sedang dimuat.
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }
}

// List negara ASEAN.
List<String> aseanCountries = [
  "Indonesia",
  "Malaysia",
  "Singapore",
  "Thailand",
  "Vietnam",
  "Philippines",
  "Myanmar",
  "Cambodia",
  "Laos",
  "Brunei"
];

// Method untuk mengambil data dari API berdasarkan negara yang dipilih.
Future<List<University>> fetchData(String country) async {
  final url =
      "http://universities.hipolabs.com/search?country=$country"; // URL endpoint API untuk mengambil data universitas.
  final response =
      await http.get(Uri.parse(url)); // Melakukan permintaan HTTP GET ke URL.

  if (response.statusCode == 200) {
    // Jika permintaan berhasil (status code 200).
    List<dynamic> data =
        jsonDecode(response.body); // Mendekode data JSON yang diterima.
    List<University> universities = []; // Daftar universitas.

    for (var item in data) {
      // Meloop melalui setiap item data.
      universities.add(University.fromJson(
          item)); // Menambahkan universitas ke dalam daftar berdasarkan data JSON.
    }

    return universities; // Mengembalikan daftar universitas.
  } else {
    // Jika terjadi kesalahan dalam permintaan.
    throw Exception(
        'Failed to load'); // Melemparkan exception dengan pesan kesalahan.
  }
}
