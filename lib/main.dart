import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:volume/volume.dart';
import 'package:google_sign_in/google_sign_in.dart';

final bool _isLoggedIn = false;

List<CameraDescription> cameras;

class CameraAppTest extends StatelessWidget {
  static const routeName = '/videoRecordScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
            // width: 200,

            alignment: Alignment.center,
            // margin: EdgeInsets.all(24),
            // padding: EdgeInsets.all(24),
            decoration: BoxDecoration(),
            // decoration: ,
            child: Stack(
              children: [
                Container(child: VideoExample()),
              ],
            )));
  }
}

class Square extends StatefulWidget {
  final color;
  final size;

  Square({this.color, this.size});

  @override
  _SquareState createState() => _SquareState();
}

class _SquareState extends State<Square> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return RotationTransition(
      turns: AlwaysStoppedAnimation(270 / 360),
      child: CameraPreview(controller),
    );
  }
}

class Demo extends StatelessWidget {
  build(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15, right: 15),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ClipRRect(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                ),
                // margin: EdgeInsets.only(bottom: 30),
                child: Square(),
              ),
            ),
          ),
          // Square(),
        ],
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CameraAppTest(),
    );
  }
}

//video code
class VideoExample extends StatefulWidget {
  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<VideoExample> {
  VideoPlayerController playerController;
  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void createVideo() {
    if (playerController == null) {
      playerController = VideoPlayerController.asset("assets/demo1.mp4")
        ..addListener(listener)
        ..setVolume(1.0)
        ..initialize()
        ..play();
    } else {
      if (playerController.value.isPlaying) {
        playerController.pause();
      } else {
        playerController.initialize();
        playerController.play();
      }
    }
  }

  @override
  void deactivate() {
    playerController.setVolume(0.0);
    playerController.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Stack(children: [
        AspectRatio(
            aspectRatio: 24 / 12,
            child: Container(
              child: (playerController != null
                  ? VideoPlayer(
                      playerController,
                    )
                  : Container()),
            )),
        Positioned(right: 30, top: 50, child: GoogleLogin()),
        Positioned(child: Demo()),
        Row(children: [
          new Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: RotatedBox(quarterTurns: -1, child: VolumePage()),
          )
        ]),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createVideo();
          playerController.play();
        },
        child: Icon(Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

//volume code
class VolumePage extends StatefulWidget {
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<VolumePage> {
  double _sliderValue = 0.0;
  int maxVol, currentVol;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> initPlatformState() async {
    await Volume.controlVolume(AudioManager
        .STREAM_MUSIC); // you can change which volume you want to change.
  }

  updateVolumes() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() {});
  }

  setVol(int i) async {
    await Volume.setVol(i);
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: Colors.indigoAccent,
      min: 0.0,
      max: 15.0,
      onChanged: (newRating) async {
        setState(() {
          _sliderValue = newRating;
        });
        await setVol(newRating.toInt());
        await updateVolumes();
      },
      value: _sliderValue,
    );
  }
}

class GoogleLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<GoogleLogin> {
  bool _isLoggedIn = false;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  _login() async {
    try {
      await _googleSignIn.signIn();
      setState(() {
        _isLoggedIn = true;
      });
    } catch (err) {
      print(err);
    }
  }

  _logout() {
    _googleSignIn.signOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Container(
      width: 80,
      height: 80,
      child: _isLoggedIn
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _googleSignIn.currentUser.displayName,
                  style: TextStyle(color: Colors.white),
                ),
                OutlineButton(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Colors.white,
                    style: BorderStyle.solid,
                  ),
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.white,
                  onPressed: () {
                    _logout();
                  },
                )
              ],
            )
          : Center(
              child: OutlineButton(
                borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.white,
                  style: BorderStyle.solid,
                ),
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.white,
                onPressed: () {
                  _login();
                },
              ),
            ),
    );
  }
}
