import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimal/device_data.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'labels/labels.dart';
import 'pages/pages.dart';

class ResponsiveAnimation extends StatefulWidget {
  ResponsiveAnimation({Key key}) : super(key: key);

  @override
  _ResponsiveAnimationState createState() => _ResponsiveAnimationState();
}

class _ResponsiveAnimationState extends State<ResponsiveAnimation> {
  double startValue = 1920;
  double endValue = 1920;
  bool animating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double verticalPadding = 100;
    double horizontalPadding = 100;
    return Stack(
      children: <Widget>[
        Container(color: Colors.white),
        Container(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 720, end: 2560),
            duration: Duration(seconds: 4),
            onEnd: () => animating = false,
            builder: (BuildContext context, value, Widget child) {
              return DeviceContainer(
                deviceData: DeviceData(
                    brand: "SCALE",
                    model: "${value.round()} x 1280",
                    width: value,
                    height: 1280,
                    physicalSize: 6.4,
                    devicePixelRatio: 1),
                heightPadding: verticalPadding,
                widthPadding: horizontalPadding,
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () => playAnimation(),
                icon: animating
                    ? Icon(null, color: Color(0xFFDFDFDF))
                    : Icon(Icons.play_circle_outline, color: Color(0xFFDFDFDF)),
                iconSize: 48,
              ),
              IconButton(
                onPressed: () => resetAnimation(),
                icon: animating
                    ? Icon(null, color: Color(0xFFDFDFDF))
                    : Icon(Icons.replay, color: Color(0xFFDFDFDF)),
                iconSize: 48,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void playAnimation() {
    setState(() {
      animating = true;
      startValue = 1920;
      endValue = 320;
    });
  }

  void resetAnimation() {
    setState(() {
      animating = false;
      startValue = 1920;
      endValue = 1920;
    });
  }
}

class DeviceContainer extends StatelessWidget {
  final DeviceData deviceData;
  final double widthPadding;
  final double heightPadding;

  const DeviceContainer({
    Key key,
    @required this.deviceData,
    this.widthPadding = 0,
    this.heightPadding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double deviceContainerHeight = screenHeight - (heightPadding * 2);
    double deviceContainerWidth = screenWidth - (widthPadding * 2);
    Size containerSize = Size(deviceContainerWidth, deviceContainerHeight);

    Size deviceScreenSize = deviceScreenSizeCalc(
        aspectRatio: deviceData.aspectRatio,
        containerWidth: deviceContainerWidth,
        containerHeight: deviceContainerHeight);

    print("Screen Dimensions: $screenWidth , $screenHeight");
    print("Device Size: $deviceScreenSize");

    LabelFactory labelFactory = LabelFactory(
        type: LabelType.SIMPLE_TOP_CENTER,
        title: deviceData.brand,
        subtitle: deviceData.model,
        deviceSize: deviceScreenSize,
        containerSize: containerSize);

    // Center container
    // TODO: Create centering methods.
    double centerVerticalOffset = 0;
    if (true) {
      centerVerticalOffset =
          deviceContainerHeight / 2 - labelFactory.containerRect.center.dy;
    }

    double previewScale =
        deviceData.scaledSize.width / labelFactory.deviceSize.width;

    return Center(
      child: Container(
        width: labelFactory.containerRect.width +
            labelFactory.containerRect.topLeft.dx,
        height: labelFactory.containerRect.height +
            labelFactory.containerRect.topLeft.dy,
        margin: EdgeInsets.only(
            top: heightPadding * 0.5,
            bottom: heightPadding * 1.5,
            left: widthPadding * 0.5,
            right: widthPadding *
                0.5), // TODO: Move padding to deviceResizeCalc. This allows the device to exceed to not be cropped when out of screen.
        child: Stack(
          children: <Widget>[
            Positioned.fromRect(
                rect: labelFactory.labelRect,
                child: labelFactory.label as Widget),
            Positioned.fromRect(
              rect: labelFactory.deviceRect,
              child: Container(
                width: labelFactory.deviceSize.width,
                height: labelFactory.deviceSize.height,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: kIsWeb
                          ? Color.fromARGB(72, 178, 178, 178)
                          : Color.fromARGB(156, 178, 178, 178),
                      blurRadius: kIsWeb ? 40 : 60,
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: Material(
                  elevation: 8,
                  shadowColor: kIsWeb
                      ? Color.fromARGB(156, 178, 178, 178)
                      : Color.fromARGB(10, 178, 178, 178),
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: MediaQuery(
                      data: MediaQueryData(
                          size: labelFactory.deviceSize * previewScale,
                          devicePixelRatio: deviceData.devicePixelRatio),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Container(
                          width: labelFactory.deviceSize.width * previewScale,
                          height: labelFactory.deviceSize.height * previewScale,
                          child: ResponsiveWrapper(
                            maxWidth: 1200,
                            minWidth: 450,
                            defaultScale: true,
                            breakpoints: [
                              ResponsiveBreakpoint(
                                  breakpoint: 450, name: MOBILE),
                              ResponsiveBreakpoint(
                                  breakpoint: 800, name: TABLET, scale: true),
                              ResponsiveBreakpoint(
                                  breakpoint: 1000, name: TABLET, scale: true),
                              ResponsiveBreakpoint(
                                  breakpoint: 1200, name: DESKTOP),
                              ResponsiveBreakpoint(
                                  breakpoint: 2460, name: "4K", scale: true),
                            ],
                            background: Container(
                              color: Color(0xFFF5F5F5),
                            ),
                            child: BouncingScrollWrapper.builder(
                                context, ListPage()),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Size deviceScreenSizeCalc(
      {double aspectRatio, double containerWidth, double containerHeight}) {
    return aspectRatio >= 1
        ? Size(containerWidth, containerWidth / aspectRatio)
        : Size(containerHeight * aspectRatio, containerHeight);
  }
}
