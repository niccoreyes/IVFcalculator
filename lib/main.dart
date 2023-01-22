import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USTH Hypernatremia IVF calculator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'USTH Hypernatremia IVF calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _sodium = 0;
  int weight = 0;
  double _target = 0.00;
  String _ivfRate = '';
  double sensibleLosses = 0.00;
  double intake = 0.00;

  double totalIVF = 0.00;

  double calculatedFWD = 0.00;

  String sex = 'Male';

  String _selectedOption = "";
  double _ageType = 0.0;

  static List<String> mgStrings = ['⬇️ mg/dL', 'Target mg/dL'];
  var mgdL = mgStrings[0];
  static String fixedPreMg = "🔁 Change"; //↔
  bool mgDLState = true; //default true = decrease by
  var mgDlStateString = "";

  static List<String> insensibleLosses = ["500", "1000"];
  String? selectInsensible = "500";
  double insensibleVal = 500.00;

  var controllerFWD = TextEditingController();
  var controllerTotal = TextEditingController();
  var mgDlController = TextEditingController();

  double d5WvsPush = 0.5;
  String d5WvPushLabel = '1/2';

  @override
  void dispose() {
    //controllerFWD.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: [
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Sodium (mEq/L)',
              ),
              initialValue: _sodium == 0 ? "" : _sodium.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {
                try {
                  _sodium = double.parse(value);
                } catch (e) {
                  _sodium = 0;
                }
                autoCalculate();
              }),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: mgdL,
                    ),
                    controller: mgDlController,
                    //initialValue: mgDlStateString,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        mgDlProcess();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                    onPressed: () {
                      mgDLState = !mgDLState;
                      if (mgDLState) {
                        mgdL = mgStrings[0];
                        if (_target != 0 && _sodium != 0) {
                          mgDlController.text = (_sodium - _target).toString();
                        }
                      } else {
                        mgdL = mgStrings[1];
                        if (_target != 0 && _sodium != 0) {
                          mgDlController.text = (_target).toString();
                        }
                      }
                      setState(() {
                        mgDlProcess();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(fixedPreMg),
                    ))
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 1,
                    child: RadioListTile(
                      value: 'Male',
                      groupValue: sex,
                      title: const Text('Male'),
                      onChanged: (value) => setState(() {
                        sex = "Male";
                        if (_selectedOption == "Child") {
                          _ageType = 0.60;
                        } else if (_selectedOption == "Adult") {
                          _ageType = 0.60;
                        } else if (_selectedOption == "Elderly") {
                          _ageType = 0.50;
                        }
                        autoCalculate();
                      }),
                    )),
                Expanded(
                    flex: 1,
                    child: RadioListTile(
                      value: 'Female',
                      groupValue: sex,
                      title: const Text('Female'),
                      onChanged: (value) => setState(() {
                        sex = "Female";
                        if (_selectedOption == "Child") {
                          _ageType = 0.60;
                        } else if (_selectedOption == "Adult") {
                          _ageType = 0.50;
                        } else if (_selectedOption == "Elderly") {
                          _ageType = 0.45;
                        }
                        autoCalculate();
                      }),
                    ))
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: RadioListTile(
                      value: 'Child',
                      groupValue: _selectedOption,
                      title: const Text('Child'),
                      onChanged: (value) => setState(() {
                            _selectedOption = value!;
                            _ageType = 0.60;
                            autoCalculate();
                          })),
                ),
                Expanded(
                  flex: 1,
                  child: RadioListTile(
                    value: 'Adult',
                    groupValue: _selectedOption,
                    title: const Text('Adult'),
                    onChanged: (value) => setState(() {
                      _selectedOption = value!;
                      if (sex == "Male") {
                        _ageType = 0.60;
                      } else {
                        _ageType = 0.50;
                      }
                      autoCalculate();
                    }),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: RadioListTile(
                    value: 'Elderly',
                    groupValue: _selectedOption,
                    title:
                        const Text('Elderly', style: TextStyle(fontSize: 12.0)),
                    onChanged: (value) => setState(() {
                      _selectedOption = value!;
                      if (sex == "Male") {
                        _ageType = 0.50;
                      } else {
                        _ageType = 0.45;
                      }
                      autoCalculate();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Text(_selectedOption != ""
                ? 'Selected: $_selectedOption ($_ageType) Estimated TBW'
                : 'Select Age : Estimated TBW'),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Weight (kg)',
              ),
              initialValue: weight == 0 ? "" : weight.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {
                try {
                  weight = int.parse(value);
                } catch (e) {
                  weight = 0;
                }
                autoCalculate();
              }),
            ),
            // horizontal line
            const SizedBox(height: 16.0),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(height: 16.0),
            Text(
              (_ivfRate != '')
                  ? 'Free water deficit: $_ivfRate'
                  : 'Free water deficit: 0/0 x Kg x TBW%',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Calculated Free Water Deficit',
                        prefixIcon: Icon(Icons.equalizer)),
                    keyboardType: TextInputType.number,
                    controller: controllerFWD,
                    onChanged: (value) => setState(() {
                      try {
                        calculatedFWD = double.parse(value);
                      } catch (e) {
                        calculatedFWD = 0.00;
                      }
                      totalSum();
                    }),
                  ),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                // ElevatedButton(
                //     onPressed: () => autoCalculate(),
                //     child: const Padding(
                //       padding: EdgeInsets.all(10.0),
                //       child: Text("🔁 Refresh"),
                //     ))
              ],
            ),
            const SizedBox(height: 16.0),
            //urine output
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Urine output (Sensible losses)',
                  prefixIcon: Icon(Icons.add)),
              keyboardType: TextInputType.number,
              initialValue:
                  sensibleLosses == 0 ? "" : sensibleLosses.toString(),
              onChanged: (value) => setState(() {
                try {
                  sensibleLosses = double.parse(value);
                } catch (e) {
                  sensibleLosses = 0.00;
                }
                totalSum();
              }),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.add),
                    labelText: "Insensible Losses",
                    border: OutlineInputBorder()),
                value: selectInsensible,
                items: insensibleLosses
                    .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 16),
                        )))
                    .toList(),
                onChanged: (item) {
                  setState(() {
                    selectInsensible = item;
                    if (selectInsensible != null) {
                      try {
                        insensibleVal = double.parse(selectInsensible!);
                      } catch (e) {}
                      totalSum();
                    }
                  });
                }),
            const SizedBox(height: 16.0),
            //urine output
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Fluid Intake',
                  prefixIcon: Icon(Icons.remove)),
              keyboardType: TextInputType.number,
              initialValue: intake == 0 ? "" : intake.toString(),
              onChanged: (value) {
                setState(() {
                  try {
                    intake = double.parse(value);
                  } catch (e) {
                    intake = 0.00;
                  }
                  totalSum();
                });
              },
            ),
            // horizontal line
            const SizedBox(height: 16.0),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(height: 16.0),
            // Intake
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Total IVF Fluids',
                        prefixIcon: Icon(Icons.data_exploration)),
                    keyboardType: TextInputType.number,
                    controller: controllerTotal,
                    onChanged: (value) => setState(() {
                      try {
                        totalIVF = double.parse(value);
                      } catch (e) {
                        totalIVF = 0.00;
                      }
                    }),
                  ),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                // ElevatedButton(
                //     onPressed: () => autoCalculate(),
                //     child: const Padding(
                //       padding: EdgeInsets.all(10.0),
                //       child: Text("🔁 Refresh"),
                //     ))
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                const Text(
                  "FLUSH",
                  style: TextStyle(fontSize: 20),
                ),
                Expanded(
                  flex: 1,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 28),
                      tickMarkShape:
                          RoundSliderTickMarkShape(tickMarkRadius: 4),
                    ),
                    child: Slider(
                      min: 0,
                      max: 1.0,
                      divisions: 4,
                      value: d5WvsPush,
                      label: d5WvPushLabel,
                      onChanged: (value) {
                        if (value == 0) {
                          d5WvPushLabel = "FLUSH";
                        } else if (value == 0.25) {
                          d5WvPushLabel = "D5W 1/4";
                        } else if (value == 0.5) {
                          d5WvPushLabel = "1/2";
                        } else if (value == 0.75) {
                          d5WvPushLabel = "FLUSH 1/4";
                        } else {
                          d5WvPushLabel = "D5W";
                        }
                        setState(() {
                          d5WvsPush = value;
                        });
                        // Update the value shown in the text field
                      },
                    ),
                  ),
                ),
                const Text(
                  "D5W",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            //_AnimatedLiquidLinearProgressIndicator(),
            Container(
              width: double.infinity,
              height: 35,
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: LiquidLinearProgressIndicator(
                value: d5WvsPush, // Defaults to 0.5.
                valueColor: AlwaysStoppedAnimation(Colors
                    .blue), // Defaults to the current Theme's accentColor.
                backgroundColor: Color.fromARGB(255, 249, 255,
                    254), // Defaults to the current Theme's backgroundColor.
                borderColor: Colors.blue,
                borderWidth: 2.0,
                borderRadius: 12.0,
                direction: Axis
                    .horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                center: Text("Flush ${(d5WvsPush * 100).toStringAsFixed(0)}%",
                    style:
                        const TextStyle(color: Colors.white, shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0.0, 0.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      )
                    ])),
              ),
            ),
            const SizedBox(height: 20),
            // horizontal line
            const SizedBox(height: 16.0),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text(
                    "D5W ➡️ ${(totalIVF * d5WvsPush).toStringAsFixed(0)} / 24 \n= ${(totalIVF * d5WvsPush / 24).toStringAsFixed(0)} cc",
                    style: const TextStyle(fontSize: 20))
              ],
            ),
            // horizontal line
            const SizedBox(height: 16.0),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text(
                  "FLUSHING ➡️ ${(totalIVF * (1 - d5WvsPush)).toStringAsFixed(0)} / 6 \n= ${(totalIVF * (1 - d5WvsPush) / 6).toStringAsFixed(0)} cc",
                  style: const TextStyle(fontSize: 20),
                )
              ],
            ),
            // horizontal line
            const SizedBox(height: 16.0),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 16,
            ),
            // Sidenotes drawing here
            Row(
              children: const [Text("Side Notes:")],
            ),
            const SizedBox(
              height: 5,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text("${_sodium - _target}"),
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 10,
                                  maxWidth: 12,
                                ),
                                height: 1,
                                color: Colors.grey,
                              ),
                              Text("$_sodium")
                            ],
                          ),
                          Text("x $weight x $_ageType = ")
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 30,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(calculatedFWD.toStringAsFixed(0)),
                            ],
                          ),
                        ),
                      ),
                      Text("+ $sensibleLosses"),
                      Text("+ $insensibleVal"),
                      Text("- $intake"),
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          maxWidth: 70,
                        ),
                        height: 1,
                        color: Colors.grey,
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "Total IVF: ${totalIVF.toStringAsFixed(0)}  "),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 25,
                                height: 25,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                    color: Colors.transparent),
                                child: ClipPath(
                                  clipper: VShapeClipper(),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "${(totalIVF * d5WvsPush).toStringAsFixed(0)} / 24 = D5W ${(totalIVF * d5WvsPush / 24).toStringAsFixed(0)} cc"),
                              Text(
                                  "${(totalIVF * (1 - d5WvsPush)).toStringAsFixed(0)} / 6 = FLUSH ${(totalIVF * (1 - d5WvsPush) / 6).toStringAsFixed(0)} cc")
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // horizontal line
            const SizedBox(height: 16.0),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 16,
            ),

            const SizedBox(
              height: 50,
            ),
            const Text(
                "I am grateful to everyone who contributed to making this project possible. Special thanks to Dr. Danielle Lucero for her guidance. I hope this tool will hasten IVF calculation correction for patients in USTH.\n - Thomas Reyes")
          ],
        ),
      ),
    );
  }

  void totalSum() {
    totalIVF = calculatedFWD + sensibleLosses + insensibleVal - intake;
    controllerTotal.text = totalIVF.toStringAsFixed(2);
  }

  void autoCalculate() {
    try {
      _ivfRate = calculateIVFRate(_sodium, weight, _target, _ageType);
    } catch (e) {}
  }

  String calculateIVFRate(
      double sodium, int weight, double target, double ageType) {
    var calculatedDiff = sodium - target;
    var calcuStringFree = "$calculatedDiff/$sodium x $weight x $ageType";
    var calcuResult =
        (((sodium - target) / sodium) * weight.toDouble() * ageType * 1000);
    calculatedFWD = calcuResult; //set global FWD

    if (calcuResult != null && calcuResult != 0 && !calcuResult.isNaN) {
      controllerFWD.text = calculatedFWD.toStringAsFixed(2);
      //calcuStringFree += "\nCalculated FWD= ${calcuResult.toStringAsFixed(2)}";
    }

    // Calculate IVF rate here using the provided sodium, age, and target values
    // This is just a sample function and the actual calculation will depend on your specific requirements
    return calcuStringFree;
  }

  void mgDlProcess() {
    try {
      if (mgDLState) {
        _target = _sodium - double.parse(mgDlController.text);
      } else if (!mgDLState) {
        _target = double.parse(mgDlController.text);
      }
    } catch (e) {
      _target = 0;
    }
    mgDlStateString = mgDlController.text;
    autoCalculate();
  }
}

class VShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var thic = 2.0;
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(thic * 2, size.height / 2);
    path.lineTo(size.width, 0);
    path.close();
    // var matrix4 = Matrix4.rotationZ(1 * math.pi / 180);
    // path = path.transform(matrix4.storage);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(getClip(size), paint);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// class _AnimatedLiquidLinearProgressIndicator extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() =>
//       _AnimatedLiquidLinearProgressIndicatorState();
// }

// class _AnimatedLiquidLinearProgressIndicatorState
//     extends State<_AnimatedLiquidLinearProgressIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1),
//     );

//     _animationController.addListener(() => setState(() {}));
//     _animationController.repeat();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final percentage = _animationController.value * 100;
//     return Center(
//       child: Container(
//         width: double.infinity,
//         height: 75.0,
//         padding: EdgeInsets.symmetric(horizontal: 24.0),
//         child: LiquidLinearProgressIndicator(
//           value: _animationController.value,
//           backgroundColor: Colors.white,
//           valueColor: AlwaysStoppedAnimation(Colors.blue),
//           borderRadius: 12.0,
//           center: Text(
//             "${percentage.toStringAsFixed(0)}%",
//             style: TextStyle(
//               color: Colors.lightBlueAccent,
//               fontSize: 20.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
