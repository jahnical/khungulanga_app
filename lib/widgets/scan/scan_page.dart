import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khungulanga_app/blocs/home_navigation_bloc/home_navigation_bloc.dart';
import 'extra_info_page.dart';

/// The description of the camera being used.
CameraDescription? camera;

/// A page for scanning using the camera.
class ScanPage extends StatefulWidget {
  /// A callback function to capture an image.
  var captureCall = () async {};

  /// Constructs a ScanPage.
  ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

/// The state for the ScanPage.
class _ScanPageState extends State<ScanPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late double _zoomLevel;
  double _maxZoomLevel = 5.0;
  bool _flashOn = false;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    widget.captureCall = captureImage;
  }

  /// Initializes the camera.
  Future<void> _initializeCamera() async {
    _controller = CameraController(camera!, ResolutionPreset.high);
    _zoomLevel = 1.0;
    _initializeControllerFuture = _controller.initialize();
    _cameraInitialized = true;
    _controller.setFlashMode(FlashMode.off);
    _controller.setFocusMode(FocusMode.auto);
    _maxZoomLevel = await _controller.getMaxZoomLevel();
  }

  /// Captures an image using the camera.
  Future<Null> captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      _navigateToExtraInfo(image);
    } catch (e) {
      // Error handling
    }
  }

  @override
  void dispose() {
    _controller.setFlashMode(FlashMode.off);
    _controller.dispose();
    super.dispose();
  }

  /// Toggles the flash mode of the camera.
  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
      _controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  /// Picks an image from the device's gallery.
  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        final pickedImage0 = XFile(pickedImage.path);
        _navigateToExtraInfo(pickedImage0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraInitialized) {
      return Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Failed to initialize camera'),
                );
              } else {
                return Stack(
                  children: [
                  Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: CameraPreview(
                    _controller,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.previewSize!.height,
                        height: _controller.value.previewSize!.width,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Container(),
                        ),
                      ),
                    ),
                  )),
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _toggleFlash,
                          icon: Icon(
                            _flashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove, color: Colors.white),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: Slider(
                            value: _zoomLevel,
                            min: 1.0,
                            max: _maxZoomLevel,
                            onChanged: (value) async {
                              await _controller.setZoomLevel(value);
                              setState(() {
                                _zoomLevel = value;
                              });
                            },
                          ),
                        ),
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 16.0),
                        FloatingActionButton(
                          onPressed: _pickImage,
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.photo_library),
                        ),
                      ],
                    ),
                  ),
                  ],
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  /// Navigates to the ExtraInfoPage with the captured image.
  void _navigateToExtraInfo(XFile image) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ExtraInfoPage(imagePath: image.path)));

    context.read<HomeNavigationBloc>().add(NavigateToHistory());
  }
}
