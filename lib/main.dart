import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:prixz/main_controller.dart';



Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapSample(),
    );
  }
}


class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  
  final _mainController = MainController();

  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_){
      _init();
    });    
  }

  void _init(){
    var location = _mainController.getUserLocationFromBox();
    if (location == null) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.info,
        title: "Necesitamos  acceder a tu ubicación",
        text: "Para brindarte nuestro servicio, es necesario acceder a tu ubicación",
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          await _getLocation();
          _mainController.writeUserLocationToBox(_mainController.userLocation!);
          CoolAlert.show(
            context: context, 
            type: CoolAlertType.info,
            title: "Ajusta tu ubicación",
            text: "Para ajustar tu ubicación, presiona el icono correspondiente a ella y arrastra el mapa a la ubicacion deseada, cuando hayas finalizado vuelve a presionar el icono"
          );
        },
      );
    } else {
      setState(() {
        _setUserLocation(location);
      });
    }
  }

  Future<void> _setUserLocation(LatLng position) async {
      setState(() {
        _mainController.userLocation = position;
      });
      var _googleMapController = await _controller.future;
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17
          )
        )
      );
  }

  Future<void> _parseAndDrawAssetsOnMap() async {
    setState(() {
      _mainController.polygons.add(Polygon(
        polygonId: const PolygonId("Area1"), points: _mainController.getPoints(_mainController.polygon1), fillColor: Colors.black.withAlpha(75), strokeWidth: 3)
      );

      _mainController.polygons.add(
        Polygon(polygonId: const PolygonId("Area2"), points: _mainController.getPoints(_mainController.polygon2), fillColor: Colors.black.withAlpha(75), strokeWidth: 3)
      );
    });
  }

  Future<void> _getLocation() async {
    try {
      final position = await _mainController.determinePosition();
      _setUserLocation(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_mainController.whereIsTheUser()),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: LatLng(19.350771, -99.139403),
          zoom: 14.4746,
        ),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
          await _parseAndDrawAssetsOnMap();
        },
        polygons: _mainController.polygons,
        markers: 
          <Marker>{
            if (_mainController.userLocation != null && !_mainController.moveLocation)
            Marker(
              draggable: false,
              markerId: const MarkerId("1"),
              position: _mainController.userLocation!,
              // icon: pinLocationIcon!,
              infoWindow:  InfoWindow(
                title: 'Presiona aqui para ajustar tu ubicacion',
                onTap: () {
                  setState(() {
                    _mainController.moveLocation = !_mainController.moveLocation;
                  });
                }
              ),
            ),
            if (_mainController.userLocation != null && _mainController.moveLocation)
            Marker(
              draggable: false,
              markerId: const MarkerId("2"),
              position: _mainController.userLocation!,
              // icon: pinLocationIcon!,
              infoWindow:  InfoWindow(
                title: 'Presiona aqui para finalizar',
                onTap: () {
                  setState(() {
                    _mainController.moveLocation = !_mainController.moveLocation;
                  });
                  _mainController.writeUserLocationToBox(_mainController.userLocation!);
                }
              ),
            )
          },
          onCameraMove: (_position) {
            if(_mainController.moveLocation) {
              setState(() {
                _mainController.userLocation = LatLng(_position.target.latitude, _position.target.longitude);
              });
            }
          }, 
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _getLocation();
        },
        label: const Text('Mi ubicación'),
        icon: const Icon(Icons.location_on),
      ),
      
    );
  }

}