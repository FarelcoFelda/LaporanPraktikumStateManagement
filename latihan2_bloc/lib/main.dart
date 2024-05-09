import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

class University {
  String name;
  String website;

  University({required this.name, required this.website});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

// Event untuk mengubah negara yang dipilih.
class CountryChanged {
  final String country;

  CountryChanged(this.country);
}

// Bloc untuk mengelola negara yang dipilih.
class CountryBloc extends Bloc<CountryChanged, String> {
  CountryBloc()
      : super("Indonesia"); // Negara awal yang dipilih adalah Indonesia.

  @override
  Stream<String> mapEventToState(CountryChanged event) async* {
    yield event.country;
  }

  @override
  void onChange(Change<String> change) {
    // Override method onChange untuk menghindari pembandingan menggunakan Equatable.
    print(change.nextState);
    super.onChange(change);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities App',
      home: BlocProvider(
        create: (context) => CountryBloc(),
        child: UniversityList(),
      ),
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas di ASEAN'),
      ),
      body: Column(
        children: [
          // Combo box untuk memilih negara ASEAN.
          BlocBuilder<CountryBloc, String>(
            builder: (context, state) {
              return DropdownButton<String>(
                value: state,
                onChanged: (String? newValue) {
                  BlocProvider.of<CountryBloc>(context).add(CountryChanged(
                      newValue!)); // Memperbarui negara yang dipilih saat pengguna memilih dari combo box.
                },
                items: aseanCountries
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
          Expanded(
            child: UniversityListView(),
          ),
        ],
      ),
    );
  }
}

class UniversityListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryBloc, String>(
      builder: (context, country) {
        return FutureBuilder<List<University>>(
          future: fetchData(country),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(snapshot.data![index].website),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
            return Center(
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
  final url = "http://universities.hipolabs.com/search?country=$country";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    List<University> universities = [];

    for (var item in data) {
      universities.add(University.fromJson(item));
    }

    return universities;
  } else {
    throw Exception('Failed to load');
  }
}
