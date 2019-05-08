import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Map());
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;
  static const _initialposition = LatLng(12.97, 77.50);
  LatLng lastposition = _initialposition;
  final Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(12.97, 77.58), zoom: 10.0),
          onMapCreated: onCreated,
          myLocationEnabled: true,
          compassEnabled: true,
          markers: markers,
          onCameraMove: OnCameraMove,
        ),
        Positioned(
          bottom: 60,
          right: 10,
          child: FloatingActionButton(
            onPressed: onAddMarkerPressed,
            tooltip: "add Marker",
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.add_location,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void OnCameraMove(CameraPosition position) {
    setState(() {
      lastposition = position.target;
    });
  }

  void onAddMarkerPressed() {
    setState(() {
      markers.add(Marker(
          markerId: MarkerId(lastposition.toString()),
          position: lastposition,
          infoWindow: InfoWindow(title: "New Marker", snippet: "Clicked"),
          icon: BitmapDescriptor.defaultMarker));
    });
  }
}
