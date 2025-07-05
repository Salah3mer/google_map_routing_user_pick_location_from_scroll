import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../src/models/md_on_user_selcted_place.dart';
import '../src/cubit/google_map_cubit.dart';
import '../src/utils/app_images.dart';
import '../src/utils/constants.dart';
import '../src/services/toastification_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../src/widgets/custom_button.dart';
import '../src/widgets/custom_textformfield.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
export '../src/cubit/google_map_cubit.dart';
export '../src/repositories/google_map_repo_impl.dart';
export '../src/services/location_service.dart';
export '../src/utils/constants.dart';
export '../src/utils/app_images.dart';

class MdSoftGoogleMapUserPickLocationFromScroll extends StatelessWidget {
  final Widget? floatingActionButtonIcon;
  final String? mapStyle;
  final bool isUser;
  final LatLng? startLocation;
  final bool internal;
  final void Function(MdOnUserSelectedPlace) selectedPlace;

  const MdSoftGoogleMapUserPickLocationFromScroll({
    super.key,
    this.startLocation,
    this.floatingActionButtonIcon,
    this.mapStyle,
    this.isUser = false,
    required this.internal,
    required this.selectedPlace,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;

    return BlocProvider(
      create: (context) => GoogleMapCubit(),
      child: BlocConsumer<GoogleMapCubit, GoogleMapState>(
        listener: (context, state) {
          if (state is GetLocationErrorState) {
            showToastificationWidget(
              message: state.errorMessage,
              context: context,
            );
          }
          if (state is GetPlaceDetailsErrorState) {
            showToastificationWidget(
              message: state.errorMessage,
              context: context,
            );
          }
          if (state is GetGovernoratesErrorState) {
            showToastificationWidget(
              message: state.errorMessage,
              context: context,
            );
          }
        },
        builder: (context, state) {
          var cubit = context.read<GoogleMapCubit>();
          var bottomPadding = MediaQuery.viewInsetsOf(context).bottom > 0
              ? MediaQuery.viewInsetsOf(context).bottom
              : 16.0;
          return ModalProgressHUD(
            inAsyncCall: cubit.mapState == MapState.loading,
            color: Colors.white,
            opacity: 0.5,
            progressIndicator: Center(
                child: CircularProgressIndicator(
              color: MdUserPickLocationGoogleMapConfig.primaryColor,
            )),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: Stack(
                  children: [
                    GoogleMapWidget(
                      internal: internal,
                      startLocation: startLocation,
                      isUser: isUser,
                      cubit: cubit,
                      mapStyle: mapStyle,
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.only(start: 9, top: 16),
                      child: SearchTextFormFeild(
                        width: width,
                        internal: internal,
                        cubit: cubit,
                      ),
                    ),
                    Center(
                      child: Image.asset(AppImages.point),
                    ),
                    Positioned.fill(
                      top: 80,
                      right: 16,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: width / 1.2,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.9),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: PlacesListWidget(
                            internal: internal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Padding(
                padding:
                    EdgeInsets.only(bottom: bottomPadding, right: 16, left: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserFloatingActionButton(
                        bottomPadding: bottomPadding, cubit: cubit),
                    const SizedBox(height: 10),
                    CustomButton(
                        onTap: () async {
                          if (internal) {
                            bool inSide = cubit
                                .chackInternalOrNot(cubit.selectedLocation!);
                            if (inSide) {
                              selectedPlace.call(MdOnUserSelectedPlace(
                                selectedLocation: cubit.selectedLocation!,
                                pointName: cubit.locationName!,
                              ));
                            } else {
                              showToastificationWidget(
                                message: 'المكان خارج الحدود المسموح بها',
                                context: context,
                              );
                            }
                          } else {
                            selectedPlace.call(MdOnUserSelectedPlace(
                              selectedLocation: cubit.selectedLocation!,
                              pointName: cubit.locationName!,
                            ));
                          }
                        },
                        text: 'تثبيت النقطة'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserFloatingActionButton extends StatelessWidget {
  const UserFloatingActionButton({
    super.key,
    required this.bottomPadding,
    required this.cubit,
  });
  final double bottomPadding;
  final GoogleMapCubit cubit;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        side: BorderSide(color: Colors.transparent),
      ),
      elevation: 1,
      backgroundColor: Colors.white,
      onPressed: () {
        cubit.googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: cubit.currentLocation,
            zoom: 16,
          ),
        ));
        cubit.updateCurrentLocationMarker();
      },
      child: SizedBox(
        height: 46,
        width: 46,
        child: Icon(
          Icons.location_searching,
          weight: 24,
          color: MdUserPickLocationGoogleMapConfig.primaryColor,
        ),
      ),
    );
  }
}

class SearchTextFormFeild extends StatelessWidget {
  const SearchTextFormFeild({
    super.key,
    required this.width,
    required this.cubit,
    this.internal = false,
    this.index = 0,
  });

  final double width;
  final bool internal;
  final GoogleMapCubit cubit;
  final int index;

  @override
  Widget build(BuildContext context) {
    Timer? debounce;

    void Function(String?)? onSearchChanged(String? query) {
      if (debounce?.isActive ?? false) debounce?.cancel();
      debounce = Timer(
        const Duration(milliseconds: 150),
        () {
          if (query != null && query.isNotEmpty) {
            cubit.getPredictions();
          } else {
            cubit.clear();
          }
        },
      );
      return null;
    }

    return BlocBuilder<GoogleMapCubit, GoogleMapState>(
        builder: (context, state) {
      return SizedBox(
        width: width / 1.2,
        child: CustomTextFormFeild(
          focusNode: cubit.searchFocusNode,
          controller: cubit.searchController,
          label: 'الى اين تود الذهاب؟...',
          onChange: onSearchChanged,
          prefixIcon: SvgPicture.asset(
            AppImages.search,
            height: 20,
            width: 20,
            fit: BoxFit.scaleDown,
          ),
        ),
      );
    });
  }
}

class PlacesListWidget extends StatelessWidget {
  final bool internal;
  const PlacesListWidget({
    super.key,
    required this.internal,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoogleMapCubit, GoogleMapState>(
      builder: (context, state) {
        var cubit = context.read<GoogleMapCubit>();
        return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => ListTile(
                  onTap: () async {
                    await cubit.getPlaceDetails(
                        placeId: cubit.predictions[index].placeId!,
                        internal: internal);
                    if (context.mounted) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  leading: SvgPicture.asset(
                    AppImages.clock,
                    height: 20,
                    width: 20,
                    fit: BoxFit.scaleDown,
                  ),
                  title: Text(cubit.predictions[index].description!),
                  trailing: SvgPicture.asset(
                    AppImages.frame,
                    height: 20,
                    width: 20,
                    fit: BoxFit.scaleDown,
                  ),
                ),
            itemCount: cubit.predictions.length);
      },
    );
  }
}

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({
    super.key,
    required this.cubit,
    required this.mapStyle,
    required this.isUser,
    required this.startLocation,
    required this.internal,
  });
  final bool isUser;
  final bool internal;
  final GoogleMapCubit cubit;
  final String? mapStyle;
  final LatLng? startLocation;

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  bool _isCameraMoving = false;
  LatLng location = const LatLng(35.27088501447092, 46.055900529026985);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: widget.cubit.markers,
      polylines: widget.cubit.polyLines,
      polygons: widget.cubit.polygon,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      rotateGesturesEnabled: false,
      compassEnabled: false,
      initialCameraPosition: widget.cubit.cameraPosition,
      myLocationEnabled: false,
      onCameraMove: (position) {
        setState(() {
          _isCameraMoving = true;
          location = position.target;
        });
      },
      onCameraIdle: () {
        setState(() {
          _isCameraMoving = false;
          widget.cubit.selectedLocation = location;
        });
        if (widget.internal) {
          bool inSide = widget.cubit.chackInternalOrNot(location);
          if (inSide) {
            widget.cubit.selectedPlaceName(location);
          } else {
            showToastificationWidget(
              message: 'المكان خارج الحدود المسموح بها',
              context: context,
            );
          }
        } else {
          widget.cubit.selectedPlaceName(location);
        }
      },
      onMapCreated: (GoogleMapController controller) async {
        widget.cubit.googleMapController = controller;
        widget.cubit.getMapStyle(mapStyle: widget.mapStyle!);

        await widget.cubit.getLocationMyCurrentLocation(
          startLocation: widget.startLocation,
        );
        if (widget.cubit.regionModel == null && widget.internal) {
          await widget.cubit.getGovernorates(internal: widget.internal);
        }
      },
    );
  }
}
