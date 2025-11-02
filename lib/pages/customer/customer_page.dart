part of '../library_page.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CustomerController _customerController = CustomerController();
  List<CustomerModel> customers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final customerList = await _customerController.getAllCustomers();
      setState(() {
        customers = customerList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading customers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7A0000),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.add),
            onPressed: () {
              // Navigate to add customer page
              Navigator.pushNamed(context, '/addCustomer').then((_) {
                _loadCustomers(); // Refresh list after adding
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.people_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No customers found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCustomers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF7A0000),
                            child: Text(
                              customer.cUSTOMERNAME?.substring(0, 1).toUpperCase() ?? 'C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            customer.cUSTOMERNAME ?? 'Unknown Customer',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer.cUSTOMEREMAIL != null && customer.cUSTOMEREMAIL!.isNotEmpty)
                                Text(
                                  customer.cUSTOMEREMAIL!,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              if (customer.cUSTOMERALAMAT != null && customer.cUSTOMERALAMAT!.isNotEmpty)
                                Text(
                                  customer.cUSTOMERALAMAT!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.pushNamed(
                                  context,
                                  '/updateCustomer',
                                  arguments: customer,
                                ).then((_) {
                                  _loadCustomers(); // Refresh list after editing
                                });
                              } else if (value == 'delete') {
                                _showDeleteDialog(customer);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Ionicons.create_outline),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Ionicons.trash_outline, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to customer detail or edit
                            Navigator.pushNamed(
                              context,
                              '/updateCustomer',
                              arguments: customer,
                            ).then((_) {
                              _loadCustomers();
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showDeleteDialog(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customer.cUSTOMERNAME}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality in controller/service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality not implemented yet')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}