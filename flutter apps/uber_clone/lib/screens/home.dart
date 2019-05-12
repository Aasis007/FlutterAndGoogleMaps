import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../requests/googlemaps_requests.dart';

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
  GoogleMapsServices googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  static LatLng _initialposition;
  LatLng lastposition = _initialposition;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return _initialposition == null
        ? Container(
      alignment: Alignment.center,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    )
        : Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition:
          CameraPosition(target: LatLng(12.97, 77.58), zoom: 10.0),
          onMapCreated: onCreated,
          myLocationEnabled: true,
          compassEnabled: true,
          markers: markers,
          onCameraMove: OnCameraMove,
          polylines: polylines,
        ),
        Positioned(
          top: 50.0,
          right: 12.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.blueGrey,
                    offset: Offset(1.0, 5.0),
                    blurRadius: 10,
                    spreadRadius: 3)
              ],
            ),
            child: TextField(
              cursorColor: Colors.blue,
              controller: locationController,
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 10, top: 5),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue,
                  ),
                ),
                hintText: "From",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
              ),
            ),
          ),
        ),
        Positioned(
          top: 105.0,
          right: 12.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 5.0),
                    blurRadius: 10,
                    spreadRadius: 3)
              ],
            ),
            child: TextField(
              cursorColor: Colors.blue,
              controller: destinationController,
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                sendRequest(value);
              },

              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 10, top: 5),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.local_taxi,
                    color: Colors.blue,
                  ),
                ),
                hintText: "To?",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
              ),
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

  void onAddMarkerPressed(LatLng location, String adress) {
    setState(() {
      markers.add(Marker(
          markerId: MarkerId(lastposition.toString()),
          position: location,
          infoWindow: InfoWindow(title: "Address", snippet: "Go"),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  void createRoute(String encodedPoly){
    setState(() {
      polylines.add(Polyline(polylineId: PolylineId(lastposition.toString()),
      width: 20,
      points: convertToLatLng(decodePoly(encodedPoly)),
      color: Colors.black)
      );
    });
  }


  //  this method will convert list of doubles into latlng
  List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++)
      lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  void getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialposition = LatLng(position.latitude, position.longitude);
      locationController.text = placemark[0].name;
    });
  }

  void sendRequest(String intendedLocation) async{
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    onAddMarkerPressed(destination, intendedLocation);
    String route = await googleMapsServices.getRouteCoordinates(_initialposition, destination);
    createRoute(route);
  }
}