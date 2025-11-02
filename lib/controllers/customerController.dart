part of '../pages/library_page.dart';

class CustomerController {
  final CustomerService _customerService = CustomerService();

 Future<List<CustomerModel>> getAllCustomers() {
    return _customerService.getCustomers();
  }

  
}
