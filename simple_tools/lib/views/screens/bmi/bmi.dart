import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_tools/views/screens/bmi/result.dart';
import '../../../../util/app_constants.dart';
import '../../custom_widgets/button.dart';
import '../../custom_widgets/bmi_widgets.dart';

class Startup extends StatefulWidget {
  const Startup({super.key});

  @override
  State<Startup> createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  final _heightNotifier = ValueNotifier<double>(AppConstants.height);
  final _weightNotifier = ValueNotifier<double>(AppConstants.weight.toDouble());
  final _ageNotifier = ValueNotifier<double>(AppConstants.age.toDouble());

  Color _maleColor = AppConstants.mainColor;
  Color _femaleColor = AppConstants.mainColor;

  Timer? _weightTimer;
  Timer? _ageTimer;

  void _toggleGender(int gender) {
    setState(() {
      if (gender == 1) {
        _maleColor = _maleColor == AppConstants.secColor
            ? AppConstants.mainColor
            : AppConstants.secColor;
        _femaleColor = AppConstants.mainColor;
      } else {
        _femaleColor = _femaleColor == AppConstants.secColor
            ? AppConstants.mainColor
            : AppConstants.secColor;
        _maleColor = AppConstants.mainColor;
      }
    });
  }

  void _startTimer(
      ValueNotifier<double> notifier, bool increment, double min, double max) {
    _stopTimer();
    _weightTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        double newValue = increment ? notifier.value + 1 : notifier.value - 1;
        if (newValue >= min && newValue <= max) {
          notifier.value = newValue;
          _updateController(notifier);
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    _weightTimer?.cancel();
    _ageTimer?.cancel();
  }

  void _updateController(ValueNotifier<double> notifier) {
    if (notifier == _weightNotifier) {
      AppConstants.weightController.text = notifier.value.toStringAsFixed(0);
    } else if (notifier == _ageNotifier) {
      AppConstants.ageController.text = notifier.value.toStringAsFixed(0);
    }
  }

  @override
  void initState() {
    super.initState();
    AppConstants.heightController.text =
        AppConstants.defaultHeight.toStringAsFixed(0);
    AppConstants.ageController.text =
        AppConstants.defaultAge.toStringAsFixed(0);
    AppConstants.weightController.text =
        AppConstants.defaultWeight.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Body Mass Calculator")),
        backgroundColor: const Color(0xFF448AFF),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Row(
                  children: [
                    _buildGenderSelector(
                        1, "Male", FontAwesomeIcons.mars, _maleColor),
                    const SizedBox(width: 10),
                    _buildGenderSelector(
                        2, "Female", FontAwesomeIcons.venus, _femaleColor),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: _buildHeightSelector(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  children: [
                    _buildWeightSelector(),
                    const SizedBox(width: 10),
                    _buildAgeSelector(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BottomButton(
                value: 'Calculate',
                onPressed: () => _showResult(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(
      int gender, String label, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleGender(gender),
        child: CustomContainer(
          colors: color,
          cardchild: Containcard(icon: icon, txt: label),
        ),
      ),
    );
  }

  Widget _buildHeightSelector() {
    return CustomContainer(
      colors: AppConstants.mainColor,
      cardchild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Height",
              style: TextStyle(color: Colors.white60, fontSize: 15)),
          ValueListenableBuilder<double>(
            valueListenable: _heightNotifier,
            builder: (context, height, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: AppConstants.bmrheightController,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 50,
                          fontWeight: FontWeight.w900),
                      onChanged: (value) {
                        double? newHeight = double.tryParse(value);
                        if (newHeight != null &&
                            newHeight >= AppConstants.minHeight &&
                            newHeight <= AppConstants.maxHeight) {
                          _heightNotifier.value = newHeight;
                          AppConstants.height = newHeight;
                        }
                      },
                    ),
                  ),
                  const Text("CM"),
                ],
              );
            },
          ),
          Slider(
            value: _heightNotifier.value,
            min: AppConstants.minHeight.toDouble(),
            max: AppConstants.maxHeight.toDouble(),
            activeColor: const Color.fromARGB(255, 184, 173, 143),
            onChanged: (double newValue) {
              setState(() {
                _heightNotifier.value = newValue;
                AppConstants.height = newValue.round().toDouble();
                AppConstants.bmrheightController.text =
                    newValue.round().toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSelector() {
    return Expanded(
      child: CustomContainer(
        colors: AppConstants.mainColor,
        cardchild: _buildNumberSelector(
            "Weight", _weightNotifier, AppConstants.weightController, "KG"),
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Expanded(
      child: CustomContainer(
        colors: AppConstants.mainColor,
        cardchild: _buildNumberSelector(
            "Age", _ageNotifier, AppConstants.ageController, ""),
      ),
    );
  }

  Widget _buildNumberSelector(String label, ValueNotifier<double> notifier,
      TextEditingController controller, String unit) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: controller,
                decoration: const InputDecoration(border: InputBorder.none),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 50,
                    fontWeight: FontWeight.w900),
                onChanged: (newValue) {
                  double? value = double.tryParse(newValue);
                  if (value != null) {
                    notifier.value = value;
                    if (label == "Weight") {
                      AppConstants.weight = value.round();
                    } else if (label == "Age") {
                      AppConstants.age = value.round();
                    }
                  }
                },
              ),
            ),
            Text(unit, style: const TextStyle(fontSize: 15)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIncrementButton(FontAwesomeIcons.minus,
                () => _startTimer(notifier, false, 0, 300)),
            const SizedBox(width: 15),
            _buildIncrementButton(FontAwesomeIcons.plus,
                () => _startTimer(notifier, true, 0, 300)),
          ],
        ),
      ],
    );
  }

  Widget _buildIncrementButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onLongPress: onPressed,
      onLongPressEnd: (_) => _stopTimer(),
      child: RoundButton(
        icon: icon,
        onpressed: onPressed,
      ),
    );
  }

  void _showResult(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const Result();
      },
    );
  }
}
