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
  
}
