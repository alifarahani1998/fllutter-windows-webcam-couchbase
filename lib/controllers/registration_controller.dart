import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cbl/cbl.dart';
import 'package:flutter_customers_info/helpers/global.dart';
import 'package:flutter_customers_info/models/customers_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RegistrationStates {}

class RegistrationStatesInitial extends RegistrationStates {}

class RegistrationStatesRegistered extends RegistrationStates {}

class RegistrationStatesLoading extends RegistrationStates {}

class RegistrationStatesError extends RegistrationStates {
  final String error;
  RegistrationStatesError({required this.error});
}

class RegistrationController extends Cubit<RegistrationStates> {
  RegistrationController() : super(RegistrationStatesInitial()) {
    initialSharedPreferences();
  }

  Future<void> initialSharedPreferences() async {
    Global.shPreferences = await SharedPreferences.getInstance();
  }

  Future<void> registerCustomerInfo(String firstName, String lastName,
      String nationalCode, String imageUri) async {
    emit(RegistrationStatesLoading());

    if (!(await checkNationalCodeExists(nationalCode))) {
      emit(
          RegistrationStatesError(error: 'کاربر با کد ملی وارد شده موجود است'));
      return;
    }
    // Open the database (creating it if it doesn’t exist).
    final database = await Database.openAsync('customers_info');

    // Create a new document.
    final mutableDocument = MutableDocument();
    await database.saveDocument(mutableDocument);

    // Update the document.
    mutableDocument.setString(firstName, key: 'first_name');
    mutableDocument.setString(lastName, key: 'last_name');
    mutableDocument.setString(nationalCode, key: 'national_code');
    mutableDocument.setString(imageUri, key: 'image_uri');
    await database.saveDocument(mutableDocument);

    // Close the database.
    await database.close();

    emit(RegistrationStatesRegistered());
  }

  Future<bool> checkNationalCodeExists(String keyword) async {
    // Open the database (creating it if it doesn’t exist).
    final database = await Database.openAsync('customers_info');

    // Create a query to fetch documents.
    final query = await Query.fromN1ql(database, '''
      SELECT * FROM customers_info
      WHERE national_code LIKE '$keyword'
    ''');

    // Run the query.
    final resultSet = await query.execute();
    List<CustomerInfoModel> matchedUsers = [];

    await for (final result in resultSet.asStream()) {
      final item = result.dictionary(0)!;
      matchedUsers.add(CustomerInfoModel(
        nationalCode: item.string('national_code'),
      ));
    }

    if (matchedUsers.length != 0) {
      // Close the database.
      await database.close();

      return false;
    }

    // Close the database.
    await database.close();
    return true;
  }
}
