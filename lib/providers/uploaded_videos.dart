import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log_level.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:video_player/video_player.dart';

class UploadedVideoFiles {
  List<Map<String, Object?>> introVideos = [];
  List<Map<String, Object?>> mainVideos = [];
  Map<String, dynamic>? backgroundMusic;
  List<Map<String, dynamic>> recordList = [];
  final FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();
  final FlutterFFmpegConfig flutterFFmpegConfig = new FlutterFFmpegConfig();
  final audioPlayer = AudioPlayer();
  UploadedVideoFiles() {
    flutterFFmpegConfig.setLogLevel(LogLevel.AV_LOG_ERROR);
    flutterFFmpegConfig.disableStatistics();
  }

  Future<double> getVideoDuration(String path) async {
    double duration;
    VideoPlayerController controller =
        new VideoPlayerController.file(File(path));
    await controller.initialize();
    duration = controller.value.duration.inSeconds.toDouble();
    controller.dispose();
    return duration;
  }

  Future<Duration> getAudioDuration(String path) async {
    await audioPlayer.setUrl(path, isLocal: true);
    await Future.delayed(Duration(milliseconds: 200));
    return Duration(milliseconds: await audioPlayer.getDuration());
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> updateProgressPercentage({
    required double videoDuration,
    Function(double?)? callBack,
  }) async {
    print('cancel');
    flutterFFmpeg.cancel();
    flutterFFmpegConfig.resetStatistics();
    await Future.delayed(Duration(seconds: 2));
    Future.doWhile(() async {
      Statistics statistics =
          await flutterFFmpegConfig.getLastReceivedStatistics();
      final prg = ((statistics.time / 1000) / videoDuration) * 100;
      // print(prg);
      callBack?.call(prg);
      await Future.delayed(Duration(seconds: 1));
      List listExecutions = await flutterFFmpeg.listExecutions();
      if (listExecutions.isEmpty) {
        print('break');
        callBack?.call(null);
        return false;
      }
      return true;
    });
  }

  Future<void> downloadVideos(
      {required List<Map<String, Object?>> videos,
      Function()? callBack}) async {
    GoogleDrive googleDrive = GoogleDrive();
    for (var video in videos) {
      if (!(video['videoPath'] as String).contains('http')) continue;
      if (video['progressPercentage'] != null) continue;
      final downloadedVideoPath = await googleDrive.downloadGoogleDriveFile(
        fNameWithExt: video['videoName'] as String,
        gdID: googleDrive.getIdfromLink(video['videoPath'] as String),
        callBack: (prg) {
          video['progressPercentage'] = prg;
          callBack?.call();
        },
      );
      video['videoPath'] = downloadedVideoPath ?? video['videoPath'];
    }
  }

  Future<String?> concat(
      {required List<Map<String, Object?>> videos,
      required String name,
      bool removeSound = false}) async {
    if (videos.isEmpty) return null;
    print('concat..');
    flutterFFmpeg.cancel();
    await Future.delayed(Duration(seconds: 1));
    final appDir = await path.getTemporaryDirectory();
    final File videoPathsFile = File('${appDir.path}/videoPaths.txt');
    final outputPath = '${appDir.path}/$name.mp4';
    await videoPathsFile.writeAsString('');

    for (var video in videos) {
      await videoPathsFile.writeAsString('file ${video['videoPath']}\n',
          mode: FileMode.append);
    }
    final exitCode = await flutterFFmpeg.execute(
        '-y  -nostdin -f concat -safe 0  -i ${videoPathsFile.path} ${removeSound ? '-an' : ''} -r 30 -ar 44100 -c copy $outputPath');

    if (exitCode == 0) {
      print('concat() $outputPath');
      return outputPath;
    } else {
      print('ERROR! concat() $exitCode');
      throw ('ERROR! concat() $exitCode');
    }
  }

  Future<void> scale(
      {required List<Map<String, Object?>> videos,
      Function? callBack,
      Future<Null> Function()? whenComplete}) async {
    final appDir = await path.getTemporaryDirectory();
    print('resizing..');
    for (var video in videos) {
      if (video['changed'] == true) {
        final outputPath =
            '${appDir.path}/${video['videoName']}';//${DateTime.now().second}-
        final _videoDuration = await getVideoDuration("${video['videoPath']}");
        print("_videoDuration $_videoDuration ${video['videoName']}");
        //get start and end
        final start =
            video['start'] == null ? 0.0 : (video['start'] as double?)! / 1000;
        final end = video['end'] == null
            ? _videoDuration
            : (video['end'] as double?)! / 1000;
        //progress percentage
        await updateProgressPercentage(
            videoDuration: _videoDuration,
            callBack: (prg) {
              video['progressPercentage'] = prg;
              callBack?.call();
            });
        //ffmpeg command
        final returnCode = await flutterFFmpeg.execute(
          '-y  -nostdin -i ${video['videoPath']} -ss $start -to $end -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -aspect 1920:1080 -vcodec libx264 -r 30 -ar 44100  $outputPath',
        );
        //after process ends
        if (returnCode == 0) {
          video['videoPath'] = outputPath;
          video['start'] = null;
          video['end'] = null;
          video['progressPercentage'] = null;
          video['changed'] = false;

          callBack?.call();
          whenComplete?.call();
        } else {
          print('ERROR!  scale() $returnCode');
          throw ('ERROR! scale() $exitCode');
        }
      }
    }
  }

  Future<void> addPadding(
      {required List<Map<String, Object?>> videos,
      Function? callBack,
      Future<Null> Function()? whenComplete}) async {
    print('addPadding..');
    final appDir = await path.getTemporaryDirectory();
    for (var video in videos) {
      if (video['changed'] == true) {
        final outputPath =
            '${appDir.path}/${video['videoName']}';//${DateTime.now().second}-
        final _videoDuration = await getVideoDuration("${video['videoPath']}");
        final start =
            video['start'] == null ? 0.0 : (video['start'] as double?)! / 1000;
        final end = video['end'] == null
            ? _videoDuration
            : (video['end'] as double?)! / 1000;
        await updateProgressPercentage(
          videoDuration: _videoDuration,
          callBack: (prg) {
            video['progressPercentage'] = prg;
            callBack?.call();
          },
        );
        final returnCode;
        if (video['hasPadding'] == null || video['hasPadding'] == false)
          returnCode = await flutterFFmpeg.execute(
            '-y  -nostdin -i ${video['videoPath']} -ss $start -to $end -vf "scale=1920:907,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1" -aspect 1920:1080 -vcodec libx264 -r 30 -ar 44100  $outputPath',
          );
        else
          returnCode = await flutterFFmpeg.execute(
            '-y  -nostdin -i ${video['videoPath']} -ss $start -to $end -r 30 -ar 44100  $outputPath',
          );

        if (returnCode == 0) {
          video['videoPath'] = outputPath;
          video['start'] = null;
          video['end'] = null;
          video['progressPercentage'] = null;
          video['changed'] = false;
          video['hasPadding'] = true;
          callBack?.call();
          whenComplete?.call();
        } else {
          print('ERROR! addPadding() $returnCode');
          throw ('ERROR! addPadding() $exitCode');
        }
      }
    }
  }

  Future<String?> concatAudio(
      {required List<Map<String, dynamic>> recordList,
      required String name}) async {
    if (recordList.isEmpty) return null;
    print('concatAudio..');
    // flutterFFmpegConfig.disableStatistics();
    final appDir = await path.getTemporaryDirectory();
    List<String> commands = [];
    final outputPath = '${appDir.path}/$name.m4a';

    commands = ['-y'];
    for (var audio in recordList) {
      commands.add('-i');
      commands.add('\'${audio['audioPath']}\'');
    }
    commands = [
      ...commands,
      '-filter_complex',
      "'concat=n=${recordList.length}:v=0:a=1[a]'",
      '-map',
      '"[a]"',
      '-c:a',
      'aac',
      '-ar',
      '44100',
      outputPath,
    ];
    final exitCode = await flutterFFmpeg.execute(commands.join(' '));
    if (exitCode == 0) {
      print('concatAudio() $outputPath');
      return outputPath;
    } else {
      print('ERROR! concatAudio() $exitCode');
      throw ('ERROR! concatAudio() $exitCode');
    }
  }

  Future<String?> mixAudio({
    String? backgroundAudio,
    String? foregroundAudio,
    required String name,
    required double videoDuration,
  }) async {
    print('mixAudio..');
    final appDir = await path.getTemporaryDirectory();
    final outputPath = '${appDir.path}/$name.m4a';
    final silenceAudioPath = '${appDir.path}/silence.m4a';
    await flutterFFmpeg
        .execute('-y -f lavfi -t $videoDuration -i anullsrc $silenceAudioPath');
    backgroundAudio = backgroundAudio ?? silenceAudioPath;
    foregroundAudio = foregroundAudio ?? silenceAudioPath;

    final commande =
        '-y -i \'$silenceAudioPath\' -t $videoDuration -i \'$backgroundAudio\' -t $videoDuration -i \'$foregroundAudio\' -filter_complex "[0:a]volume=0.0[a0]; [1:a]volume=0.5[a1]; [2:a]volume=5.0[a2];  [a2][a1][a0]amix=inputs=3:duration=longest[out]"  -map "[out]"  -ac 2  -c:a  aac  -ar 44100  $outputPath';

    final exitCode = await flutterFFmpeg.execute(commande);
    if (exitCode == 0) {
      print('mixAudio() $outputPath');
      return outputPath;
    } else {
      print('ERROR! mixAudio() $exitCode');
      throw ('ERROR! mixAudio() $exitCode');
    }
  }

  // Future<String?> mergreAudioVideo({
  //   required String? video,
  //   required String? audio,
  //   required String name,
  //   required double videoDuration,
  // }) async {
  //   if (video == null || audio == null) return video;
  //   print('mergreAudioVideo..');
  //   final appDir = await path.getTemporaryDirectory();
  //   final outputPath = '${appDir.path}/$name.mp4';
  //   final out = videoDuration - 5;
  //   final exitCode = await flutterFFmpeg.execute(
  //       '-i $video -i $audio -filter_complex "[0:v]fade=type=in:duration=5,fade=type=out:duration=5:start_time=$out[v];[1:a]afade=type=in:duration=5,afade=type=out:duration=5:start_time=$out[a]" -map "[v]" -map "[a]" -r 30 -ar 44100 $outputPath');
  //   if (exitCode == 0) {
  //     print('mergreAudioVideo() $outputPath');
  //     return outputPath;
  //   } else {
  //     print('ERROR! mergreAudioVideo() $exitCode');
  //     throw ('ERROR! mergreAudioVideo() $exitCode');
  //   }
  // }

  Future<String?> overlay({
    required String video,
    required String audio,
    required String watermark,
    required String centredPhoneNumber,
    required String bottomPhoneNumber,
    required String subscribe,
    required double videoDuration,
    int x = 0,
    int y = 0,
    int w = -1,
    int h = -1,
  }) async {
    print('OverlayTest..');
    final appDir = await path.getTemporaryDirectory();
    final outputPath = '${appDir.path}/OverlayTest.mp4';
    double lastEndPosition = 0.0;
    String keyFilterOverlayCommand(
        {required double startPosition, required int i, required double end}) {
      if (startPosition + 10 > end) return '';
      final cmd = '''
      [v][1:v] overlay=enable=\'between(t,$lastEndPosition,$startPosition)\'[v];
      [$i:v]format=rgb24,colorkey=black:0.3:0.2,setpts=PTS+$startPosition/TB[vb];
      [v][vb]overlay=enable=\'between(t,$startPosition, ${startPosition + 10})\'[v];
      ''';
      lastEndPosition = startPosition + 11;
      return cmd;
    }

    String channelMixOverlayCommand(
        {required double startPosition, required int i, required double end}) {
      if (startPosition + 10 > end) return '';

      final cmd = '''
      [v][1:v] overlay=enable=\'between(t,$lastEndPosition,$startPosition)\'[v];
      [$i:v]format=yuva420p,colorchannelmixer=aa=0.8,setpts=PTS+$startPosition/TB[vb];
      [v][vb]overlay=enable=\'between(t,$startPosition, ${startPosition + 10})\'[v];
      ''';
      lastEndPosition = startPosition + 11;
      return cmd;
    }

    int nbrEventBreak = videoDuration ~/ 60;
    nbrEventBreak = nbrEventBreak < 10 ? nbrEventBreak : 10;
    final eventBreakTime = videoDuration / nbrEventBreak;
    final fadeOutStartTime = videoDuration - 5;
    final end = videoDuration - 60;
    String command = '''
      -y
      -i $video
      -i $watermark
      -i $centredPhoneNumber
      -i $subscribe
      -i $bottomPhoneNumber
      -i $audio
      -filter_complex
      "
      [0:v]fade=type=in:duration=5,fade=type=out:duration=5:start_time=$fadeOutStartTime[v];
      [5:a]afade=type=in:duration=5,afade=type=out:duration=5:start_time=$fadeOutStartTime[a];

      ${channelMixOverlayCommand(i: 2, startPosition: eventBreakTime, end: end)}
      ${keyFilterOverlayCommand(i: 3, startPosition: 2 * eventBreakTime, end: end)}
      ${(2 * eventBreakTime + 10 > end) ? '' : '''
      [3:a]adelay=${(2 * eventBreakTime) * 1000}|${(2 * eventBreakTime) * 1000}[subscribeA];
      [a][subscribeA]amix=inputs=2:duration=longest[a];
      '''}
      
      ${keyFilterOverlayCommand(i: 4, startPosition: 3 * eventBreakTime, end: end)}

    ''';

    for (var startPosition = lastEndPosition + eventBreakTime;
        startPosition < end;
        startPosition += eventBreakTime) {
      command +=
          keyFilterOverlayCommand(i: 4, startPosition: startPosition, end: end);
    }
    // [v][1] overlay=enable=\'between(t,${videoDuration - 19},$videoDuration)\'[v]
    command += '''

      ${channelMixOverlayCommand(i: 2, startPosition: videoDuration - 11, end: videoDuration)}

      "
      -map [v] 
      -map [a] 
      -c:a aac
      -c:v libx264 -preset ultrafast
      -r 30 
      -ar 44100
      $outputPath
    ''';
    int i = command.lastIndexOf(';');
    command = command.replaceRange(i, i + 1, ' ');
    final exitCode = await flutterFFmpeg.execute(command.replaceAll('\n', ' '));

    if (exitCode == 0) {
      print('OverlayTest() $outputPath');
      return outputPath;
    } else {
      print('ERROR! OverlayTest() $exitCode');
      throw ('ERROR! OverlayTest() $exitCode');
    }
  }

  Future<String?> processFinalVideo(
      {Function(String?, double?)? callBack}) async {
    print('initialising processFinalVideo..');
    // final appDir = await path.getApplicationDocumentsDirectory();
    final tempDir = await path.getTemporaryDirectory();
    final outputPath = '${tempDir.path}/finalVideo.mp4';//${DateTime.now().second}_
    final videoPathsFile =
        await File('${tempDir.path}/FinalVideoPaths.txt').writeAsString('');
    print('importing assets..');
    final watermark =
        await copyOfAsset('assets/for_video_editing/images/watermark.png');
    final bottomPhoneNumber = await copyOfAsset(
        'assets/for_video_editing/videos/bottom_phone_number.mp4');
    final centredPhoneNumber = await copyOfAsset(
        'assets/for_video_editing/videos/centred_phone_number.mp4');
    final introLogo =
        await copyOfAsset('assets/for_video_editing/videos/intro_logo.mp4');
    final outro =
        await copyOfAsset('assets/for_video_editing/videos/outro.mp4');
    final subscribe =
        await copyOfAsset('assets/for_video_editing/videos/subscribe.mp4');

    print('processing..');
    double finalVideoDuration = 0.0;
    //intro video
    final concatIntro = await concat(videos: introVideos, name: 'introVideo');
    if (concatIntro != null) {
      await videoPathsFile.writeAsString('file $concatIntro\n',
          mode: FileMode.append);
      finalVideoDuration += await getVideoDuration(concatIntro);
    }
    //into logo video
    await videoPathsFile.writeAsString('file $introLogo\n',
        mode: FileMode.append);
    finalVideoDuration += await getVideoDuration(introLogo);
    //mai Video
    final mainVideo = await concat(
      videos: mainVideos,
      name: 'mainVideo',
    );
    if (mainVideo == null) return null;
    double mainVideoDuration = await getVideoDuration(mainVideo);
    finalVideoDuration += mainVideoDuration;
    final concatedAudio = await concatAudio(
      recordList: recordList,
      name: 'concatedAudio',
    );
    await updateProgressPercentage(
      videoDuration: finalVideoDuration,
      callBack: (prg) => callBack?.call('Processing audio...', prg),
    );
    final mixedAudio = await mixAudio(
      backgroundAudio: backgroundMusic!['audioPath'],
      foregroundAudio: concatedAudio,
      name: 'mixedAudio',
      videoDuration: mainVideoDuration,
    );
    await Future.delayed(Duration(seconds: 2));
    await updateProgressPercentage(
      videoDuration: finalVideoDuration,
      callBack: (prg) => callBack?.call('Processing video...', prg),
    );
    final overlayedMainVideo = await overlay(
      video: mainVideo,
      audio: mixedAudio!,
      watermark: watermark,
      centredPhoneNumber: centredPhoneNumber,
      bottomPhoneNumber: bottomPhoneNumber,
      subscribe: subscribe,
      videoDuration: mainVideoDuration,
    );

    await videoPathsFile.writeAsString('file $overlayedMainVideo\n',
        mode: FileMode.append);

    //outro video
    await videoPathsFile.writeAsString('file $outro\n', mode: FileMode.append);
    finalVideoDuration += await getVideoDuration(outro);

    await Future.delayed(Duration(seconds: 2));
    await updateProgressPercentage(
      videoDuration: finalVideoDuration,
      callBack: (prg) => callBack?.call('finalizing...', prg),
    );
    //concat results
    final exitCode = await flutterFFmpeg.execute(
      '-y   -f concat -safe 0  -i ${videoPathsFile.path} -r 30 -ar 44100 -c copy $outputPath',
    );
    callBack?.call(null, null);
    if (exitCode == 0) {
      print('processFinalVideo() $outputPath');
      return outputPath;
    } else {
      print('ERROR! processFinalVideo() $exitCode');
      throw ('ERROR! processFinalVideo() $exitCode');
    }
  }

  Future<String> copyOfAsset(String asset) async {
    String dir = (await path.getApplicationDocumentsDirectory()).path;
    final filepath = '$dir/${asset.split('/').last}';
    if (await File(filepath).exists()) {
      print('asset already exists.');
      return filepath;
    }
    if (asset.endsWith('mp4')) {
      final originalfile = '$dir/original_${asset.split('/').last}';
      var bytes = await rootBundle.load(asset);
      final buffer = bytes.buffer;
      await File(originalfile).writeAsBytes(
          buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      await flutterFFmpeg.execute(
          '-y  -nostdin -i $originalfile -c:v libx264 -c:a aac -r 30 -ar 44100 $filepath');
    } else {
      var bytes = await rootBundle.load(asset);
      final buffer = bytes.buffer;
      await File(filepath).writeAsBytes(
          buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    }
    return filepath;
  }

  Map<String, Object?>? findVideoByPath(String path) {
    var result = mainVideos.firstWhere((video) => video['videoPath'] == path,
        orElse: () =>
            introVideos.firstWhere((video) => video['videoPath'] == path));
    return result.isEmpty ? null : result;
  }

  String videosSource(List<Map<String, Object?>> videos) {
    for (var video in videos) {
      if (!(video['videoPath'] as String).contains('drive.google.com')) {
        return 'local';
      }
    }
    return 'googleDrive';
  }

  bool isListChanged(List<Map<String, Object?>> videos) {
    for (var video in videos) {
      if (video['changed'] == true) {
        return true;
      }
    }
    return false;
  }

  Map<String, Object?>? findVideo(String key, var value, String? location) {
    var result;
    if (location == 'MainVideos')
      result = mainVideos.firstWhere((video) => video[key] == value);
    else if (location == 'IntroVideos')
      result = mainVideos.firstWhere((video) => video[key] == value);
    else
      result = mainVideos.firstWhere((video) => video[key] == value,
          orElse: () => introVideos.firstWhere((video) => video[key] == value,
              orElse: () => {}));
    return result.isEmpty ? null : result;
  }
}
