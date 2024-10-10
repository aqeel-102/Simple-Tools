import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_tools/util/app_constants.dart';

import '../../../util/images.dart';

class PrepaidRechargeCalculator extends StatefulWidget {
  const PrepaidRechargeCalculator({super.key});

  @override
  State<PrepaidRechargeCalculator> createState() =>
      _PrepaidRechargeCalculatorState();
}

class _PrepaidRechargeCalculatorState extends State<PrepaidRechargeCalculator> {
  TextEditingController amountController = TextEditingController();

  final double tax = 88.889 / 100;
  double amount = 100;
  bool isRecharged = true;
  Color amountRechargedCardColor = AppConstants.activeColor;
  Color amountReceivedCardColor = AppConstants.secColor;
  Color jazzCardColor = AppConstants.activeColor;
  Color telenorCardColor = AppConstants.secColor;
  Color ufoneCardColor = AppConstants.secColor;
  Color zongCardColor = AppConstants.secColor;
  int selectedSimCard = 1;
  double minSliderValue = 100;
  double maxSliderValue = 10000;

  updateData({required bool isRecharged, required int selectedSimCard}) {
    selectedSimCard == 1
        ? (
            jazzCardColor = AppConstants.activeColor,
            telenorCardColor = AppConstants.secColor,
            ufoneCardColor = AppConstants.secColor,
            zongCardColor = AppConstants.secColor,
            minSliderValue = isRecharged ? 100 : 88.889,
            amount = isRecharged ? 100 : 88.889,
            amountController.text = amount.toStringAsFixed(0),
            maxSliderValue = isRecharged ? 10000 : 8888.90,
          )
        : selectedSimCard == 2
            ? (
                jazzCardColor = AppConstants.secColor,
                telenorCardColor = AppConstants.activeColor,
                ufoneCardColor = AppConstants.secColor,
                zongCardColor = AppConstants.secColor,
                minSliderValue = isRecharged ? 80 : 71.11,
                amount = isRecharged ? 80 : 71.11,
                amountController.text = amount.toStringAsFixed(0),
                maxSliderValue = isRecharged ? 10000 : 8888.90,
              )
            : selectedSimCard == 3
                ? (
                    jazzCardColor = AppConstants.secColor,
                    telenorCardColor = AppConstants.secColor,
                    ufoneCardColor = AppConstants.activeColor,
                    zongCardColor = AppConstants.secColor,
                    minSliderValue = isRecharged ? 90 : 80,
                    amount = isRecharged ? 90 : 80,
                    amountController.text = amount.toStringAsFixed(0),
                    maxSliderValue = isRecharged ? 5000 : 4444.45,
                  )
                : (
                    jazzCardColor = AppConstants.secColor,
                    telenorCardColor = AppConstants.secColor,
                    ufoneCardColor = AppConstants.secColor,
                    zongCardColor = AppConstants.activeColor,
                    minSliderValue = isRecharged ? 80 : 71.11,
                    amount = isRecharged ? 80 : 71.11,
                    amountController.text = amount.toStringAsFixed(0),
                    maxSliderValue = isRecharged ? 20000 : 17777.80,
                  );
  }

  @override
  void initState() {
    amountController.text = amount.toStringAsFixed(0);
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double amountRecharged = isRecharged ? amount * tax : amount / tax;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppConstants.secColor,
      appBar: AppBar(
        backgroundColor: AppConstants.mainColor,
        title: const Text(
          AppConstants.mobileRechargeScreenTitle,
          style: TextStyle(
            color: AppConstants.textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          selectedSimCard = 1;
                          updateData(
                            isRecharged: isRecharged,
                            selectedSimCard: selectedSimCard,
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10.0,
                        top: 10.0,
                        right: 5.0,
                        bottom: 5.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: jazzCardColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(Images.mobileRecharge),
                            height: 50,
                            width: 50,
                          ),
                          Text(
                            AppConstants.jazzTitle,
                            style: TextStyle(
                              color: AppConstants.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          selectedSimCard = 2;
                          updateData(
                            isRecharged: isRecharged,
                            selectedSimCard: selectedSimCard,
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        top: 10.0,
                        right: 5.0,
                        bottom: 5.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: telenorCardColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(Images.mobileRecharge),
                            height: 50,
                            width: 50,
                          ),
                          Text(
                            AppConstants.telenorTitle,
                            style: TextStyle(
                              color: AppConstants.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          selectedSimCard = 3;
                          updateData(
                            isRecharged: isRecharged,
                            selectedSimCard: selectedSimCard,
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        top: 10.0,
                        right: 5.0,
                        bottom: 5.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: ufoneCardColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(Images.mobileRecharge),
                            height: 50,
                            width: 50,
                          ),
                          Text(
                            AppConstants.ufoneTitle,
                            style: TextStyle(
                              color: AppConstants.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          selectedSimCard = 4;
                          updateData(
                            isRecharged: isRecharged,
                            selectedSimCard: selectedSimCard,
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        top: 10.0,
                        right: 10.0,
                        bottom: 5.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: zongCardColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(Images.mobileRecharge),
                            height: 50,
                            width: 50,
                          ),
                          Text(
                            AppConstants.zongTitle,
                            style: TextStyle(
                              color: AppConstants.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          isRecharged = true;
                          amountReceivedCardColor = AppConstants.secColor;
                          amountRechargedCardColor = AppConstants.activeColor;
                          updateData(
                            isRecharged: isRecharged,
                            selectedSimCard: selectedSimCard,
                          );
                        },
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      margin: const EdgeInsets.only(
                        left: 10.0,
                        top: 5.0,
                        right: 5.0,
                        bottom: 5.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: amountRechargedCardColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Text(
                        textAlign: TextAlign.center,
                        AppConstants.rechargingAmountTitle,
                        style: TextStyle(
                          color: AppConstants.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          isRecharged = false;
                          amountReceivedCardColor = AppConstants.activeColor;
                          amountRechargedCardColor = AppConstants.secColor;
                          updateData(
                            isRecharged: isRecharged,
                            selectedSimCard: selectedSimCard,
                          );
                        },
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        top: 5.0,
                        right: 10.0,
                        bottom: 5.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: amountReceivedCardColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Text(
                        textAlign: TextAlign.center,
                        AppConstants.receivingAmountTitle,
                        style: TextStyle(
                          color: AppConstants.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    alignment: Alignment.center,
                    height: double.infinity,
                    margin: const EdgeInsets.only(
                      left: 10.0,
                      top: 5.0,
                      right: 5.0,
                      bottom: 5.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: AppConstants.secColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Slider(
                          value: amount.toDouble(),
                          activeColor: Colors.blue,
                          inactiveColor: Colors.blue[300],
                          onChanged: (double value) {
                            setState(
                              () {
                                amount = value;
                                amountController.text =
                                    amount.toStringAsFixed(0);
                              },
                            );
                          },
                          min: minSliderValue,
                          max: maxSliderValue,
                        ),
                        Text(
                          ('${minSliderValue.toStringAsFixed(0)} - ${maxSliderValue.toStringAsFixed(0)}'),
                          style: const TextStyle(color: AppConstants.textColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    height: double.infinity,
                    margin: const EdgeInsets.only(
                      left: 5.0,
                      top: 5.0,
                      right: 10.0,
                      bottom: 5.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: AppConstants.secColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: amountController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      // onChanged: (String value) {
                      //   setState(
                      //     () {
                      //       if (double.parse(value) >= minSliderValue &&
                      //           double.parse(value) <= maxSliderValue) {
                      //         amount = double.parse(value);
                      //       }
                      //     },
                      //   );
                      // },
                      // onSubmitted: (String value) {
                      //   setState(
                      //     () {
                      //       if (double.parse(value) >= minSliderValue &&
                      //           double.parse(value) <= maxSliderValue) {
                      //         amount = double.parse(value);
                      //       } else if (double.parse(value) < minSliderValue ||
                      //           !amountController.text.isNotEmpty) {
                      //         amount = minSliderValue;
                      //         amountController.text =
                      //             minSliderValue.toStringAsFixed(0);
                      //       } else {
                      //         amount = maxSliderValue;
                      //         amountController.text =
                      //             maxSliderValue.toStringAsFixed(0);
                      //       }
                      //     },
                      //   );
                      // },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.only(
                top: 50.0,
              ),
              alignment: Alignment.topCenter,
              height: double.infinity,
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppConstants.secColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Text(
                    amountRecharged.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isRecharged
                        ? AppConstants.amountRechargeMessage
                        : AppConstants.amountReceiveMessage,
                    style: const TextStyle(color: AppConstants.textColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
