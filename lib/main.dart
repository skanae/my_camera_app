import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // main 関数内で非同期処理を呼び出すための設定
  WidgetsFlutterBinding.ensureInitialized();
  // デバイスで使用可能なカメラのリストを取得
  final cameras = await availableCameras();
  // 利用可能なカメラのリストから特定のカメラを取得
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Example',
      theme: ThemeData(),
      home: TakePictureScreen(camera: camera),
    );
  }
}

/// 写真撮影画面
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      // カメラを指定
      widget.camera,
      // 解像度を定義
      ResolutionPreset.max,
      // 1080p (1920x1080) 2160p (3840x2160)
    );

    // コントローラーを初期化
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // ウィジェットが破棄されたら、コントローラーを破棄
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _deviceWidth = MediaQuery.of(context).size.width;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth_adjust = (MediaQuery.of(context).size.width * 16) / 9;

    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(children: [
                CameraPreview(_controller),
                Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 0,
                    ),
                    Text("_deviceWidth:" + _deviceWidth.toString()), //360
                    Text(
                        "_deviceHeight:" + _deviceHeight.toString()), //716.6666
                    Text("_deviceWidth_adjust:" +
                        _deviceWidth_adjust.toString()), //640
                  ],
                ),
                Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Divider(
                      color: Colors.blue,
                      thickness: 3,
                      height: _deviceWidth,
                      // indent: 20,
                      // endIndent: 20,
                    ),
                    Divider(
                        color: Colors.blue,
                        thickness: 3,
                        height: _deviceWidth * 2
                        // indent: 20,
                        // endIndent: 20,
                        ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Divider(
                      color: Colors.red,
                      thickness: 3,
                      // height: _deviceWidth,
                      // indent: 20,
                      // endIndent: 20,
                    ),
                    Divider(
                      color: Colors.red,
                      thickness: 3,
                      // height: (_deviceWidth * 1.5),
                      // indent: 20,
                      // endIndent: 20,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    VerticalDivider(
                      color: Colors.red,
                      thickness: 3,
                      // width: _deviceWidth / 3,
                      // indent: 20,
                      // endIndent: 20,
                    ),
                    VerticalDivider(
                      color: Colors.red,
                      thickness: 3,
                      // width: (_deviceWidth * 2) / 3,
                      // indent: 20,
                      // endIndent: 20,
                    ),
                  ],
                )
              ]);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 写真を撮る
          final image = await _controller.takePicture();
          // 表示用の画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayPictureScreen(imagePath: image.path),
              fullscreenDialog: true,
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// 撮影した写真を表示する画面
class DisplayPictureScreen extends StatelessWidget {
  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('撮れた写真')),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
