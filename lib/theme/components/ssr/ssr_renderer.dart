import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/ssr/ssr.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SSRRenderer extends StatefulWidget {
  final SSR ssr;
  final String path;
  final List<dynamic> json;

  const SSRRenderer({
    super.key,
    required this.ssr,
    required this.json,
    required this.path,
  });

  @override
  State<SSRRenderer> createState() => _SSRRendererState();
}

class _SSRRendererState extends State<SSRRenderer> {
  final loading = false.obs;
  var widgets = <Widget>[];

  @override
  void initState() {
    widgets = List.generate(widget.json.length, (index) {
      final last = index == widget.json.length - 1;
      final element = widget.json[index];
      switch (element["type"]) {
        case "text":
          return _renderText(element, last);
        case "input":
          return _renderInput(element, last);
        case "button":
          return _renderSubmitButton(element, last);
      }

      return _renderError(element["type"], last);
    });

    super.initState();
  }

  /// Render a text element from the element json
  Widget _renderText(Map<String, dynamic> json, bool last) {
    switch (json["style"]) {
      case 0:
        return Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : sectionSpacing),
          child: Text(
            json["text"],
            style: Get.textTheme.headlineMedium,
          ),
        );
      case 1:
        return Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
          child: Text(
            json["text"],
            style: Get.textTheme.labelMedium,
          ),
        );
      case 2:
        return Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
          child: Text(
            json["text"],
            style: Get.textTheme.bodyMedium,
          ),
        );
    }

    return _renderError("text-style-${json["style"]}", last);
  }

  /// Render an input field from the element json
  Widget _renderInput(Map<String, dynamic> json, bool last) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: last ? 0 : defaultSpacing,
      ),
      child: FJTextField(
        obscureText: json["hidden"],
        hintText: json["placeholder"],
        onChange: (value) {
          widget.ssr.currentInputValues[json["name"]] = value;
        },
      ),
    );
  }

  /// Render a submit button from the element json
  Widget _renderSubmitButton(Map<String, dynamic> json, bool last) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: last ? 0 : defaultSpacing,
      ),
      child: Column(
        children: [
          AnimatedErrorContainer(
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            message: widget.ssr.error,
          ),
          _renderButton(json, last),
          Obx(
            () => Animate(
              effects: [
                ExpandEffect(
                  duration: 250.ms,
                  axis: Axis.vertical,
                  alignment: Alignment.bottomCenter,
                )
              ],
              target: widget.ssr.error.value == "" ? 0 : 1,
              child: widget.ssr.suggestButton != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: defaultSpacing),
                      child: _renderButton(widget.ssr.suggestButton!, true),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  /// Render a normal button using json (NOT A NORMAL ELEMENT)
  Widget _renderButton(Map<String, dynamic> json, bool last) {
    return FJElevatedLoadingButton(
      onTap: () async {
        widget.ssr.error.value = "";
        loading.value = true;
        widget.ssr.error.value = await widget.ssr.next(json["path"]) ?? "";
        loading.value = false;
      },
      label: json["label"],
      loading: loading,
    );
  }

  /// Render an error
  Widget _renderError(String type, bool last) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : defaultSpacing),
      child: ErrorContainer(
        message: "render.error".trParams({
          "type": type,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
