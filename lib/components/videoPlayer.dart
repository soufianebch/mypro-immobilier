import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mypro_immobilier/providers/uploaded_videos.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:video_trimmer/video_trimmer.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';

// class MyVideoPlayer extends StatefulWidget {
//   MyVideoPlayer({Key? key, required this.link}) : super(key: key);
//   final String link;
//   @override
//   _MyVideoPlayerState createState() => _MyVideoPlayerState();
// }

// class _MyVideoPlayerState extends State<MyVideoPlayer> {
//   late VideoPlayerController videoPlayerController =
//       VideoPlayerController.network(widget.link);
//   late ChewieController chewieController;

//   @override
//   void initState() {
//     chewieController = ChewieController(
//       videoPlayerController: videoPlayerController,
//       aspectRatio: 16 / 9,
//       allowMuting: true,
//       autoInitialize: true,
//       allowFullScreen: false,
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(errorMessage),
//         );
//       },
//     );
//     super.initState();
//   }

//   @override
//   void dispose() {
//     videoPlayerController.dispose();
//     chewieController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Chewie(
//       controller: chewieController,
//     );
//   }
// }
class TrimmerView extends StatefulWidget {
  final String videoPath;

  final UploadedVideoFiles uploadedVideoFiles;
  TrimmerView({required this.videoPath, required this.uploadedVideoFiles});

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  var init = true;
  final Trimmer _trimmer = Trimmer();
  late final video;
  late double _startValue;
  late double _endValue;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  // Future<String?> _saveVideo() async {
  //   setState(() {
  //     _progressVisibility = true;
  //   });

  //   String? _value;

  //   await _trimmer
  //       .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
  //       .then((value) {
  //     setState(() {
  //       _progressVisibility = false;
  //       _value = value;
  //     });
  //   });

  //   return _value;
  // }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: File(video['videoPath']));
  }

  @override
  void initState() {
    super.initState();
    video = widget.uploadedVideoFiles.findVideoByPath(widget.videoPath);
    _startValue = video['start'] ?? 0.0;
    _endValue = video['end'] ?? 0.0;

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.tertiaryColor,
        automaticallyImplyLeading: false,
        leading: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.black,
              size: 30,
            ),
            iconSize: 30,
          ),
        ),
        title: FittedBox(
          child: Text(
            'Video Trimmer',
            style: Theme.of(context).textTheme.headline3!.copyWith(
                  fontFamily: 'Poppins',
                ),
          ),
        ),
        actions: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(),
            child: Align(
              alignment: Alignment(0.85, 0),
              child: IconButton(
                onPressed: () async {
                  video?['start'] = _startValue;
                  if (_endValue > _startValue) video?['end'] = _endValue;
                  video['changed'] = true;
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 31,
                ),
                iconSize: 31,
              ),
            ),
          )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.grey[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                // ElevatedButton(
                //   onPressed: _progressVisibility
                //       ? null
                //       : () async {
                //           _saveVideo().then((outputPath) {
                //             print('OUTPUT PATH: $outputPath');
                //             final snackBar = SnackBar(
                //                 content: Text('Video Saved successfully'));
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               snackBar,
                //             );
                //           });
                //         },
                //   child: Text("SAVE"),
                // ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Text(
                    '${(_startValue / 60000).toStringAsFixed(2)} - ${(_endValue / 60000).toStringAsFixed(2)} ',
                    textAlign: TextAlign.center),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TrimEditor(
                      trimmer: _trimmer,
                      viewerHeight: 60.0,
                      viewerWidth: MediaQuery.of(context).size.width - 40,
                      borderPaintColor: MyTheme.primaryColor,
                      circlePaintColor: MyTheme.primaryColor,
                      circleSize: 10,
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        if (!init || _endValue == 0.0) {
                          _endValue = value;
                        }
                        init = false;
                      },
                      onChangePlaybackState: (value) {
                        setState(() {
                          _isPlaying = value;
                        });
                      },
                    ),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.grey[600],
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.grey[600],
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
