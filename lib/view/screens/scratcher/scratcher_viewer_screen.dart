import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/html_type.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_ui/universal_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scratcher/scratcher.dart';

class ScratcherViewerScreen extends StatefulWidget {

  @override
  State<ScratcherViewerScreen> createState() => _ScratcherViewerScreenState();
}

class _ScratcherViewerScreenState extends State<ScratcherViewerScreen> {
  @override
  List scratcherList = [];
  void initState() {
    Future.delayed(Duration.zero,() async {
      Map newData = await getScratcherList();

      if(newData['status']){
        setState((){
          scratcherList = newData['data'];
        });
      }

    });

    super.initState();
  }


  getScratcherList() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString(AppConstants.TOKEN);
    final responseOrder = await http.get(
        Uri.parse('${AppConstants.BASE_URL}/api/v1/my-scratchers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${token}',
        }
    );

    print('API RESPONSE');
    print(json.decode(responseOrder.body)['data']);
    print('API RESPONSE');
    return await json.decode(responseOrder.body);
  }


  applyCoupon(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString(AppConstants.TOKEN);
    print('${AppConstants.BASE_URL}/api/v1/user-scratcher-apply/${id}}');
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/api/v1/user-scratcher-apply/${id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}',
      },
    );
    final res =  await json.decode(response.body);
    print(res);
  }
  Widget build(BuildContext context) {
    print('LIST-----------------------');
    print(scratcherList[0]['checked']);
    for (var i in scratcherList)
      print(i);
    return Scaffold(
      appBar: CustomAppBar(title: 'My Scratchers'.tr),
      body: Center(
        child: Container(
          width: Dimensions.WEB_MAX_WIDTH,
          height: MediaQuery.of(context).size.height,
          color: GetPlatform.isWeb ? Colors.white : Theme.of(context).cardColor,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              children : (scratcherList != null) ? [ for (var i in scratcherList)
                 Card(
                    elevation: 10, //shadow elevation for card
                    child:  Padding(
                      padding: const EdgeInsets.all(10),
                      child : i['checked'] == 0 ?
                      Scratcher(
                        brushSize: 50,
                        threshold: 50,
                        color: Colors.red,
                        image: Image.asset(
                          "assets/image/scratcher.png",
                          fit: BoxFit.fill,
                        ),
                        onChange: (value) =>{
                          if(value == 100.0){
                            print("Scratch progress: $value%")
                          }
                        },
                        onThreshold: () =>{
                          applyCoupon(i['id']),
                          showCustomSnackBar('Scratch amount added to your wallet',isError: false),
                        },

                        child: Image.network(
                                '${AppConstants.BASE_URL}/public/images/${i['scratch']}',
                                fit: BoxFit.fill,
                              ),
                      )
                          :
                      Image.network('${AppConstants.BASE_URL}/public/images/${i['scratch']}'),
                    ),
                )
               ] : [Text('No Scratcher')],
              )
            ),
          )
        ),
      );

  }
}