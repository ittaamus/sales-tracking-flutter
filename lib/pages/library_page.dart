import 'package:flutter/material.dart';
import 'package:salesyuasa/models/customerModel.dart';
import 'package:salesyuasa/models/login_model.dart';
import 'package:ionicons/ionicons.dart';
import 'package:salesyuasa/models/barang_model.dart';
import 'package:salesyuasa/config/base_config.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File;
import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesyuasa/models/visitModel.dart';
import 'package:salesyuasa/services/shared_preferences_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

part 'login_page.dart';
part 'home_page.dart';
part '../controllers/login_controller.dart';
part '../core/router.dart';
part 'home/upcomingcard_page.dart';
part 'home/feature_page.dart';

// services
part '../services/barang_service.dart';
part '../services/login_service.dart';
part '../services/visitService.dart';
part '../services/customerService.dart';
part '../services/location_service.dart';

part '../controllers/barang_controller.dart';
part '../controllers/visitController.dart';
part '../controllers/customerController.dart';


part 'barang/barang_page.dart';
part 'barang/updatebarang_page.dart';
part '../pages/barang/addbarang_page.dart';
part 'customer/customer_page.dart';
part 'home/location_page.dart';
part 'templates/header_page.dart';
part 'templates/footer_page.dart';
part 'visit/visit_page.dart';
part 'visit/addVisit.dart';
part 'main_page.dart';
part 'profile/profile_page.dart';
