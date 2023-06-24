import 'dart:ffi';

import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/screens/cart/widget/cart_product_widget.dart';
import 'package:efood_multivendor/view/screens/subscription/subscription_checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatefulWidget {
  final product;
  SubscriptionScreen({@required this.product});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreen();
}

class _SubscriptionScreen extends State<SubscriptionScreen> {

  int qty = 1;
  double price = 0;
  double originalPrice = 0;
  bool mon = false;
  bool tue = false;
  bool wed = false;
  bool thu = false;
  bool fri = false;
  bool sat = false;
  bool sun = false;
  bool alternate = false;
  bool weekend = false;
  bool all = false;

  TextEditingController dateFromInput = TextEditingController();
  TextEditingController dateToInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    originalPrice = widget.product.price;
    price = widget.product.price;
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Subscription'.tr, isBackButtonExist: (ResponsiveHelper.isDesktop(context) )),
      body:  Column(
          children: [
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL), physics: BouncingScrollPhysics(),
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.WEB_MAX_WIDTH,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Card(
                      color: Colors.grey.shade200,
                          elevation: 5.0,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image.network(
                                 '${AppConstants.BASE_URL}/storage/app/public/product/${widget.product.image.toString()}',
                                  height: 80,
                                  width: 80,
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: '',
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                  '${widget.product.name.toString()}\n',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold)),
                                            ]),
                                      ),
                                      RichText(
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: 'Unit: ',
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                  '${qty.toString()}\n',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold)),
                                            ]),
                                      ),
                                      RichText(
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: 'Price: ₹',
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                  '${price.toString()}\n',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold)),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        TextButton(
                                          child: Container(
                                            color: Colors.orange,
                                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                                            child: const Text(
                                              '-',
                                              style: TextStyle(color: Colors.white, fontSize: 18.0),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if(qty > 1){
                                              setState(() {
                                                int newQty = qty -1;
                                                qty = newQty;
                                                price = originalPrice * newQty;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(qty.toString()),
                                    Column(
                                      children: [
                                        TextButton(
                                          child: Container(
                                            color: Colors.orange,
                                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                                            child: const Text(
                                              '+',
                                              style: TextStyle(color: Colors.white, fontSize: 18.0),
                                            ),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                                int newQty = qty + 1;
                                                qty = newQty;
                                                price = originalPrice * newQty;
                                              });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ),
                      Text('Days', style : TextStyle(fontSize: 16, height: 2 )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(child: MaterialButton(
                            color: mon ? Colors.orange : Colors.grey,
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                mon = !mon;
                              });

                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'M',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          )),
                          Flexible(child: MaterialButton(
                            color: tue ? Colors.orange : Colors.grey,
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                tue = !tue;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'T',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          )),
                          Flexible(child: MaterialButton(
                            color: wed ? Colors.orange : Colors.grey,
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                wed = !wed;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'W',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          )),
                          Flexible(child: MaterialButton(
                            color: thu ? Colors.orange : Colors.grey,
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                thu = !thu;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'T',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          )),
                          Flexible(child: MaterialButton(
                            color: fri ? Colors.orange : Colors.grey,
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                fri = !fri;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'F',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          )),
                          Flexible(child: MaterialButton(
                            color: sat ? Colors.orange : Colors.grey,
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                sat = !sat;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'S',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          )),
                          Flexible(child: MaterialButton(
                            color: sun ? Colors.orange : Colors.grey,
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                sun = !sun;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'S',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          )),
                        ],
                      ),
                      Text('From Date', style : TextStyle(fontSize: 16, height: 2 )),
                        TextField(
                          controller: dateFromInput,
                          decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today), //icon of text field
                              labelText: "Enter Date" //label text of field
                          ),
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(Duration(days: 0)),
                                lastDate: DateTime(2100));
                            if (pickedDate != null) {
                              print(
                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                              String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                              print(
                                  formattedDate); //formatted date output using intl package =>  2021-03-16
                              setState(() {
                                dateFromInput.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {}
                          },
                        ),
                      Text('To Date', style : TextStyle(fontSize: 16, height: 2 )),
                        TextField(
                          controller: dateToInput,
                          //editing controller of this TextField
                          decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today), //icon of text field
                              labelText: "Enter Date" //label text of field
                          ),
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(Duration(days: 0)),
                                lastDate: DateTime(2100));
                                if (pickedDate != null) {
                                  print(
                                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                                  print(
                                      formattedDate); //formatted date output using intl package =>  2021-03-16
                                  setState(() {
                                    dateToInput.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                } else {}
                          },
                        ),
                      Text('Time Slot', style : TextStyle(fontSize: 16, height: 2 )),
                        TextField(
                          controller: timeInput, //editing controller of this TextField
                          decoration: InputDecoration(
                              icon: Icon(Icons.timer), //icon of text field
                              labelText: "Enter Time" //label text of field
                          ),
                          readOnly: true,  //set it true, so that user will not able to edit text
                          onTap: () async {
                            TimeOfDay pickedTime =  await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              context: context,
                            );
                            if(pickedTime != null ){
                              print(pickedTime.format(context));   //output 10:51 PM
                              DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                              print(parsedTime); //output 1970-01-01 22:53:00.000
                              String formattedTime = DateFormat('hh:mm a').format(parsedTime);
                              print(formattedTime); //output 14:59:00
                              setState(() {
                                timeInput.text = formattedTime; //set the value of text field.
                              });
                            }else{
                              print("Time is not selected");
                            }
                          },
                        ),
                        Text('Options', style : TextStyle(fontSize: 16, height: 2 )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                                child:  TextButton(
                                  child: Container(
                                    color: alternate ? Colors.orange : Colors.grey,
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    child: const Text(
                                      'Alternative',
                                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      alternate = true;
                                      weekend = false;
                                      all = false;
                                      mon =  true;
                                      tue = false;
                                      wed = true;
                                      thu = false;
                                      fri = true;
                                      sat = false;
                                      sun = true;
                                    });
                                  },
                                ),
                            ),
                            Flexible(
                              child:  TextButton(
                                child: Container(
                                  color: weekend ? Colors.orange : Colors.grey,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  child: const Text(
                                    'Weekend',
                                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    alternate = false;
                                    weekend = true;
                                    all = false;
                                    mon =  false;
                                    tue = false;
                                    wed = false;
                                    thu = false;
                                    fri = false;
                                    sat = true;
                                    sun = true;
                                  });
                                },
                              ),
                            ),
                            Flexible(
                              child:  TextButton(
                                child: Container(
                                  color: all ? Colors.orange : Colors.grey,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  child: const Text(
                                    'All',
                                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    alternate = false;
                                    weekend = false;
                                    all = true;
                                    mon =  true;
                                    tue = true;
                                    wed = true;
                                    thu = true;
                                    fri = true;
                                    sat = true;
                                    sun = true;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Center(
                          child: Text('TOTAL:  ${price}/Day', style: TextStyle(fontSize: 18, height: 2, fontWeight: FontWeight.w600),),
                        )
                      ]
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              width: Dimensions.WEB_MAX_WIDTH,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: CustomButton(buttonText: 'proceed_to_checkout'.tr, onPressed: () async{
                     bool dayError = true;
                     bool finalError = false;
                     if(mon || tue || wed || thu || fri || sat || sun){
                       dayError = false;
                     }
                     if(dayError){
                       var snackBar = SnackBar(
                         content: Text('At least one day selection required!'),
                         backgroundColor: Colors.red,
                         padding: EdgeInsets.all(10),
                         behavior: SnackBarBehavior.floating,
                         // shape: StadiumBorder(),
                         duration: Duration(milliseconds: 3000),
                         action: SnackBarAction(
                           label: 'Dismiss',
                           disabledTextColor: Colors.white,
                           textColor: Colors.white,
                           onPressed: () {
                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
                           },
                         ),
                       );
                       // Step 3
                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
                       finalError = true;
                   }
                   else if(dateFromInput.text == ''){
                       var snackBar = SnackBar(
                         content: Text('From date is required!'),
                         backgroundColor: Colors.red,
                         padding: EdgeInsets.all(10),
                         behavior: SnackBarBehavior.floating,
                         // shape: StadiumBorder(),
                         duration: Duration(milliseconds: 3000),
                         action: SnackBarAction(
                           label: 'Dismiss',
                           disabledTextColor: Colors.white,
                           textColor: Colors.white,
                           onPressed: () {
                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
                           },
                         ),
                       );
                       // Step 3
                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
                       finalError = true;
                   }
                   else if(dateToInput.text == ''){
                       var snackBar = SnackBar(
                         content: Text('To date is required!'),
                         backgroundColor: Colors.red,
                         padding: EdgeInsets.all(10),
                         behavior: SnackBarBehavior.floating,
                         // shape: StadiumBorder(),
                         duration: Duration(milliseconds: 3000),
                         action: SnackBarAction(
                           label: 'Dismiss',
                           disabledTextColor: Colors.white,
                           textColor: Colors.white,
                           onPressed: () {
                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
                           },
                         ),
                       );
                       // Step 3
                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
                       finalError = true;
                   }
                   else if(timeInput.text == ''){
                       var snackBar = SnackBar(
                         content: Text('Time is required!'),
                         backgroundColor: Colors.red,
                         padding: EdgeInsets.all(10),
                         behavior: SnackBarBehavior.floating,
                         // shape: StadiumBorder(),
                         duration: Duration(milliseconds: 3000),
                         action: SnackBarAction(
                           label: 'Dismiss',
                           disabledTextColor: Colors.white,
                           textColor: Colors.white,
                           onPressed: () {
                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
                           },
                         ),
                       );
                       // Step 3
                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
                       finalError = true;
                   }


                   List dayList = getDaysInBetween(DateTime.parse(dateFromInput.text.toString()), DateTime.parse(dateToInput.text.toString()));
                   List newDate = [];
                   dayList.forEach((currentDate) {
                     String convertDay = DateFormat('EEEE').format(currentDate);
                     if(sun && convertDay == 'Sunday'){
                       newDate.add(currentDate);
                     }
                     else if(mon && convertDay == 'Monday'){
                       newDate.add(currentDate);
                     }
                     else if(tue && convertDay == 'Tuesday'){
                       newDate.add(currentDate);
                     }
                     else if(wed && convertDay == 'Wednesday'){
                       newDate.add(currentDate);
                     }
                     else if(thu && convertDay == 'Thursday'){
                       newDate.add(currentDate);
                     }
                     else if(fri && convertDay == 'Friday'){
                       newDate.add(currentDate);
                     }
                     else if(sat && convertDay == 'Saturday'){
                       newDate.add(currentDate);
                     }
                   });
                   if(newDate.length == 0){
                     var snackBar = SnackBar(
                       content: Text('Date range not detecting at least one date !'),
                       backgroundColor: Colors.red,
                       padding: EdgeInsets.all(10),
                       behavior: SnackBarBehavior.floating,
                       // shape: StadiumBorder(),
                       duration: Duration(milliseconds: 3000),
                       action: SnackBarAction(
                         label: 'Dismiss',
                         disabledTextColor: Colors.white,
                         textColor: Colors.white,
                         onPressed: () {
                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
                         },
                       ),
                     );
                     // Step 3
                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                     finalError = true;
                   }
                   print(newDate);
                   if(!finalError){
                     double total = price * newDate.length;
                     Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => SubscriptionCheckoutScreen (
                               monday : mon,
                               tuesday : tue,
                               wednesday : wed,
                               thursday : thu,
                               friday : fri,
                               saturday : sat,
                               sunday : sun,
                               product : widget.product,
                               fromDate : dateFromInput.text,
                               toDate : dateToInput.text,
                               timeSlot : timeInput.text,
                               selectedDate : newDate,
                               qty : qty,
                               total : total,
                               fromCart : false,
                               cartList : []
                           ),
                         ));

                     print('${total} Navigate to proceed to check out ########################################################');
                   }
              }),
            ),
          ],
        )
      );
  }
}
