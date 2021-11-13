import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

abstract class BoxConst {
  static const String USER_LAT = "user_lat";
  static const String USER_LONG = "user_long";
}

class MainController {
  
  // Location
  final polygons = <Polygon>{};
  final polygon1 = [ [ -99.1638816, 19.4638269 ], [ -99.1793311, 19.4230352 ], [ -99.1721213, 19.4524969 ], [ -99.2002738, 19.4557341 ], [ -99.2198432, 19.4369573 ], [ -99.2414725, 19.4100834 ], [ -99.2438758, 19.3916252 ], [ -99.2301429, 19.3741365 ], [ -99.21641, 19.3592373 ], [ -99.1958106, 19.3864435 ], [ -99.1927207, 19.3663632 ], [ -99.2119468, 19.3530829 ], [ -99.2043937, 19.3446606 ], [ -99.193064, 19.3326744 ], [ -99.1889441, 19.3090234 ], [ -99.1539252, 19.2983307 ], [ -99.139849, 19.3099954 ], [ -99.0880072, 19.3216593 ], [ -99.095217, 19.3466043 ], [ -99.0608847, 19.3585895 ], [ -99.0608847, 19.3900059 ], [ -99.0567649, 19.4084643 ], [ -99.0519584, 19.4330722 ], [ -99.0231192, 19.4887501 ], [ -99.0135062, 19.5418204 ], [ -99.0238059, 19.570937 ], [ -99.0588248, 19.5482912 ], [ -99.0794242, 19.5521736 ], [ -99.0993369, 19.4816295 ], [ -99.1089499, 19.4842189 ], [ -99.1055167, 19.4991066 ], [ -99.1027701, 19.5230536 ], [ -99.1206229, 19.539232 ], [ -99.1412223, 19.5379378 ], [ -99.1968406, 19.5508795 ], [ -99.2373526, 19.513993 ], [ -99.2421592, 19.4602661 ], [ -99.2112601, 19.4874554 ], [ -99.1851676, 19.4783928 ], [ -99.1638816, 19.4638269 ] ];
  final polygon2 = [ [ -99.1828104, 19.3959295 ], [ -99.1793771, 19.365162 ], [ -99.1584345, 19.3509098 ], [ -99.1282221, 19.3535012 ], [ -99.1110559, 19.3810323 ], [ -99.096293, 19.3981964 ], [ -99.1347452, 19.394958 ], [ -99.1368051, 19.4033776 ], [ -99.1254755, 19.4033776 ], [ -99.1244455, 19.4111492 ], [ -99.1086527, 19.4079111 ], [ -99.098353, 19.4075873 ], [ -99.0980097, 19.4169776 ], [ -99.0942331, 19.4208631 ], [ -99.1100259, 19.4276625 ], [ -99.1306253, 19.4292814 ], [ -99.1340585, 19.4079111 ], [ -99.1447015, 19.4056444 ], [ -99.1429849, 19.3884811 ], [ -99.1285654, 19.3810323 ], [ -99.1405817, 19.3739071 ], [ -99.1567178, 19.3800607 ], [ -99.1567178, 19.4069396 ], [ -99.152598, 19.4208631 ], [ -99.161181, 19.4231296 ], [ -99.1814371, 19.4134158 ], [ -99.1828104, 19.3959295 ] ];
  
  // Config
  final box = GetStorage();
  LatLng? userLocation;
  bool moveLocation = false;

  LatLng? getUserLocationFromBox(){
    var lat = box.read<double>(BoxConst.USER_LAT);
    var long = box.read<double>(BoxConst.USER_LONG);
    if (lat != null && long != null) {
      return LatLng(lat, long);
    }
  }

  void writeUserLocationToBox(LatLng position){
    box.write(BoxConst.USER_LAT, position.latitude);
    box.write(BoxConst.USER_LONG, position.longitude);
  }

  List<LatLng> getPoints(List<List<double>> polygon) {
    var result = <LatLng>[];
    
    for (var point in polygon) {
      result.add(LatLng(point[1], point[0]));
    }
    
    return result;
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (final LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) {
          x1 = latLng.latitude;
        }
        if (latLng.latitude < x0) {
          x0 = latLng.latitude;
        }
        if (latLng.longitude > y1!) {
          y1 = latLng.longitude;
        }
        if (latLng.longitude < y0!) {
          y0 = latLng.longitude;
        }
      }
    }
    // return LatLngBounds(LatLng(x1, y1), LatLng(x0, y0));
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  String whereIsTheUser(){
  
    if(userLocation == null) {
      return "Por favor proporciona tu ubicación";
    }

    if(inside([userLocation!.latitude, userLocation!.longitude], polygon2)) {
      return "Área 2";
    }

    if(inside([userLocation!.latitude, userLocation!.longitude], polygon1)) {
      return "Área 1";
    }

    else {
      return "fuera de zona";
    }

  }

  bool inside(List<double> point, List<List<double>> polygon) {

    var mpPoint = mp.LatLng(point[0], point[1]);
    var mpPolygon = <mp.LatLng>[];

    for (var item in polygon) {
      mpPolygon.add(mp.LatLng(item[1], item[0]));
    }

    return mp.PolygonUtil.containsLocation(mpPoint, mpPolygon, false);
  }

    /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Ubicación desabilitada, por favor habilite la ubicación para continuar');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Nos has negado el permiso a la ubicación de forma permanente, no podemos acceder a ella.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Permisos denegados, por favor acepta el permiso para acceder a tu ubicación');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

}