// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/constant.dart';

class SearchLocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
  final GeoPoint? geoLoc;
  const SearchLocationPage({this.geoLoc});
}

class _SearchPageState extends State<SearchLocationPage> {
  late TextEditingController textEditingController = TextEditingController();
  late PickerMapController controller;
  final FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    searchFocus.addListener(() {
      if (searchFocus.hasFocus) {
        dataBloc.homeKey.currentState
            ?.changeResizeToAvoidBottomInset(value: false);
      }
    });
    super.initState();
    controller = PickerMapController(
        initMapWithUserPosition: widget.geoLoc == null,
        initPosition: widget.geoLoc);
    textEditingController.addListener(textOnChanged);
  }

  void textOnChanged() {
    controller.setSearchableText(textEditingController.text);
  }

  @override
  void dispose() {
    searchFocus.dispose();
    textEditingController.removeListener(textOnChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey.currentState?.changeResizeToAvoidBottomInset();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar(context, 'Seleccionar localización',
            elevation: false, image: 'assets/images/checklist.png', onPop: () {
          dataBloc.homeKey.currentState?.changeResizeToAvoidBottomInset();
          Navigator.pop(context);
        }),
        body: _locationPicker(context, size),
      ),
    );
  }

  Widget _locationPicker(BuildContext context, Size size) {
    return CustomPickerLocation(
      controller: controller,
      appBarPicker: _searchField(context),
      topWidgetPicker: TopSearchWidget(),
      bottomWidgetPicker: Positioned(
        bottom: 12,
        // right: 12,
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  _zoomIn().paddingBottom(8),
                  _zoomOut(),
                ],
              ),
              Column(
                children: [
                  _goToUserLocation().paddingBottom(8),
                  _returnCurrentLocation(context),
                ],
              ),
            ],
          ),
        ),
      ),
      pickerConfig: CustomPickerLocationConfig(
        minZoomLevel: 6,
        // loadingWidget: Center(
        //   child: Loader(),
        // ),
        initZoom: 17,
      ),
    );
  }

  Widget _returnCurrentLocation(BuildContext context) {
    return AppButton(
      width: 30,
      // height: 30,
      padding: kButtonPadding,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(color: greyMediumLight)),
      onTap: () async {
        GeoPoint p = await controller.selectAdvancedPositionPicker();
        Navigator.pop(context, p);
      },
      child: Icon(
        Icons.check_rounded,
        size: kIconSize + 13,
        color: pColor,
      ),
    );
  }

  Widget _zoomIn() {
    return AppButton(
      width: 30,
      // height: 30,
      padding: kButtonPadding,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(color: greyMediumLight)),
      onTap: () async {
        controller.osmBaseController.zoomIn();
      },
      child: Icon(
        Icons.add,
        size: kIconSize + 13,
        color: pColor,
      ),
    );
  }

  Widget _zoomOut() {
    return AppButton(
      width: 30,
      // height: 30,
      padding: kButtonPadding,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(color: greyMediumLight)),
      onTap: () async {
        controller.osmBaseController.zoomOut();
      },
      child: Icon(
        Icons.remove,
        size: kIconSize + 13,
        color: pColor,
      ),
    );
  }

  Widget _goToUserLocation() {
    return AppButton(
      width: 30,
      // height: 30,
      padding: kButtonPadding,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(color: greyMediumLight)),
      onTap: () async {
        // await controller. ();

        if (customerBloc.getLocation != null) {
          // await controller.osmBaseController.enableTracking();

          await controller.osmBaseController.currentLocation();
          await controller.osmBaseController
              .initMap(initWithUserPosition: true);

          // await controller.osmBaseController.enableTracking();
        } else {
          await controller.osmBaseController.currentLocation();
          await controller.osmBaseController.enableTracking();

          // await controller.osmBaseController.enableTracking();
        }
        await controller.advancedPositionPicker();
      },
      child: Icon(
        Icons.my_location,
        size: kIconSize + 13,
        color: pColor,
      ),
    );
  }

  AppBar _searchField(BuildContext context) {
    return AppBar(
      toolbarHeight: 63,
      automaticallyImplyLeading: false,
      excludeHeaderSemantics: true,
      titleSpacing: 8,
      // centerTitle: ,

      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: greyLight),
        child: AppTextField(
          focus: searchFocus,
          controller: textEditingController,
          textStyle: buttonsSmallTextStyle(context),
          textFieldType: TextFieldType.NAME,
          decoration: InputDecoration(
            suffixIcon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            suffix: ValueListenableBuilder<TextEditingValue>(
              valueListenable: textEditingController,
              builder: (ctx, text, child) {
                if (text.text.isNotEmpty) {
                  return child!;
                }
                return SizedBox.shrink();
              },
              child: InkWell(
                focusNode: FocusNode(),
                onTap: () {
                  textEditingController.clear();
                  controller.setSearchableText("");
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
            focusColor: Colors.black,
            filled: true,
            hintText: "Buscar",
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            fillColor: greyLight,
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class TopSearchWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TopSearchWidgetState();
}

class _TopSearchWidgetState extends State<TopSearchWidget> {
  late PickerMapController controller;
  ValueNotifier<GeoPoint?> notifierGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> notifierAutoCompletion = ValueNotifier(false);

  late StreamController<List<SearchInfo>> streamSuggestion = StreamController();
  late Future<List<SearchInfo>> _futureSuggestionAddress;
  String oldText = "";
  Timer? _timerToStartSuggestionReq;
  final Key streamKey = Key("streamAddressSug");

  @override
  void initState() {
    super.initState();
    controller = CustomPickerLocation.of(context);
    controller.searchableText.addListener(onSearchableTextChanged);
  }

  void onSearchableTextChanged() async {
    final v = controller.searchableText.value;
    if (v.length > 3 && oldText != v) {
      oldText = v;
      if (_timerToStartSuggestionReq != null &&
          _timerToStartSuggestionReq!.isActive) {
        _timerToStartSuggestionReq!.cancel();
      }
      _timerToStartSuggestionReq =
          Timer.periodic(Duration(seconds: 3), (timer) async {
        await suggestionProcessing(v);
        timer.cancel();
      });
    }
    if (v.isEmpty) {
      await reInitStream();
    }
  }

  Future reInitStream() async {
    notifierAutoCompletion.value = false;
    await streamSuggestion.close();
    setState(() {
      streamSuggestion = StreamController();
    });
  }

  Future<void> suggestionProcessing(String addr) async {
    notifierAutoCompletion.value = true;
    _futureSuggestionAddress = addressSuggestion(
      addr,
      limitInformation: 5,
    );
    _futureSuggestionAddress.then((value) {
      streamSuggestion.sink.add(value);
    });
  }

  @override
  void dispose() {
    controller.searchableText.removeListener(onSearchableTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifierAutoCompletion,
      builder: (ctx, isVisible, child) {
        return AnimatedContainer(
          duration: Duration(
            milliseconds: 500,
          ),
          height: isVisible ? MediaQuery.of(context).size.height / 4 : 0,
          child: Card(
            child: child!,
          ),
        );
      },
      child: StreamBuilder<List<SearchInfo>>(
        stream: streamSuggestion.stream,
        key: streamKey,
        builder: (ctx, snap) {
          if (snap.hasData) {
            return ListView.builder(
              itemExtent: 50.0,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(
                    snap.data![index].address.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  onTap: () async {
                    /// go to location selected by address
                    controller.goToLocation(
                      snap.data![index].point!,
                    );
                    controller.osmBaseController.setZoom(zoomLevel: 14);

                    /// hide suggestion card
                    notifierAutoCompletion.value = false;
                    await reInitStream();
                    FocusScope.of(context).requestFocus(
                      FocusNode(),
                    );
                  },
                );
              },
              itemCount: snap.data!.length,
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return Card(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
