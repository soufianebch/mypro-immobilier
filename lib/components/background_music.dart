import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypro_immobilier/components/sound_display.dart';
import 'package:mypro_immobilier/providers/uploaded_videos.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class BackgroundVideoMusic extends StatefulWidget {
  BackgroundVideoMusic({Key? key, required this.uploadedVideoFiles})
      : super(key: key);
  final UploadedVideoFiles uploadedVideoFiles;
  @override
  _BackgroundVideoMusicState createState() => _BackgroundVideoMusicState();
}

class _BackgroundVideoMusicState extends State<BackgroundVideoMusic> {
  TextEditingController controller = TextEditingController();
  String? uri;
  final audioPlayer = AudioPlayer();
  Map<String, dynamic>? backgroundMusic;
  Color inputBorderColler = Colors.black;
  // String getYoutubeVideoId(String url) {
  //   RegExp regExp = new RegExp(
  //     r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
  //     caseSensitive: false,
  //     multiLine: false,
  //   );
  //   final match = regExp.firstMatch(url)?.group(1); // <- This is the fix
  //   String str = match ?? '';
  //   return str;
  // }
  Future<Map<String, dynamic>?> downloadYoutubeAudio() async {
    try {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest(controller.text);
      var streamInfo = manifest.audioOnly.last;
      setState(() {
        inputBorderColler = Colors.green;
      });
      // Get the actual stream
      var stream = yt.videos.streamsClient.get(streamInfo);

      // Open a file for writing.
      final appDir = await getTemporaryDirectory();
      var file = File('${appDir.absolute.path}/backgroundMusic.mp4');
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
      backgroundMusic = {
        'audioPath': file.path,
        'audioName': 'myproimmobilier_${file.path.split('/').last}',
        'audioDuration':
            await widget.uploadedVideoFiles.getAudioDuration(file.path),
      };
      // FocusScope.of(context).unfocus();
      setState(() {});
      return backgroundMusic;
    } catch (err) {
      print(err);
      setState(() {
        inputBorderColler = Colors.red;
      });
      return null;
    }
  }

  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      backgroundMusic = widget.uploadedVideoFiles.backgroundMusic;
      audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          audioPlayer.stop();
        });
      });
      init = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.46 +
            MediaQuery.of(context).viewInsets.bottom,
        padding: EdgeInsets.fromLTRB(
          10,
          10,
          10,
          MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Download from youtube',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter.deny(' ')],
                onChanged: (_) async {
                  await downloadYoutubeAudio();
                },
                onFieldSubmitted: (_) async {
                  await downloadYoutubeAudio();
                },
                controller: controller,
                textInputAction: TextInputAction.done,
                // validator: (value) =>
                //     (value == null || value.length < 10 || value.length > 50)
                //         ? 'Titre doit etre entre 10 et 50 caractères.'
                //         : null,
                decoration: InputDecoration(
                  hintText: 'Link..',
                  hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontFamily: 'Poppins',
                        color: Colors.grey[400],
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: inputBorderColler,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: inputBorderColler,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? InkWell(
                          onTap: () => setState(
                            () => controller.clear(),
                          ),
                          child: Icon(
                            Icons.clear,
                            size: 15,
                            color: inputBorderColler,
                          ),
                        )
                      : null,
                ),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontFamily: 'Poppins',
                    ),
                maxLines: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Or',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FFButtonWidget(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Upload'),
                    ),
                  ],
                ),
                onPressed: () async {
                  final pickFileResult = await FilePicker.platform.pickFiles(
                    withData: false,
                    // withReadStream: true,
                    allowMultiple: false,
                    type: FileType.audio,
                  );
                  if (pickFileResult != null) {
                    final file = pickFileResult.files.first;
                    backgroundMusic = {
                      'audioPath': file.path,
                      'audioName': 'myproimmobilier_${file.name}',
                      'audioDuration': await widget.uploadedVideoFiles
                          .getAudioDuration(file.path!),
                    };
                  }
                  setState(() {});
                },
              ),
            ),
            Container(
              height: 70,
              width: MediaQuery.of(context).size.width * .8,
              margin: EdgeInsets.only(bottom: 10),
              child: backgroundMusic == null
                  ? null
                  : StreamBuilder(
                      stream: audioPlayer.onAudioPositionChanged,
                      builder: (context, snapshot) => DisplaySound(
                        color: Colors.grey[100],
                        file: backgroundMusic!,
                        audioPlayer: audioPlayer,
                        isPlaying: audioPlayer.state == PlayerState.PLAYING,
                        title:
                            '${audioPlayer.state == PlayerState.PLAYING && snapshot.hasData ? widget.uploadedVideoFiles.formatDuration(snapshot.data as Duration) : '00:00:00'}/${widget.uploadedVideoFiles.formatDuration(backgroundMusic!['audioDuration'])}',
                        onTap: audioPlayer.state == PlayerState.PLAYING
                            ? () {
                                audioPlayer.stop();
                                setState(() {});
                              }
                            : () async {
                                await audioPlayer.play(
                                    backgroundMusic!['audioPath'],
                                    isLocal: true);
                                setState(() {});
                              },
                        onDismissed: (direction) async {
                          audioPlayer.stop();
                          final tempHolder = backgroundMusic;
                          setState(() {
                            backgroundMusic = null;
                          });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Background music deleted!'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                setState(() {
                                  backgroundMusic = tempHolder;
                                });
                              },
                            ),
                          ));
                        },
                      ),
                    ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                    options: FFButtonWidget.styleFrom(
                      width: 150,
                      height: 40,
                      textStyle:
                          Theme.of(context).textTheme.subtitle2!.copyWith(
                                fontFamily: 'Poppins',
                                color: Color(0xFF9E9E9E),
                              ),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      widget.uploadedVideoFiles.backgroundMusic =
                          backgroundMusic;
                      Navigator.of(context).pop();
                    },
                    child: Text('Confirm'),
                    options: FFButtonWidget.styleFrom(
                      width: 150,
                      height: 40,
                      textStyle:
                          Theme.of(context).textTheme.subtitle2!.copyWith(
                                fontFamily: 'Poppins',
                                color: Color(0xFF9E9E9E),
                              ),
                      borderSide: BorderSide(
                        color: Color(0x00EEEEEE),
                        width: 1,
                      ),
                      borderRadius: 12,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
