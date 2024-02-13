import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pothole_detection_system/home_methods/suggestions.dart';
import 'package:pothole_detection_system/main.dart';
import 'package:google_maps_webservice/places.dart' as placesLib;
import 'package:geocoding/geocoding.dart' as geocodingLib;

class Suggestion {
  final String address;
  Suggestion(this.address);
}

Future<List<String>> fetchAddressSuggestions(String query) async {
  // Replace with your actual API call to fetch address suggestions
  // For example:
  // return await yourApi.fetchAddressSuggestions(query);
  final places = placesLib.GoogleMapsPlaces(apiKey: google_map_API);
  final response = await places.autocomplete(query);
  return response.predictions?.map((prediction) => prediction.description ?? '').toList() ?? [];
}

class AddressSearch extends SearchDelegate<Suggestion> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () async {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Scaffold();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      // Replace 'null' with your actual API call to fetch suggestions.
      future: fetchAddressSuggestions(query),
      builder: (context, snapshot) {
        if (query.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Text('Enter your address'),
          );
        } else if (snapshot.hasData) {
          final suggestions = snapshot.data!;
          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text(suggestions[index]),
              onTap: () async {
                List<geocodingLib.Location> locations = await geocodingLib.locationFromAddress(suggestions[index]);
                geocodingLib.Location location = locations.first;

                destination = suggestions[index];
                destinationController.text = destination!;

                destinationPosition = Position(latitude: location.latitude, longitude: location.longitude, timestamp: null, accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0, );

                close(context, Suggestion(suggestions[index]));
              },
            ),
            itemCount: suggestions.length,
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
