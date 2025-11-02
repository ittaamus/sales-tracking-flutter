part of '../pages/library_page.dart';

class VisitController {
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<List<VisitModel>> visitList = ValueNotifier([]);

  VisitController() {
    // Load initial data
    loadData();
  }

  void loadData() async {
    try {
      List<VisitModel> visits = await VisitService().fetchVisits();
      visitList.value = visits;
    } catch (e) {
      debugPrint('Error loading visits: $e');
    }
  } 

  void searchVisit() {
    // Implement search functionality
  }

  Future<bool> deleteVisit(String visitId, BuildContext context, param2) async {
    // Simulate delete action
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  void dispose() {
    searchController.dispose();
  }
}
