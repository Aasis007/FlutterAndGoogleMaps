import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const apikey="AIzaSyAr-KMCALpkv8FkoMIKFZ3mTGR-ITcw6CA";

class GoogleMapsServices{
Future<String> getRouteCoordinates(LatLng Location1, LatLng Location2) async{

  String url="https://maps.googleapis.com/maps/api/directions/json?origin=${Location1.latitude},${Location1.longitude}&destination=${Location2.latitude},${Location2.longitude}&key=$apikey";
  http.Response response = await http.get(url);
  Map values = jsonDecode(response.body);
  return values["routes"][0]["overview_polyline"]["points"];
}
}