import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/themes.dart';

///callback when scrolling changed, since you ask for int
/// i prefer double instead : 20.5 kg or 100.34 kg
typedef OnScrollChanged = void Function(double scale);

///calback when selected
typedef OnSelected = void Function(double scale);

class ScaleIndicator extends StatefulWidget {
  /// default value show in widget when first open
  final double? initialValue;

  ///what the distance for performance, min max kg so the we can pass max length to listview builder
  final int? range;
  final Color? indicatorColor;

  ///callback when scrolling changed
  final OnScrollChanged? onScrollChanged;

  const ScaleIndicator({
    Key? key,
    this.initialValue,
    this.range,
    this.indicatorColor,
    this.onScrollChanged,
  }) : super(key: key);

  @override
  State<ScaleIndicator> createState() => _ScaleIndicatorState();
}

class _ScaleIndicatorState extends State<ScaleIndicator> {
  // default value show in widget when first open
  late double _initialValue;

  // what the distance for performance, min max kg so the we can pass max length to listview builder
  late int _range;

  late Color _indicatorColor;

  late double _valueSelected;

  static const double _indicatorWidth = 10.0;

  @override
  void initState() {
    super.initState();
    // set your default value here
    _initialValue = 0;
    _range = 200;
    _indicatorColor = Colors.blue;
    _valueSelected = 0;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        double pixels = scroll.metrics.pixels;
        double result = pixels / (_indicatorWidth * 5.0);
        setState(() {
          _valueSelected = result;
          widget.onScrollChanged!(
              double.tryParse(_valueSelected.toStringAsFixed(2)) ?? 0.0);
        });
        return true;
      },
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                    child: Text(
                  textAlign: TextAlign.center,
                  "${_valueSelected.toStringAsFixed(2)} kg",
                  style: GoogleFonts.inter(
                      fontSize: 32.0, fontWeight: FontWeight.w500),
                )),
                Expanded(
                  child: ListView.builder(
                    itemCount: _range * _range,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: _indicatorWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 1.5,
                              height: _heightFromIndex(index),
                              decoration: BoxDecoration(
                                  color: Color(0xFFB5B5B5),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5.0),
                                      topRight: Radius.circular(5.0))),
                            ),
                            const Expanded(child: SizedBox())
                          ],
                        ),
                      );
                    },
                  ),
                ),
                //Button for ex you wanna show it on ShowDialog or else
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: ElevatedButton(
                //       onPressed: () {
                //         widget.onSelected(
                //             double.tryParse(_valueSelected.toStringAsFixed(2)) ??
                //                 0.0);
                //       },
                //       child: const Text("Done")),
                // )
              ],
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.25 - 76.0,
              left: MediaQuery.of(context).size.width * 0.5,
              child: Container(
                width: 3,
                height: MediaQuery.of(context).size.height * 0.16,
                decoration: BoxDecoration(
                  color: MedScribe_Theme.secondary_color,
                  borderRadius: BorderRadius.circular(25),
                ),
              ))
        ],
      ),
    );
  }

  double _heightFromIndex(int index) {
    if (index % 5 == 0) {
      return 80.0;
    }
    // } else if (index % 5 == 0) {
    //   return 25.0;
    // }
    return 40.0;
  }
}
