import 'package:mdsoft_google_map_user_pick_location_from_scroll/google_map_routing_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class GoogleMapRoutingPlatform extends PlatformInterface {
  /// Constructs a GoogleMapRoutingPlatform.
  GoogleMapRoutingPlatform() : super(token: _token);

  static final Object _token = Object();

  static GoogleMapRoutingPlatform _instance = MethodChannelGoogleMapRouting();

  /// The default instance of [GoogleMapRoutingPlatform] to use.
  ///
  /// Defaults to [MethodChannelGoogleMapRouting].
  static GoogleMapRoutingPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GoogleMapRoutingPlatform] when
  /// they register themselves.
  static set instance(GoogleMapRoutingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
