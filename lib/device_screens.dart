import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:minimal/device_data.dart';

class ResponsivePreview extends StatefulWidget {
  ResponsivePreview({Key key}) : super(key: key);

  @override
  _ResponsivePreviewState createState() => _ResponsivePreviewState();
}

class _ResponsivePreviewState extends State<ResponsivePreview> {
  ScrollController scrollController;
  DeviceDataRepository deviceDataRepository;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    deviceDataRepository = DeviceDataRepository(deviceDataJson);
//    deviceDataRepository.addAllWithBrand("iPhone");
//    print(
//        "Active Devices: ${deviceDataRepository.activeDeviceDatas.map((e) => e.toJson().toString()).toString()}");
  }

  // TODO: Set horizontal and vertical padding.
  // Horizontal padding controls preview horizontal spacing. Control in ListView.

  @override
  Widget build(BuildContext context) {
    double verticalPadding = 50;
    return ListView.builder(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 100),
      itemBuilder: (context, index) {
        DeviceData deviceData = deviceDataRepository.activeDeviceDatas[index];
        return Container(
            child: DeviceContainer(
              deviceData: deviceData,
              heightPadding: verticalPadding,
            ),
            margin:
                (index != (deviceDataRepository.activeDeviceDatas.length - 1))
                    ? EdgeInsets.only(right: 50)
                    : null);
      },
      itemCount: deviceDataRepository.activeDeviceDatas.length,
    );
  }
}

class DeviceContainer extends StatelessWidget {
  final DeviceData deviceData;
  final double heightPadding;

  const DeviceContainer({
    Key key,
    @required this.deviceData,
    this.heightPadding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Height available for device container.
    // Screen height minus height padding.
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double deviceContainerHeight = screenHeight - (heightPadding * 2);
    print("Device Container Height: $deviceContainerHeight");
    double marginTop = 400;
    // Constrain the maximum width within a range
    // calculated from the device width and height.
    // If the width of the screen is too narrow
    // (i.e. on a phone), the preview width is allowed
    // to exceed the width of the phone.
    // A maximum width aspect ratio limit is set to
    // fit a reasonable portion of wide displays in the
    // preview area.
    Map<String, double> deviceResizeCalc = deviceScreenSizeCalc(
        maxWidthRatio: 1,
        boundaryWidthRatio: 1 / 2,
        minHeightPercentage: 2 /
            3, // TODO Automatically calculate this value from screen aspect ratio. This percentage helps control how much of the preview fits on the device screen.
        aspectRatio: deviceData.aspectRatio,
        containerHeight: deviceContainerHeight);
    double deviceScreenWidth = deviceResizeCalc["width"];
    double deviceScreenHeight = deviceResizeCalc["height"];
    // TODO Add label construct to give container enough room for label.
    return Container(
      width: deviceResizeCalc["width"] +
          400, // TODO Calculate device positions for text positioning.
      height: deviceContainerHeight,
      margin: EdgeInsets.symmetric(
          vertical:
              heightPadding), // TODO Move padding to deviceResizeCalc. Why?
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: marginTop - 80,
            width: deviceScreenWidth + 200,
            child: Align(
              alignment: FractionalOffset(0, 0.3),
              child: AutoSizeText(
                deviceData.model ?? "",
                maxLines: 1,
                maxFontSize: 400,
                minFontSize: 0,
                style: TextStyle(
                    fontSize: 400,
                    color: Color(0xFFDFDFDF),
                    height: 0.9,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat"),
              ),
            ),
          ),
          if (deviceData.model?.isEmpty ?? true)
            SizedBox(
              height: marginTop - 80,
              width: deviceScreenWidth + 200,
              child: Align(
                alignment: FractionalOffset(0, 0.3),
                child: AutoSizeText(
                  deviceData.brand ?? "",
                  maxLines: 1,
                  maxFontSize: 400,
                  minFontSize: 0,
                  style: TextStyle(
                      fontSize: 400,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat"),
                ),
              ),
            ),
          if ((deviceData.model?.isEmpty ?? true) == false)
            Container(
              margin: EdgeInsets.only(left: 70),
              child: SizedBox(
                height: marginTop,
                width: deviceScreenWidth - 50,
                child: Align(
                  alignment: FractionalOffset(0, 0.4),
                  child: AutoSizeText(
                    deviceData.brand ?? "",
                    maxLines: 1,
                    maxFontSize: 400,
                    minFontSize: 0,
                    wrapWords: false,
                    style: TextStyle(
                        fontSize: 400,
                        color: Color(0xFF757575),
                        height: 0.9,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat"),
                  ),
                ),
              ),
            ),
          Center(
            child: Container(
              width: deviceScreenWidth,
              height: deviceScreenHeight,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(72, 178, 178, 178),
                    blurRadius: 40,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Material(
                elevation: 8,
                shadowColor: Color.fromARGB(156, 178, 178, 178),
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    "assets/images/paper_flower_overhead_bw_w1080.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate the dimensions for the preview area
  /// and device size.
  ///
  /// Calculate the appropriate dimensions by working
  /// backwards from device size constraints.
  /// The purpose of setting device size constraints
  /// is to fit device preview on the preview screen
  /// in a way the user expects.
  ///
  /// The [maxWidthRatio], [boundaryWidthRatio],
  /// and [minHeightPercentage] approximate a
  /// solver function to maximize the device preview
  /// size and fit the maximum portion of the device
  /// on the preview screen. When the [aspectRatio]
  /// of the device preview exceeds the [boundaryWidthRatio],
  /// the device height begins to shrink, up to the
  /// [minHeightPercentage].
  ///
  /// After the device preview [Size] is determined,
  /// calculate the container [Size].
  ///
  /// Returns a device preview [Size] and container [Size]
  /// that can be used to position the device preview
  /// and additional elements within the device preview.
  Map<String, double> deviceScreenSizeCalc(
      {double maxWidthRatio,
      double boundaryWidthRatio,
      double minHeightPercentage,
      double aspectRatio,
      double containerHeight}) {
    // TODO: Add asserts to force correct inputs for calculations.
    if (aspectRatio > maxWidthRatio)
      return {
        "width": containerHeight * minHeightPercentage * aspectRatio,
        "height": containerHeight * minHeightPercentage
      };

    if (aspectRatio > boundaryWidthRatio) {
      double heightPercentageCalc =
          1 - (aspectRatio - boundaryWidthRatio) * (1 - minHeightPercentage);
      return {
        "width": containerHeight * heightPercentageCalc * aspectRatio,
        "height": containerHeight * heightPercentageCalc
      };
    }

    return {"width": containerHeight * aspectRatio, "height": containerHeight};
  }
}
