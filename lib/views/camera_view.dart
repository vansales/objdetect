import 'package:objdetect/controller/scan_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<ScanController>(
      init: ScanController(),
      builder: (controller) {
        return controller.isCameraInitialized.value
            ? Stack(
                children: [
                  CameraPreview(controller.cameraController),
                  Positioned(
                    top: controller.y != null ? controller.y * 650 : 100,
                    right: controller.x != null ? controller.x * 550 : 100,
                    // top: 100,
                    // right: 100,
                    child: Container(
                      width: controller.w != null
                          ? (controller.w * 100 * context.width / 100)
                          : 100,
                      height: controller.h != null
                          ? (controller.h * 100 * context.height / 100)
                          : 200,
                      // width: 200,
                      // height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green, width: 4.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white.withOpacity(0.5),
                            child: Text(controller.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const Center(child: Text("Loating Preview..."));
      },
    ));
  }
}
