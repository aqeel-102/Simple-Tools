import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_tools/views/screens/bmr/result_bmr.dart';
import '../../../../util/app_constants.dart';
import '../../custom_widgets/button.dart';

class BMR extends StatefulWidget {
  const BMR({super.key});

  @override
  State<BMR> createState() => _BMRState();
}

class _BMRState extends State<BMR> {
  final _heightNotifier = ValueNotifier<double>(AppConstants.height);
  final _weightNotifier = ValueNotifier<double>(AppConstants.weight.toDouble());
  final _ageNotifier = ValueNotifier<double>(AppConstants.age.toDouble());

  Color maleColor = AppConstants.mainColor;
  Color femaleColor = AppConstants.mainColor;

  Timer? _weightTimer;
  Timer? _ageTimer;

  void _toggleGender(int gender) {
    setState(() {
      if (gender == 1) {
        maleColor = maleColor == AppConstants.secColor
            ? AppConstants.mainColor
            : AppConstants.secColor;
        femaleColor = AppConstants.mainColor;
      } else {
        femaleColor = femaleColor == AppConstants.secColor
            ? AppConstants.mainColor
            : AppConstants.secColor;
        maleColor = AppConstants.mainColor;
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
      AppConstants.bmrweightController.text = notifier.value.toStringAsFixed(0);
    } else if (notifier == _ageNotifier) {
      AppConstants.bmrageController.text = notifier.value.toStringAsFixed(0);
    }
  }

  void _incrementValue(ValueNotifier<double> notifier, bool increment) {
    double newValue = increment ? notifier.value + 1 : notifier.value - 1;
    if (newValue >= 0 && newValue <= 300) {
      setState(() {
        notifier.value = newValue;
        _updateController(notifier);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AppConstants.bmrheightController.text =
        AppConstants.defaultHeight.toStringAsFixed(0);
    AppConstants.bmrageController.text =
        AppConstants.defaultAge.toStringAsFixed(0);
    AppConstants.bmrweightController.text =
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "BMR Calculator",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Row(
                    children: [
                      _buildGenderSelector(
                          1, "Male", FontAwesomeIcons.mars, maleColor),
                      const SizedBox(width: 16),
                      _buildGenderSelector(
                          2, "Female", FontAwesomeIcons.venus, femaleColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: _buildHeightSelector(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Row(
                    children: [
                      _buildWeightSelector(),
                      const SizedBox(width: 16),
                      _buildAgeSelector(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                BottomButton(
                  value: 'Calculate BMR',
                  onPressed: () => _showResult(context),
                ),
              ],
            ),
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
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeightSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.mainColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.mainColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Height",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                      maxLength: 3,
                      textAlign: TextAlign.center,
                      controller: AppConstants.bmrheightController,
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: (value) {
                        double? newHeight = double.tryParse(value);
                        if (newHeight != null &&
                            newHeight >= AppConstants.minHeight &&
                            newHeight <= AppConstants.maxHeight) {
                          setState(() {
                            _heightNotifier.value = newHeight;
                            AppConstants.height = newHeight;
                            AppConstants.bmrheightController.text = value;
                          });
                        }
                      },
                    ),
                  ),
                  const Text(
                    "cm",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppConstants.mainColor,
              inactiveTrackColor: AppConstants.mainColor.withOpacity(0.2),
              thumbColor: AppConstants.mainColor,
              overlayColor: AppConstants.mainColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _heightNotifier.value,
              min: AppConstants.minHeight.toDouble(),
              max: AppConstants.maxHeight.toDouble(),
              onChanged: (double newValue) {
                setState(() {
                  _heightNotifier.value = newValue;
                  AppConstants.height = newValue.round().toDouble();
                  AppConstants.bmrheightController.text =
                      newValue.round().toString();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSelector() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.mainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppConstants.mainColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: _buildNumberSelector(
            "Weight", _weightNotifier, AppConstants.bmrweightController, "kg"),
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.mainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppConstants.mainColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: _buildNumberSelector(
            "Age", _ageNotifier, AppConstants.bmrageController, ""),
      ),
    );
  }

  Widget _buildNumberSelector(String label, ValueNotifier<double> notifier,
      TextEditingController controller, String unit) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              child: TextFormField(
                maxLength: 3,
                textAlign: TextAlign.center,
                controller: controller,
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
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
            Text(
              unit,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _incrementValue(notifier, false),
              onLongPress: () => _startTimer(notifier, false, 0, 300),
              onLongPressEnd: (_) => _stopTimer(),
              child: _buildIncrementButton(FontAwesomeIcons.minus),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => _incrementValue(notifier, true),
              onLongPress: () => _startTimer(notifier, true, 0, 300),
              onLongPressEnd: (_) => _stopTimer(),
              child: _buildIncrementButton(FontAwesomeIcons.plus),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncrementButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppConstants.mainColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 16,
        color: AppConstants.mainColor,
      ),
    );
  }

  void _showResult(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const BmrResult();
      },
    );
  }
}
