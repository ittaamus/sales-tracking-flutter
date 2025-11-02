part of '../pages/library_page.dart';

class LocationService {
  /// Get current high accuracy position with address
  static Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get high accuracy position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1, // Update when moved by 1 meter
        ),
      );

      // Get address from coordinates (reverse geocoding)
      String address = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          address = _buildAddressFromPlacemark(placemarks[0]);
        }
      } catch (e) {
        // If geocoding fails, use coordinates as address
        address = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get current position only (without address)
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    );
  }

  /// Get address from coordinates
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return _buildAddressFromPlacemark(placemarks[0]);
      }
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Build readable address from placemark
  static String _buildAddressFromPlacemark(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
      addressParts.add(place.subAdministrativeArea!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      addressParts.add(place.postalCode!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.isNotEmpty 
        ? addressParts.join(', ') 
        : 'Unknown Address';
  }

  /// Check if location permissions are granted
  static Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Check if location service is enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get coordinates from address (geocoding) with improved accuracy
  static Future<Map<String, double?>> getCoordinatesFromAddress(String address) async {
    try {
      if (address.trim().isEmpty) {
        throw Exception('Address cannot be empty');
      }

      // Add timeout to prevent hanging
      List<Location> locations = await locationFromAddress(address)
          .timeout(const Duration(seconds: 10));
      
      if (locations.isNotEmpty) {
        // Get the most accurate location (first one is usually best)
        Location location = locations.first;
        
        // Validate coordinates are reasonable (within world bounds)
        if (location.latitude >= -90 && location.latitude <= 90 &&
            location.longitude >= -180 && location.longitude <= 180) {
          return {
            'latitude': location.latitude,
            'longitude': location.longitude,
          };
        } else {
          throw Exception('Invalid coordinates returned');
        }
      } else {
        throw Exception('No coordinates found for this address');
      }
    } catch (e) {
      throw Exception('Failed to get coordinates from address: ${e.toString()}');
    }
  }

  /// Get multiple possible coordinates from address
  static Future<List<Map<String, dynamic>>> getMultipleCoordinatesFromAddress(String address) async {
    try {
      if (address.trim().isEmpty) {
        throw Exception('Address cannot be empty');
      }

      List<Location> locations = await locationFromAddress(address);
      return locations.map((location) => {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': location.timestamp,
      }).toList();
    } catch (e) {
      throw Exception('Failed to get coordinates from address: ${e.toString()}');
    }
  }

  /// Validate if address can be geocoded
  static Future<bool> canGeocodeAddress(String address) async {
    try {
      if (address.trim().isEmpty || address.length < 10) return false;
      
      List<Location> locations = await locationFromAddress(address)
          .timeout(const Duration(seconds: 8));
      return locations.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get address suggestions for improved user experience
  static Future<List<String>> getAddressSuggestions(String partialAddress) async {
    try {
      if (partialAddress.trim().isEmpty || partialAddress.length < 5) {
        return [];
      }
      
      // Add common Indonesian location suffixes to improve search
      List<String> searchVariations = [
        partialAddress,
        '$partialAddress, Indonesia',
        '$partialAddress, Jakarta',
        '$partialAddress, Surabaya',
        '$partialAddress, Bandung',
      ];
      
      List<String> suggestions = [];
      
      for (String searchTerm in searchVariations) {
        try {
          List<Location> locations = await locationFromAddress(searchTerm)
              .timeout(const Duration(seconds: 5));
          
          if (locations.isNotEmpty) {
            // Get address back from coordinates for validation
            String validatedAddress = await getAddressFromCoordinates(
              locations.first.latitude, 
              locations.first.longitude
            );
            
            if (!suggestions.contains(validatedAddress)) {
              suggestions.add(validatedAddress);
            }
          }
        } catch (e) {
          continue; // Skip this variation
        }
        
        if (suggestions.length >= 3) break; // Limit suggestions
      }
      
      return suggestions;
    } catch (e) {
      return [];
    }
  }

  /// Get distance between two points in meters
  static double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}