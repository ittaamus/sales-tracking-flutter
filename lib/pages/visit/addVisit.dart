part of '../library_page.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final VisitController visitController = VisitController();
  final CustomerController customerController = CustomerController();
  final TextEditingController customerSearchController =
      TextEditingController();

  List<CustomerModel> customers = [];
  CustomerModel? selectedCustomer;
  bool isLoading = true;
  bool isAutoDetectingLocation = false;
  File? selectedImage;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    // Set default location values
    visitController.latitudeController.text = '0.0';
    visitController.longitudeController.text = '0.0';

    // Add listener to address field for auto-geocoding with proper debouncing
    visitController.addressController.addListener(_onAddressChanged);

    // Automatically get current location when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocationSilently();
    });
  }

  void _onAddressChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _updateCoordinatesFromAddress();
      }
    });
  }

  Future<void> _loadCustomers() async {
    try {
      final customerList = await customerController.getAllCustomers();
      setState(() {
        customers = customerList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading customers: $e')));
      }
    }
  }

  Future<void> _updateCoordinatesFromAddress() async {
    String address = visitController.addressController.text.trim();

    // Don't geocode very short addresses or empty addresses
    if (address.length < 15) return;

    try {
      // Show subtle loading indicator
      setState(() {
        isAutoDetectingLocation = true;
      });

      // Get coordinates from address
      Map<String, double?> coordinates =
          await LocationService.getCoordinatesFromAddress(address);

      if (coordinates['latitude'] != null &&
          coordinates['longitude'] != null &&
          mounted) {
        // Update coordinate fields
        setState(() {
          visitController.latitudeController.text = coordinates['latitude']!
              .toStringAsFixed(6);
          visitController.longitudeController.text = coordinates['longitude']!
              .toStringAsFixed(6);
        });

        // Show subtle success notification
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.location_searching,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Coordinates auto-updated from address!'),
                  ),
                ],
              ),
              backgroundColor: Colors.blue.shade700,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
        }
      }
    } catch (e) {
      // Don't show error for automatic geocoding, just log it
      debugPrint('Auto geocoding failed for address: $address - Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isAutoDetectingLocation = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocationSilently() async {
    try {
      setState(() {
        isAutoDetectingLocation = true;
      });

      // Check permissions quietly
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isAutoDetectingLocation = false;
        });
        return; // Fail silently if GPS is disabled
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isAutoDetectingLocation = false;
          });
          return; // Fail silently
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isAutoDetectingLocation = false;
        });
        return; // Fail silently
      }

      // Get position quietly with medium accuracy for speed
      Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 0,
              timeLimit: Duration(seconds: 10),
            ),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Location timeout');
            },
          );

      // Update coordinates
      if (mounted) {
        setState(() {
          visitController.latitudeController.text = position.latitude
              .toString();
          visitController.longitudeController.text = position.longitude
              .toString();
        });
      }

      // Get address quietly
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 8));

        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks[0];
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
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          }

          String address = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';

          setState(() {
            visitController.addressController.text = address;
          });

          // Show subtle success notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location Auto-Detected!'),
                        Text(
                          'Accuracy: ±${position.accuracy.toStringAsFixed(1)}m',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        // Address geocoding failed, but we still have coordinates
        debugPrint('Silent geocoding failed: $e');
      }
    } catch (e) {
      // Fail silently - don't show error messages for automatic location
      debugPrint('Silent location failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          isAutoDetectingLocation = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
          visitController.imageUrlController.text = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _saveVisit() async {
    // Validate required fields
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }

    if (visitController.notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter visit notes')));
      return;
    }

    try {
      // Create new visit model
      VisitModel newVisit = VisitModel(
        vISITSALESID: visitController.salesIdController.text.isNotEmpty
            ? visitController.salesIdController.text
            : 'default_sales_id',
        vISITCUSTID: selectedCustomer!.cUSTOMERID,
        vISITTIME: DateTime.now().toIso8601String(),
        lATITUDE: visitController.latitudeController.text,
        lONGITUDE: visitController.longitudeController.text,
        iMAGESURL: visitController.imageUrlController.text,
        nOTES: visitController.notesController.text,
        dESKRIPSIALAMAT: visitController.addressController.text,
      );

      // Save visit using service
      bool success = await VisitService().addVisit(newVisit);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit saved successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to save visit')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving visit: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Visit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7A0000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Autocomplete<CustomerModel>(
                            displayStringForOption: (CustomerModel option) =>
                                option.cUSTOMERNAME ?? 'Unknown Customer',
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return const Iterable<
                                      CustomerModel
                                    >.empty();
                                  }
                                  return customers.where((
                                    CustomerModel option,
                                  ) {
                                    return (option.cUSTOMERNAME ?? '')
                                        .toLowerCase()
                                        .contains(
                                          textEditingValue.text.toLowerCase(),
                                        );
                                  });
                                },
                            onSelected: (CustomerModel selection) {
                              setState(() {
                                selectedCustomer = selection;
                                customerSearchController.text =
                                    selection.cUSTOMERNAME ?? '';
                              });
                            },
                            fieldViewBuilder:
                                (
                                  BuildContext context,
                                  TextEditingController
                                  fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted,
                                ) {
                                  // Sync with our controller
                                  if (customerSearchController
                                          .text
                                          .isNotEmpty &&
                                      fieldTextEditingController.text.isEmpty) {
                                    fieldTextEditingController.text =
                                        customerSearchController.text;
                                  }

                                  return TextFormField(
                                    controller: fieldTextEditingController,
                                    focusNode: fieldFocusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Search Customer *',
                                      hintText: 'Type customer name...',
                                      prefixIcon: const Icon(
                                        Ionicons.person_outline,
                                      ),
                                      suffixIcon:
                                          fieldTextEditingController
                                              .text
                                              .isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                fieldTextEditingController
                                                    .clear();
                                                customerSearchController
                                                    .clear();
                                                setState(() {
                                                  selectedCustomer = null;
                                                  // Alamat tidak dihapus saat clear customer
                                                });
                                              },
                                            )
                                          : const Icon(Ionicons.search_outline),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (selectedCustomer == null) {
                                        return 'Please select a customer';
                                      }
                                      return null;
                                    },
                                  );
                                },
                            optionsViewBuilder:
                                (
                                  BuildContext context,
                                  AutocompleteOnSelected<CustomerModel>
                                  onSelected,
                                  Iterable<CustomerModel> options,
                                ) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                          maxWidth: 300,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                final CustomerModel option =
                                                    options.elementAt(index);
                                                return ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        const Color(0xFF7A0000),
                                                    radius: 16,
                                                    child: Text(
                                                      (option.cUSTOMERNAME ??
                                                              'C')
                                                          .substring(0, 1)
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    option.cUSTOMERNAME ??
                                                        'Unknown Customer',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  subtitle:
                                                      option.cUSTOMEREMAIL !=
                                                          null
                                                      ? Text(
                                                          option.cUSTOMEREMAIL!,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                        )
                                                      : null,
                                                  dense: true,
                                                  onTap: () {
                                                    onSelected(option);
                                                  },
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sales ID
                  TextField(
                    controller: visitController.salesIdController,
                    decoration: InputDecoration(
                      labelText: 'Sales ID',
                      prefixIcon: const Icon(Ionicons.id_card_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Visit Notes
                  TextField(
                    controller: visitController.notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Visit Notes *',
                      prefixIcon: const Icon(Ionicons.document_text_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Address Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Address Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: visitController.addressController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Address Description',
                              hintText:
                                  'Enter full address (e.g., Jl. Sudirman No.1, Jakarta)',
                              prefixIcon: isAutoDetectingLocation
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.blue.shade600,
                                              ),
                                        ),
                                      ),
                                    )
                                  : const Icon(Ionicons.location_outline),
                              suffixIcon:
                                  visitController
                                      .addressController
                                      .text
                                      .isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        visitController.addressController
                                            .clear();
                                        setState(() {
                                          visitController
                                                  .latitudeController
                                                  .text =
                                              '0.0';
                                          visitController
                                                  .longitudeController
                                                  .text =
                                              '0.0';
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.cyan.shade50,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Smart Address Recognition',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Type complete address (min 15 chars) and coordinates will be automatically calculated',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Location Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (isAutoDetectingLocation)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.blue.shade700,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Auto-detecting...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                      visitController.latitudeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Latitude',
                                    prefixIcon: const Icon(
                                      Icons.my_location,
                                      size: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    fillColor: Colors.grey.shade50,
                                    filled: true,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller:
                                      visitController.longitudeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Longitude',
                                    prefixIcon: const Icon(
                                      Icons.my_location,
                                      size: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    fillColor: Colors.grey.shade50,
                                    filled: true,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Fully Automatic Location System',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '✨ GPS location auto-detected on page load\n🗺️ Address changes auto-update coordinates\n📍 No manual buttons needed - everything is automatic!',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Image Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visit Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (selectedImage != null) ...[
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Ionicons.camera),
                              label: Text(
                                selectedImage != null
                                    ? 'Change Photo'
                                    : 'Take Photo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveVisit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A0000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Visit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    visitController.addressController.removeListener(_onAddressChanged);
    visitController.dispose();
    customerSearchController.dispose();
    super.dispose();
  }
}
