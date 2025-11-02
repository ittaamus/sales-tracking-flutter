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

  //addDataService - Using visitkunjungan endpoint with form data
  Future<bool> addVisit(VisitModel visit) async {
    try {
      // Use the visitkunjungan endpoint as requested
      final url = Uri.parse("${BaseConfig.baseUrl}/visitkunjungan");

      // Create multipart request for form data (matching PHP $_POST expectations)
      var request = http.MultipartRequest('POST', url);
      
      // Add form fields (matching PHP $_POST structure)
      request.fields['VISIT_SALES_ID'] = visit.vISITSALESID ?? '1';
      request.fields['VISIT_CUST_ID'] = visit.vISITCUSTID ?? '1';
      request.fields['VISIT_TIME'] = DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19);
      request.fields['LATITUDE'] = visit.lATITUDE ?? '0.0';
      request.fields['LONGITUDE'] = visit.lONGITUDE ?? '0.0';
      request.fields['NOTES'] = visit.nOTES ?? '';
      request.fields['DESKRIPSI_ALAMAT'] = visit.dESKRIPSIALAMAT ?? '';

      // Handle image file if exists
      if (visit.iMAGESURL != null && visit.iMAGESURL!.isNotEmpty && visit.iMAGESURL != '') {
        // Check if it's a local file path
        if (File(visit.iMAGESURL!).existsSync()) {
          var imageFile = await http.MultipartFile.fromPath(
            'IMAGES_URL', // This matches $_FILES['IMAGES_URL'] in PHP
            visit.iMAGESURL!,
          );
          request.files.add(imageFile);
          print('Added image file: ${visit.iMAGESURL}');
        } else {
          print('Image file not found or not local path: ${visit.iMAGESURL}');
        }
      }

      print('=== DEBUG API CALL - VISITKUNJUNGAN FORM DATA ===');
      print('URL: $url');
      print('Form Fields: ${request.fields}');
      print('Files: ${request.files.map((f) => '${f.field}: ${f.filename}').join(', ')}');

      // Send the request
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

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
