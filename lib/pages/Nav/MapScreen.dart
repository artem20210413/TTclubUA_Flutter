import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../components/CustomAppBar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;

  final LatLng _initialPosition = const LatLng(50.4501, 30.5234); // Киев

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        'Map',
        automaticallyImplyLeading: true,
      ),
      // body: Column( children: [Text(dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'].toString())],)
      body: Column( children: [Text('dfdad')],)
    );
  }
}
//GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 12,
//         ),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//       ),