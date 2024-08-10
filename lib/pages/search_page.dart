import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customers_info/controllers/search_query_controller.dart';
import 'package:flutter_customers_info/utils/constants.dart';
import 'package:flutter_customers_info/widgets/main_button.dart';
import 'package:flutter_customers_info/widgets/text_input.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController keywordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchQueryController>(
      // this bloc was not provided in any other parent widgets
      create: (context) => SearchQueryController(),
      child: BlocConsumer<SearchQueryController, SearchQueryStates>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: lightOrange.withOpacity(0.8),
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'جست و جوی کاربر',
                style: TextStyle(fontSize: 30, color: lightOrange),
              ),
            ),
            body: Container(
                child: Column(
              children: [
                TextInput(
                  hintText: 'نام خانوادگی یا کد ملی',
                  textEditingController: keywordController,
                ),
                MainButton(
                    isWaiting: state is SearchQueryStatesLoading,
                    onPressed: () {
                      if (keywordController.text.isNotEmpty)
                        context
                            .read<SearchQueryController>()
                            .retrieveCustomerInfo(keywordController.text);
                    },
                    text: strSearch,
                    color: whiteColor,
                    textColor: lightOrange),
                SizedBox(
                  height: 10,
                ),
                MainButton(
                    isWaiting: state is SearchQueryStatesLoading,
                    onPressed: () =>
                        context.read<SearchQueryController>().deleteDatabase(),
                    text: 'حذف پایگاه داده',
                    color: whiteColor,
                    textColor: lightOrange),
                SizedBox(
                  height: 20,
                ),
                state is SearchQueryStatesFound // when a user or some users match with the search keyword
                    ? Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2,
                          child: ListView.builder(
                            itemCount: state.users.length,
                            itemBuilder: (context, index) => Column(
                              children: [
                                Container(
                                  width: 300,
                                  height: 300,
                                  child:
                                      Image.file(state.users[index].imageUri!),
                                ),
                                Text(
                                  'نام: ${state.users[index].firstName!}',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'نام خانوادگی: ${state.users[index].lastName!}',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'کد ملی: ${state.users[index].nationalCode!}',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container() // if search has no result or not searched yet
              ],
            )),
          );
        },
      ),
    );
  }
}
