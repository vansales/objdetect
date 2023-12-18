import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFlite();
  }

  @override
  void dispose() {
    super.dispose();
    releaseTFlite();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  var x, y, w, h = 0.0;
  var label = "";

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      print("Permission denied");
    }
  }

  initTFlite() async {
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  releaseTFlite() async {
    await Tflite.close();
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        model: "SSDMobileNet",
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );

    if (detector != null && detector.isNotEmpty) {
      log("Result is $detector");
      // log(detector.first["label"]);
      // log(detector.first["confidence"].toString());

      if (detector.first["confidenceInClass"] * 100 > 45) {
        label = detector.first["detectedClass"].toString();
        h = detector.first['rect']['h'];
        w = detector.first['rect']['w'];
        x = detector.first['rect']['x'];
        y = detector.first['rect']['y'];
        // h = 0.0;
        // w = 0.0;
        // x = 0.0;
        // y = 0.0;
      }
      update();
    }
  }
}
