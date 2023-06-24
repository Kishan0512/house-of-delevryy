import 'dart:async';
import 'dart:ffi';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scratcher/scratcher.dart';
import 'package:http/http.dart' as http;
import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'dart:convert';

class OrderSuccessfulScreen extends StatefulWidget {
  final String orderID;
  final int status;
  final double totalAmount;

  OrderSuccessfulScreen(
      {@required this.orderID,
      @required this.status,
      @required this.totalAmount});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  Map apiRes = <String, dynamic>{
    'status' : false,
    'message' : 'Not available',
    'data' : {}
  };
  @override
  void initState() {
    Future.delayed(Duration.zero,() async {
      Map newData = await getScratchCard();
      setState(() {
        apiRes =  newData;
      });
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // String token = await prefs.getString(AppConstants.TOKEN);
      //
      // final responseOrder = await http.get(
      //     Uri.parse('${AppConstants.BASE_URL}/api/v1/customer/order/track?order_id=${widget.orderID}'),
      //     headers: <String, String>{
      //       'Content-Type': 'application/json; charset=UTF-8',
      //       'Authorization': 'Bearer ${token}',
      //     }
      // );
      // // // order_amount
      // print('COME-------');
      // print(json.decode(responseOrder.body)['order_amount']);
      //
      // final response = await http.post(
      //   Uri.parse('${AppConstants.BASE_URL}/api/v1/get-random-scratcher'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json; charset=UTF-8',
      //     'Authorization': 'Bearer ${token}',
      //   },
      //   body: jsonEncode(<String, dynamic>{
      //     'price': json.decode(responseOrder.body)['order_amount'],
      //   }),
      // );
      // // setState(() {
      //   apiRes =  json.decode(response.body);
      // // });
      //
      // print(apiRes);
    });
    Get.find<OrderController>()
        .trackOrder(widget.orderID.toString(), null, false);

    // if(widget.totalAmount != null){
    //   getScratchCard(widget.totalAmount);
    // }
    super.initState();
  }


  getScratchCard() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString(AppConstants.TOKEN);

    final responseOrder = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/api/v1/customer/order/track?order_id=${widget.orderID}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}',
      }
    );
    // order_amount
    print('COME-------');
    print(json.decode(responseOrder.body)['order_amount']);

    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/api/v1/get-random-scratcher'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}',
      },
      body: jsonEncode(<String, dynamic>{
        'price': json.decode(responseOrder.body)['order_amount'],
      }),
    );
    return await json.decode(response.body);

    print('API RESPONSE');
    print(apiRes);
  }

  applyCoupon(Map applyData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString(AppConstants.TOKEN);

    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/api/v1/user-scratcher-apply/${applyData['get_id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}',
      },
    );
    final res =  await json.decode(response.body);
    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      body: GetBuilder<OrderController>(builder: (orderController) {
        double total = 0;
        bool success = true;

        if (orderController.trackModel != null) {
          print('PAYMENT STATUS');
          print(orderController.trackModel.paymentStatus);
          print(apiRes);
          print('PAYMENT STATUS');
          total = ((orderController.trackModel.orderAmount / 100) *
              Get.find<SplashController>()
                  .configModel
                  .loyaltyPointItemPurchasePoint);
          success = orderController.trackModel.paymentStatus == 'paid' ||
              orderController.trackModel.paymentMethod == 'cash_on_delivery';

          print('UNHP -----------------------------------------------------------');
          print(orderController.trackModel.orderAmount);

          print('UNHP -----------------------------------------------------------');

          if (!success) {
            Future.delayed(Duration(seconds: 1), () {
              Get.dialog(PaymentFailedDialog(orderID: widget.orderID),
                  barrierDismissible: false);
            });
          }
        }

        return orderController.trackModel != null
            ? Center(
                child: SizedBox(
                    width: Dimensions.WEB_MAX_WIDTH,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(success ? Images.checked : Images.warning,
                              width: 100, height: 100),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          Text(
                            success
                                ? 'you_placed_the_order_successfully'.tr
                                : 'your_order_is_failed_to_place'.tr,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge),
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_LARGE,
                                vertical: Dimensions.PADDING_SIZE_SMALL),
                            child: Text(
                              success
                                  ? 'your_order_is_placed_successfully'.tr
                                  : 'your_order_is_failed_to_place_because'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // (orderController.trackModel.paymentStatus == 'paid' && apiRes is Map && apiRes['status'] == true)
                          //     ? Column(children: [
                          //   Scratcher(
                          //     brushSize: 50,
                          //     threshold: 50,
                          //     color: Colors.red,
                          //     image: Image.asset(
                          //       "assets/image/scratcher.png",
                          //       fit: BoxFit.fill,
                          //       width: 200,
                          //       height: 200,
                          //     ),
                          //     onChange: (value) =>
                          //         print("Scratch progress: $value%"),
                          //     onThreshold: () =>
                          //         print("Threshold reached, you won!"),
                          //     child: Container(
                          //       height: 200,
                          //       width: 200,
                          //       color: Colors.white,
                          //       child: Column(
                          //         // mainAxisAlignment:
                          //         //     MainAxisAlignment.spaceEvenly,
                          //         // crossAxisAlignment: CrossAxisAlignment.center,
                          //         children: [
                          //           Image.network(
                          //             '${AppConstants.BASE_URL}/public/images/${apiRes['data']['media']}',
                          //             fit: BoxFit.contain,
                          //             width: 250,
                          //             height: 200,
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          //   Text('You earn the scratch'.tr,
                          //       style: robotoMedium.copyWith(
                          //           fontSize: Dimensions.fontSizeLarge)),
                          //   // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          // ])
                          // : SizedBox.shrink(),


                          (orderController.trackModel?.paymentStatus == 'paid' && apiRes is Map && apiRes['status'] == true)
                              ? Column(children: [
                            Scratcher(
                              brushSize: 50,
                              threshold: 50,
                              color: Colors.red,
                              image: Image.asset(
                                "assets/image/scratcher.png",
                                fit: BoxFit.fill,
                                width: 200,
                                height: 200,
                              ),
                              onChange: (value) =>{
                                if(value == 100.0){
                                  print("Scratch progress: $value%")
                                }
                              },
                              onThreshold: () =>{
                                // print("Threshold reached, you won! *****************************************")
                                applyCoupon(apiRes['data']),
                                showCustomSnackBar('Scratch amount added to your wallet',isError: false),
                              },

                              child: Container(
                                height: 200,
                                width: 200,
                                color: Colors.white,
                                child: Column(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceEvenly,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      '${AppConstants.BASE_URL}/public/images/${apiRes['data']['media']}',
                                      fit: BoxFit.fill,
                                      width: 250,
                                      height: 200,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text('You earn the scratch'.tr,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge)),
                            // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          ])
                              : SizedBox.shrink(),



                          (success &&
                                  Get.find<SplashController>()
                                          .configModel
                                          .loyaltyPointStatus ==
                                      1 &&
                                  total.floor() > 0)
                              ? Column(children: [
                                  Image.asset(
                                      Get.find<ThemeController>().darkTheme
                                          ? Images.gift_box1
                                          : Images.gift_box,
                                      width: 150,
                                      height: 150),
                                  Text('congratulations'.tr,
                                      style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge)),
                                  SizedBox(
                                      height: Dimensions.PADDING_SIZE_SMALL),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.PADDING_SIZE_LARGE),
                                    child: Text(
                                      'you_have_earned'.tr +
                                          ' ${total.floor().toString()} ' +
                                          'points_it_will_add_to'.tr,
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color:
                                              Theme.of(context).disabledColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ])
                              : SizedBox.shrink(),
                          SizedBox(height: 30),
                          Padding(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            child: CustomButton(
                                buttonText: 'back_to_home'.tr,
                                onPressed: () => Get.offAllNamed(
                                    RouteHelper.getInitialRoute())),
                          ),
                        ])))
            : Center(child: CircularProgressIndicator());
      }),
    );
  }
}
