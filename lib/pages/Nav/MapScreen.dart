import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../components/CustomAppBar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  static const LatLng _kyiv = LatLng(50.4501, 30.5234);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Map', automaticallyImplyLeading: true),
      body: Stack(
        children: [
          //dotenv.env['YOUR_GOOGLE_MAPS_API_KEY'] ?? ''
          // GoogleMap(
          //   initialCameraPosition: CameraPosition(
          //     target: _kyiv,
          //     zoom: 12,
          //   ),
          //   myLocationEnabled: false,
          //   // оставляем false, чтобы не ловить исключение без разрешения
          //   myLocationButtonEnabled: false,
          //   zoomControlsEnabled: false,
          //   compassEnabled: false,
          // ),
        ],
      ),
    );
  }
}
