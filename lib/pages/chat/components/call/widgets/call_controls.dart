import 'dart:async';

import 'package:chat_interface/controller/chat/conversation/call/microphone_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/output_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallControls extends StatefulWidget {
  const CallControls({super.key});

  @override
  State<CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<CallControls> {

  final _audioInputs = <MediaDevice>[].obs;
  final _audioOutputs = <MediaDevice>[].obs;

  StreamSubscription<dynamic>? subscription;

  @override
  void initState() {
    super.initState();

    /*
    subscription = Hardware.instance.onDeviceChange.stream.listen((event) {
      _updateDevices(event);
    });
    Hardware.instance.enumerateDevices().then((value) => _updateDevices(value)); */
  }

  void _updateDevices(List<MediaDevice> devices) {
    _audioInputs.clear();
    _audioInputs.addAll(devices.where((element) => element.kind == "audioinput").toList());

    _audioOutputs.clear();
    _audioOutputs.addAll(devices.where((element) => element.kind == "audiooutput").toList());
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing * 0.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GetX<MicrophoneController>(
              builder: (controller) {
                return LoadingIconButton(
                  loading: controller.microphoneLoading,
                  onTap: () => controller.setMicrophone(!controller.microphone.value),
                  icon: controller.microphone.value ? Icons.mic : Icons.mic_off,
                  iconSize: 35,
                  color: theme.colorScheme.primary
                ); 
              },
            ),
            horizontalSpacing(defaultSpacing * 0.5),
            GetX<PublicationController>(
              builder: (controller) {
                return LoadingIconButton(
                  loading: controller.outputLoading,
                  onTap: () => controller.setOutput(!controller.output.value),
                  icon: controller.output.value ? Icons.volume_up : Icons.volume_off,
                  iconSize: 35,
                  color: theme.colorScheme.primary
                ); 
              },
            ),
            horizontalSpacing(defaultSpacing * 0.5),
            LoadingIconButton(
              loading: false.obs,
              onTap: () {},
              icon: Icons.close,
              color: Colors.red.shade400,
              iconSize: 35,
            )
          ],
        ),
      ),
    );
  }
}