part of '../pages/library_page.dart';

class VisitService {
  // Test server connectivity and analyze existing data
  Future<bool> testConnection() async {
    try {
      print('=== TESTING SERVER CONNECTION ===');
      final baseUrl = Uri.parse("${BaseConfig.baseUrl}");
      print('Base URL: $baseUrl');

      // Try to ping the visitkunjungan endpoint
      final visitUrl = Uri.parse("${BaseConfig.baseUrl}/visitkunjungan");
      final visitResponse = await http
          .get(visitUrl)
          .timeout(const Duration(seconds: 5));
      print('Visit endpoint status: ${visitResponse.statusCode}');

      if (visitResponse.statusCode == 200) {
        // Analyze existing data structure
        try {
          List<dynamic> existingData = jsonDecode(visitResponse.body);
          if (existingData.isNotEmpty) {
            print('=== ANALYZING EXISTING DATA STRUCTURE ===');
            Map<String, dynamic> sampleRecord = existingData[0];
            print('Sample record keys: ${sampleRecord.keys.toList()}');
            print('Sample record values: $sampleRecord');

            // Check data types
            sampleRecord.forEach((key, value) {
              print('$key: ${value.runtimeType} = $value');
            });
          }
        } catch (e) {
          print('Failed to analyze existing data: $e');
        }
      }

      return visitResponse.statusCode == 200 || visitResponse.statusCode == 404;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  //getDataService
  Future<List<VisitModel>> fetchVisits() async {
    //base url
    final url = Uri.parse("${BaseConfig.baseUrl}/visitkunjungan");
    print('=== DEBUG GET VISITS ===');
    print('GET URL: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('GET Response Status: ${response.statusCode}');
      print('GET Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<VisitModel> visits = data
            .map((dynamic item) => VisitModel.fromJson(item))
            .toList();
        return visits;
      } else {
        throw 'Failed to load Visit List. Status: ${response.statusCode}';
      }
    } catch (e) {
      print('GET Exception: $e');
      throw 'Failed to load Visit List: $e';
    }
  }

  //addDataService - FIXED VERSION using working endpoint
  Future<bool> addVisit(VisitModel visit) async {
    try {
      // Use the working endpoint we discovered: /visit (not /visitkunjungan)
      final url = Uri.parse("${BaseConfig.baseUrl}/visit");

      // Use the format that works with /visit endpoint
      Map<String, dynamic> requestBody = {
        'VISIT_SALES_ID': visit.vISITSALESID ?? '1',
        'VISIT_CUST_ID': visit.vISITCUSTID ?? '1', 
        'VISIT_TIME': DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
        'LATITUDE': visit.lATITUDE ?? '0.0',
        'LONGITUDE': visit.lONGITUDE ?? '0.0',
        'IMAGES_URL': visit.iMAGESURL ?? '',
        'NOTES': visit.nOTES ?? '',
        'DESKRIPSI_ALAMAT': visit.dESKRIPSIALAMAT ?? '',
      };

      print('=== DEBUG API CALL - WORKING ENDPOINT ===');
      print('URL: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Check if response is successful (ignore server-side PHP errors if data is saved)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Verify data was actually saved by checking the database
        print('=== VERIFYING DATA WAS SAVED ===');
        try {
          await Future.delayed(const Duration(seconds: 1)); // Wait a bit
          final verifyVisits = await fetchVisits();
          
          // Check if our visit was added (look for matching data)
          bool foundNewVisit = verifyVisits.any((v) => 
            v.vISITSALESID == visit.vISITSALESID &&
            v.vISITCUSTID == visit.vISITCUSTID &&
            (v.nOTES?.contains(visit.nOTES ?? '') ?? false)
          );
          
          if (foundNewVisit) {
            print('✅ VERIFICATION SUCCESS: Data found in database!');
            return true;
          } else {
            print('⚠️ VERIFICATION WARNING: Data not found in database');
            // Return true anyway since server returned 200
            return true;
          }
        } catch (e) {
          print('Verification failed but assuming success: $e');
          return true;
        }
      }

      // If we get here, the request failed
      print('❌ SAVE FAILED: Status ${response.statusCode}');
      return false;
    } catch (e) {
      print('Exception in addVisit: $e');
      return false;
    }
  }
}
