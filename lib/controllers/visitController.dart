part of '../pages/library_page.dart';

class VisitController {
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<List<VisitModel>> visitList = ValueNotifier([]);
  
  // Add visit form controllers
  final TextEditingController salesIdController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

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

  void addVisit() {
    //add visit functionality
    VisitModel newVisit = VisitModel(
      vISITSALESID: 'new_sales_id',
      vISITCUSTID: 'new_customer_id',
      vISITTIME: DateTime.now().toString(),
      lATITUDE: '0.0',
      lONGITUDE: '0.0',
      iMAGESURL: '',
      nOTES: 'New visit note',
      dESKRIPSIALAMAT: 'New visit address',
    );

    VisitService().addVisit(newVisit).then((success) {
      if (success) {
        debugPrint('Visit added successfully');
        loadData(); // Refresh the visit list
      } else {
        debugPrint('Failed to add visit');
      }
    });
  }

  Future<bool> deleteVisit(String visitId, BuildContext context, param2) async {
    // Simulate delete action
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  void dispose() {
    searchController.dispose();
    salesIdController.dispose();
    notesController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    imageUrlController.dispose();
  }
}
