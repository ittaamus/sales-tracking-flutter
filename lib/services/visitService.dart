part of '../pages/library_page.dart';

class VisitService {
  //getDataService
  Future<List<VisitModel>> fetchVisits() async {
    //base url
    final url = Uri.parse("${BaseConfig.baseUrl}/visitkunjungan");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<VisitModel> visits = data
          .map((dynamic item) => VisitModel.fromJson(item))
          .toList();
      return visits;
    } else {
      throw 'Failed to load Visit List';
    }
  }

  //addDataService
  Future<bool> addVisit(VisitModel visit) async {
    final url = Uri.parse("${BaseConfig.baseUrl}/visitkunjungan");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'VISIT_SALES_ID': visit.vISITSALESID,
        'VISIT_CUST_ID': visit.vISITCUSTID,
        'VISIT_TIME': visit.vISITTIME,
        'LATITUDE': visit.lATITUDE,
        'LONGITUDE': visit.lONGITUDE,
        'IMAGES_URL': visit.iMAGESURL,
        'NOTES': visit.nOTES,
        'DESKRIPSIALAMAT': visit.dESKRIPSIALAMAT,
      }),
    );

    if (response.statusCode == 201) {

      return true;
    } else {
      return false;
    }
  }
}
