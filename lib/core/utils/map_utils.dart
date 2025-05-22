import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapUtils {
  /// Create a custom marker icon from an asset image
  static Future<BitmapDescriptor> createMarkerIconFromAsset(
    String assetPath, {
    int width = 80,
    int height = 80,
  }) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  /// Create a custom marker icon from a widget
  static Future<BitmapDescriptor> createMarkerIconFromWidget(
    BuildContext context,
    Widget widget, {
    Size size = const Size(80, 80),
  }) async {
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();

    final RenderView renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      configuration: ViewConfiguration(
        // size: size,
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      ),
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: boundary,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    renderView.prepareInitialFrame();
    pipelineOwner.rootNode = renderView;

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: widget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await boundary.toImage(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List uint8list = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(uint8list);
  }

  /// Get camera bounds that include all provided positions
  static LatLngBounds getBoundsForPoints(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
      minLat = (minLat == null) ? point.latitude : (point.latitude < minLat ? point.latitude : minLat);
      maxLat = (maxLat == null) ? point.latitude : (point.latitude > maxLat ? point.latitude : maxLat);
      minLng = (minLng == null) ? point.longitude : (point.longitude < minLng ? point.longitude : minLng);
      maxLng = (maxLng == null) ? point.longitude : (point.longitude > maxLng ? point.longitude : maxLng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  /// Get camera update to fit all provided points with padding
  static CameraUpdate getCameraUpdateForPoints(
    List<LatLng> points, {
    double padding = 50.0,
  }) {
    if (points.isEmpty) {
      return CameraUpdate.newCameraPosition(
        const CameraPosition(target: LatLng(0, 0), zoom: 10),
      );
    }

    if (points.length == 1) {
      return CameraUpdate.newCameraPosition(
        CameraPosition(target: points.first, zoom: 15),
      );
    }

    return CameraUpdate.newLatLngBounds(getBoundsForPoints(points), padding);
  }
}
