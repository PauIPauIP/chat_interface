import 'package:chat_interface/pages/spaces/tabletop/tabletop_painter.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class TabletopView extends StatefulWidget {
  const TabletopView({super.key});

  @override
  State<TabletopView> createState() => _TabletopViewState();
}

class _TabletopViewState extends State<TabletopView> {
  final mousePos = const Offset(0, 0).obs;
  final offset = const Offset(0, 0).obs;
  final scale = 1.0.obs;
  final rotation = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerHover: (event) {
              sendLog("move");
              mousePos.value = (event.localPosition / scale.value) - offset.value;
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                final scrollDelta = event.scrollDelta.dy / 500 * -1;
                if (scale.value + scrollDelta < 0.5) {
                  return;
                }
                if (scale.value + scrollDelta > 2) return;

                final zoomFactor = (scale.value + scrollDelta) / scale.value;
                final focalPoint = (event.localPosition / scale.value) - offset.value;
                final newFocalPoint = (event.localPosition / (scale.value + scrollDelta)) - offset.value;

                offset.value -= focalPoint - newFocalPoint;
                scale.value *= zoomFactor;
                mousePos.value = (event.localPosition / scale.value) - offset.value;
              }
            },
            child: GestureDetector(
              onPanDown: (details) {},
              onPanUpdate: (details) {
                offset.value += details.delta * (1 / scale.value);
              },
              onPanEnd: (details) {},
              child: SizedBox.expand(
                child: ClipRRect(
                  child: Obx(
                    () {
                      return CustomPaint(
                        painter: TabletopPainter(
                          mousePosition: mousePos.value,
                          offset: offset.value,
                          scale: scale.value,
                          rotation: rotation.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              color: Colors.white,
              width: 200,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Slider(
                    value: rotation.value,
                    onChanged: (value) => rotation.value = value,
                    min: 0,
                    max: 2 * math.pi,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
