// Import Flutter material library for UI components.
import 'package:flutter/material.dart';

// Import HTTP library for making network requests.
import 'package:http/http.dart' as http;

// Import dart:convert for JSON decoding.
import 'dart:convert';

// Import Provider package for state management.
import 'package:provider/provider.dart';

// Define a class for University with name and website attributes.
class University {
  String name;
  String website;

  University({required this.name, required this.website});

  // Factory method to create University object from JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

void main() {
  runApp(
    // Wrap the root widget with ChangeNotifierProvider for state management.
    ChangeNotifierProvider(
      create: (context) => SelectedCountryProvider(),
      child: MyApp(),
    ),
  );
}

// Define a provider class for selected country.
class SelectedCountryProvider extends ChangeNotifier {
  String _selectedCountry = "Indonesia"; // Default selected country.

  // Getter for selected country.
  String get selectedCountry => _selectedCountry;

  // Method to update selected country.
  void selectCountry(String country) {
    _selectedCountry = country;
    notifyListeners(); // Notify listeners when country changes.
  }
}

// Define the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Universitas di ASEAN'), // App bar title.
        ),
        body: Column(
          children: [
            // Combo box for selecting ASEAN country.
            Consumer<SelectedCountryProvider>(
              builder: (context, selectedCountryProvider, child) {
                return DropdownButton<String>(
                  value: selectedCountryProvider.selectedCountry,
                  onChanged: (String? newValue) {
                    selectedCountryProvider.selectCountry(
                        newValue!); // Update selected country when user selects from combo box.
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
              child: UniversityListView(), // Display list of universities.
            ),
          ],
        ),
      ),
    );
  }
}

// Define a widget to display list of universities.
class UniversityListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedCountryProvider>(
      builder: (context, selectedCountryProvider, child) {
        return FutureBuilder<List<University>>(
          future: fetchData(selectedCountryProvider.selectedCountry),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].name), // University name.
                    subtitle: Text(
                        snapshot.data![index].website), // University website.
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                    '${snapshot.error}'), // Display error if fetching data fails.
              );
            }
            return Center(
              child:
                  CircularProgressIndicator(), // Display loading indicator while fetching data.
            );
          },
        );
      },
    );
  }
}

// List of ASEAN countries.
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

// Method to fetch university data from API based on selected country.
Future<List<University>> fetchData(String country) async {
  final url =
      "http://universities.hipolabs.com/search?country=$country"; // API URL with country parameter.
  final response = await http.get(Uri.parse(url)); // Make HTTP GET request.

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body); // Decode JSON response.
    List<University> universities = [];

    for (var item in data) {
      universities.add(University.fromJson(
          item)); // Create University objects from JSON data.
    }

    return universities; // Return list of universities.
  } else {
    throw Exception('Failed to load'); // Throw error if fetching data fails.
  }
}
