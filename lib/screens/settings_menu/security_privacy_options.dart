import 'package:flutter_switch/flutter_switch.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';

class PrivacyOptions extends StatefulWidget {
  const PrivacyOptions({Key? key}) : super(key: key);

  @override
  State<PrivacyOptions> createState() => _PrivacyOptionsState();
}

class _PrivacyOptionsState extends State<PrivacyOptions> {
  final SettingsController settingsController = Get.find();

  @override
  void initState() {
    settingsController.loadSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: privacyString.tr),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                Column(
                  children: [
                    // shareLocationTile(),
                    bioMetricLoginTile(),
                  ],
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  shareLocationTile() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Row(children: [
            Expanded(
              child: BodyLargeText(shareLocationString.tr,
                  weight: TextWeight.medium),
            ),
            // const Spacer(),
            Obx(() => FlutterSwitch(
                  inactiveColor: AppColorConstants.disabledColor,
                  activeColor: AppColorConstants.themeColor,
                  width: 50.0,
                  height: 30.0,
                  valueFontSize: 15.0,
                  toggleSize: 20.0,
                  value: settingsController.shareLocation.value,
                  borderRadius: 30.0,
                  padding: 8.0,
                  // showOnOff: true,
                  onToggle: (val) {
                    settingsController.shareLocationToggle(val);
                  },
                )),
          ]).hp(DesignConstants.horizontalPadding),
        ),
        divider()
      ],
    );
  }

  bioMetricLoginTile() {
    return Obx(() => settingsController.bioMetricType.value == 0
        ? Container()
        : Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BodyLargeText(faceIdOrTouchIdString.tr,
                                weight: TextWeight.medium)
                            .bP4,
                        BodySmallText(
                          unlockYourAppUsingBiometricLoginString.tr,
                        ),
                      ],
                    ),
                  ),
                  // const Spacer(),
                  FlutterSwitch(
                    inactiveColor: AppColorConstants.disabledColor,
                    activeColor: AppColorConstants.themeColor,
                    width: 50.0,
                    height: 30.0,
                    valueFontSize: 15.0,
                    toggleSize: 20.0,
                    value: settingsController.bioMetricAuthStatus.value,
                    borderRadius: 30.0,
                    padding: 8.0,
                    // showOnOff: true,
                    onToggle: (value) {
                      settingsController.biometricLogin(value);
                    },
                  ),
                ]).hp(DesignConstants.horizontalPadding),
              ),
              divider()
            ],
          ));
  }
}
