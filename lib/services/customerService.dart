part of '../pages/library_page.dart';

class CustomerService {
  Future<List<CustomerModel>> getCustomers() async {
    // Implementasi untuk mengambil data pelanggan
    final response = await http.get(Uri.parse('${BaseConfig.baseUrl}/customer'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CustomerModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    // Implementasi untuk menambahkan pelanggan
    final response = await http.post(
      Uri.parse('${BaseConfig.baseUrl}/customer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customer.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    // Implementasi untuk memperbarui data pelanggan
    final response = await http.put(
      Uri.parse('${BaseConfig.baseUrl}/customer/${customer.cUSTOMERID}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customer.toJson()),
    );
    return response.statusCode == 200;
  }


}
