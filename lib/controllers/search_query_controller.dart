import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cbl/cbl.dart';
import 'package:flutter_customers_info/models/customers_info_model.dart';

abstract class SearchQueryStates {}

class SearchQueryStatesInitial extends SearchQueryStates {}

class SearchQueryStatesFound extends SearchQueryStates {
  // number of matched users with the query
  final List<CustomerInfoModel> users;
  SearchQueryStatesFound({required this.users});
}

class SearchQueryStatesLoading extends SearchQueryStates {}

class SearchQueryStatesError extends SearchQueryStates {
  final String error;
  SearchQueryStatesError({required this.error});
}

class SearchQueryController extends Cubit<SearchQueryStates> {
  SearchQueryController() : super(SearchQueryStatesInitial());

  Future<void> retrieveCustomerInfo(String keyword) async {
    emit(SearchQueryStatesLoading());

    // Open the database (creating it if it doesn’t exist).
    final database = await Database.openAsync('customers_info');

    // Create a query to fetch documents.
    final query = await Query.fromN1ql(database, '''
      SELECT * FROM customers_info
      WHERE last_name LIKE '$keyword'
      OR national_code LIKE '$keyword'
    ''');

    // Run the query.
    final resultSet = await query.execute();
    List<CustomerInfoModel> matchedUsers = [];

    await for (final result in resultSet.asStream()) {
      final item = result.dictionary(0)!;
      matchedUsers.add(CustomerInfoModel(
        firstName: item.string('first_name'),
        lastName: item.string('last_name'),
        nationalCode: item.string('national_code'),
        imageUri: await Io.File('image_${item.string('national_code')}.png')
            .writeAsBytes(base64Decode(item.string('image_uri')!)),
      ));
      FileImage(File('image_${item.string('national_code')}.png')).evict();
    }

    // Close the database.
    await database.close();

    emit(SearchQueryStatesFound(users: matchedUsers));
  }

  Future<void> deleteDatabase() async {
    emit(SearchQueryStatesLoading());

    // Open the database (creating it if it doesn’t exist).
    final database = await Database.openAsync('customers_info');
    await database.delete();
    // Close the database.
    await database.close();
    emit(SearchQueryStatesInitial());
  }
}
