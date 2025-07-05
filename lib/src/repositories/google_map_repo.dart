import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mdsoft_google_map_user_pick_location_from_scroll/src/api/failure.dart';
import 'package:mdsoft_google_map_user_pick_location_from_scroll/src/models/geometry/geometry.dart';
import 'package:mdsoft_google_map_user_pick_location_from_scroll/src/models/place_details_model/place_details_model.dart';
import 'package:mdsoft_google_map_user_pick_location_from_scroll/src/models/places_model/places_model.dart';

abstract class GoogleMapRepo {
  Future<Either<Failure, PlacesModel>> getPredictions({
    required String input,
    required String sessionToken,
  });
  Future<Either<Failure, PlaceDetailsModel>> getPlaceDetails({
    required String placeId,
  });
  Future<Either<Failure, RegionModel>> getGovernorate({
    required LatLng currentLocation,
  });
}
