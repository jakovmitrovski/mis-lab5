import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mis_lab3/constants/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  var events = [];
  late Position _currentPosition;

  late GoogleMapController mapController;

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  final LatLng _center = const LatLng(41.98374140000001, 21.4369859);
  late String _destinationAddress;



  late double _destinationLatitude;
  late double _destinationLongitude;

  late PolylinePoints polylinePoints;

  List<LatLng> polylineCoordinates = [];

  Map<PolylineId, Polyline> polylines = {};

  String _selectedEventName = "";
  bool showPathForm = false;

  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {

    polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      kApiKey,
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      print ("The address is ${place.name}");

    } catch (e) {
      print(e);
    }
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> getMarkers() {
    Set<Marker> markers = {};
    for (final event in events) {
      final marker = Marker(
        markerId: MarkerId(event["reminder"]),
        position: LatLng(event["lat"], event["lng"]),
        infoWindow: InfoWindow(
          title: event["reminder"],
          snippet: event["address"],
        ),
        onTap: () {
          setState(() {
            _destinationLatitude = event["lat"];
            _destinationLongitude = event["lng"];
            _destinationAddress = event["address"];
            polylines.clear();
            polylineCoordinates.clear();
            if (event["reminder"] == _selectedEventName) {
              showPathForm = !showPathForm;
            }else {
              showPathForm = true;
            }
            _selectedEventName = event["reminder"];
          });
          print(event);
        }
      );

      markers.add(marker);
    }
    return markers;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    events = ModalRoute.of(context)!.settings.arguments
        as List<Map<String, dynamic>>;

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: getMarkers(),
              polylines: Set<Polyline>.of(polylines.values)
            ),
            if (showPathForm) SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Прикажи најкратка патека до $_destinationAddress',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                                if (polylines.isNotEmpty) {
                                  polylines.clear();
                                }
                                if (polylineCoordinates.isNotEmpty) {
                                  polylineCoordinates.clear();
                                }
                                _createPolylines(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                  _destinationLatitude,
                                  _destinationLongitude,
                                );
                                setState(() {
                                  showPathForm = false;
                                });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Прикажи Патека'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ),
    ),
    );
  }
}
