import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocationProvider extends ChangeNotifier {
  LatLng? location;

  get getCurrentLocation => location;

  setLocation(LatLng location) {
    this.location = location;
    notifyListeners();
  }
}
