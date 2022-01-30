import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:mis_lab3/constants/constants.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:uuid/uuid.dart';

class AddLocationEvent extends StatefulWidget {

  Function notify;

  AddLocationEvent({required this.notify});

  @override
  _AddLocationEventState createState() => _AddLocationEventState();
}

final _places = GoogleMapsPlaces(apiKey: kApiKey);
final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User? loggedInUser;

class _AddLocationEventState extends State<AddLocationEvent> {

  String? _location = "";
  double? _latitude = 0.0;
  double? _longitude = 0.0;
  String _reminder = "_______";
  final reminderController = TextEditingController();


  void _onGeofence(bg.GeofenceEvent event) {
    print('onGeofence $event');
    widget.notify(_reminder, _location);
  }

  @override
  void initState() {
    super.initState();

    _auth.userChanges()
        .listen((User? user) {
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    });
      // add geofence if coordinates are set
    if (_latitude != null && _longitude != null) {
      _addGeofence();
    }
    // set background geolocation events
    bg.BackgroundGeolocation.onGeofence(_onGeofence);

    // Configure the plugin and call ready
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false, // true
        logLevel: bg.Config.LOG_LEVEL_OFF // bg.Config.LOG_LEVEL_VERBOSE
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.startGeofences();
      }
    });
  }

  void _addGeofence() {
    bg.BackgroundGeolocation.addGeofence(bg.Geofence(
      identifier: 'Location',
      radius: 150,
      latitude: _latitude!,
      longitude: _longitude!,
      notifyOnEntry: true, // only notify on entry
      notifyOnExit: false,
      notifyOnDwell: false,
      loiteringDelay: 30000, // 30 seconds
    )).then((bool success) {
      print('[addGeofence] success with $_latitude and $_longitude');
    }).catchError((error) {
      print('[addGeofence] FAILURE: $error');
    });
  }

  void _addEntryToDb (){
    _firestore.collection('locationEvents').add(
        {'userId': loggedInUser!.uid,
          'address': _location,
          'lat': _latitude,
          'lng': _longitude,
          'reminder': _reminder
        }
    ).then((value) => print("Location Event Added"))
        .catchError((error) => print("Failed to add location event: $error"));
  }

  Future<void> displayPrediction(Prediction? p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId!);
      // var address = await Geocoder.local.findAddressesFromQuery(p.description);

      // update the state and update the values in shared preferences for persistence
      setState(() {
        _location = p.description;
        _latitude = detail.result.geometry?.location.lat;
        _longitude = detail.result.geometry?.location.lng;
        _reminder = reminderController.text;
        reminderController.clear();
      });

      _addEntryToDb();

      // update the geofence
      _addGeofence();
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
    print(response.predictions);
    print(response.status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MIS Lab 5"),
      ),
      body: Center(
        // position the column of widgets in the center
        child: Column(
          // vertically align widets
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Container(
              child: Center(child: Text("Прво внесете ја причината за која сакате да бидете потсетени, потоа притиснете на копчето + доле десно за да внесете локација, со притискање на самата локација, ќе биде запишан потсетник. Кога ќе пристигнете на дадената локација, ќе бидете потсетени за она што сте го напишале.")),
            ),
            SizedBox(height: 10),
            Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              child: TextField(
                controller: reminderController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Потсетник',
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Потсетник за $_reminder на:',
            ),
            SizedBox(height: 10),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                child: Text(
                  '$_location',
                  textAlign: TextAlign.center,
                )),
            SizedBox(height: 10),
            Text(
              '$_latitude, $_longitude',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // pop up google address search widget and call display prediction after user makes selection

          Prediction? p = await PlacesAutocomplete.show(
              offset: 1,
              radius: 1000,
              strictbounds: false,
              // region: 'us',
              sessionToken: '01346D-7A452A-108DE4',
              context: context,
              apiKey: kApiKey,
              onError: onError,
              language: 'en'
              components: [Component(Component.country, 'mk')]
              types: ["address"],
              hint: "Search City",
              mode: Mode.overlay);
          await displayPrediction(p); // call to update user selection values
        },
        tooltip: 'Set Home Location',
        child: Icon(Icons.add),
      ),
    );
  }
}


