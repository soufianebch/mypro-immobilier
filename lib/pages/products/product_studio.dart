import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mypro_immobilier/components/background_music.dart';
import 'package:mypro_immobilier/components/sound_display.dart';
import 'package:mypro_immobilier/pages/products/add_product/product_upload_videos.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:record/record.dart';
import 'package:share_extend/share_extend.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

enum RecordMode {
  playing,
  paused,
  stoped,
}

class StudioScreen extends StatefulWidget {
  static const routeName = 'studio';
  StudioScreen({Key? key}) : super(key: key);

  @override
  _StudioScreenState createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  Record record = Record();
  AudioPlayer audioPlayer = AudioPlayer();
  RecordMode recordMode = RecordMode.stoped;
  late Product product;
  int? playingAudioIndex;
  int? playingAudioCurrentPosition;
  List<String> productFeatures = [];
  FloatingActionButtonLocation floatingActionButtonLocation =
      FloatingActionButtonLocation.endFloat;
  double mainVideoDuration = 0.0;
  GoogleDrive googleDrive = GoogleDrive();
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  double? processProgress;
  String? processTitle;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  DateTime? _longPressStart;
  double? _longPressDownloadProgress;

  bool init = true;
  @override
  void didChangeDependencies() {
    if (init) {
      product = ModalRoute.of(context)!.settings.arguments as Product;
      if (product.uploadedVideoFiles!.mainVideos.length > 0) {
        videoPlayerController = VideoPlayerController.network(
            '${product.uploadedVideoFiles!.mainVideos.first['videoPath']}');
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          aspectRatio: 16 / 9,
          allowMuting: true,
          autoInitialize: true,
          allowFullScreen: false,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(errorMessage),
            );
          },
        );
        product.uploadedVideoFiles!
            .getVideoDuration(
              '${product.uploadedVideoFiles!.mainVideos.first['videoPath']}',
            )
            .then((value) => mainVideoDuration = value);
      } else {
        videoPlayerController = null;
        chewieController = null;
        mainVideoDuration = 0.0;
      }

      audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          playingAudioIndex = null;
          playingAudioCurrentPosition = null;
        });
      });

      if (product.ascensseur != null && product.ascensseur!)
        productFeatures.add('ascensseur');
      if (product.terrasse != null && product.terrasse!)
        productFeatures.add('terrasse');
      if (product.meuble != null && product.meuble!)
        productFeatures.add('meuble');
      if (product.climatisation != null && product.climatisation!)
        productFeatures.add('climatisation');
      if (product.chauffage != null && product.chauffage!)
        productFeatures.add('chauffage');
      if (product.cuisineEquipee != null && product.cuisineEquipee! || true)
        productFeatures.add('cuisine Equipe');
      if (product.concierge != null && product.concierge!)
        productFeatures.add('concierge');
      if (product.securite != null && product.securite!)
        productFeatures.add('securite');
      if (product.parking != null && product.parking!)
        productFeatures.add('parking');
      if (product.duplex != null && product.duplex!)
        productFeatures.add('duplex');
      setState(() {});
      init = false;
      super.didChangeDependencies();
    }
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    audioPlayer.dispose();
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        return true;
      },
      child: Stack(children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyTheme.tertiaryColor,
            automaticallyImplyLeading: false,
            leading: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(),
              child: GestureDetector(
                onLongPressStart: (details) => _longPressStart = DateTime.now(),
                onLongPressMoveUpdate: (details) async {
                  if (_longPressStart == null) return;
                  final counter =
                      DateTime.now().difference(_longPressStart!).inSeconds;
                  print(counter);
                  if (counter > 5) {
                    _longPressStart = null;
                    print('Pass..');
                    Fluttertoast.showToast(
                      msg: "Pass!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                    HapticFeedback.vibrate();
                    Clipboard.setData(ClipboardData(
                        text:
                            'https://drive.google.com/folderview?id=${product.googleDriveFolderId}'));
                    Clipboard.setData(ClipboardData(text: product.finalVideo));
                    Clipboard.setData(ClipboardData(text: '''
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
تعرف اكتر على القنيطرة : 
➫https://youtu.be/RzXRuHyGCTs
Savoir plus sur Kenitra : 
➫https://youtu.be/RzXRuHyGCTs


للمزيد من المعلومات اتصلو بنا على : 
Pour plus d'informations, contactez-nous sur:

►Phone+Whatsapp  : +212 628921611

Whatsapp :
➫https://wa.me/212628921611
Facebook : 
➫https://www.facebook.com/MYPROIMMOBILIERofficiel/
Instagram:
➫https://www.instagram.com/mypro_immobilier/
▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
#agence #immobilier #appartement #vendre #kenitra #شقة #شقق #وكالة #عقاري #عقار #mypro #immobilier
                    
                    '''));
                    Clipboard.setData(ClipboardData(text:''' 
▻▻▻▻▻▻ +212 628-921611 ◅◅◅◅◅◅
►WHATSAPP: https://wa.me/212628921611
►TELEPHONE: https://l.linklyhq.com/l/JlOd
'''));
                    Clipboard.setData(ClipboardData(text:''' 
شقق للبيع بالقنيطرة اليانس دارنا,اليانس,appartement a vendre,kenitra,appartement à vendre,kenitra maroc,immobilier maroc,appartements à vendre à kenitra,offres maison terrain,appartement a vendre a kenitra pas cher,شقق للبيع في القنيطرة المغرب,شقق للبيع في,شقق للبيع بالمهدية,بتجزئة اليانس دارنا مهدية القنيطرة,maison à vendre à kenitra,agence immobilier,appartement a vendre a kenitra avito,القنيطرة,مهدية,شقق للبيع بالقنيطرة,شقة,asmaa beauty,saad lamjarred
                    '''));
                    Clipboard.setData(ClipboardData(text: '${product.prix}'));
                    Clipboard.setData(ClipboardData(text: product.description));
                    Clipboard.setData(ClipboardData(text: product.title));
                    Clipboard.setData(ClipboardData(text: product.description_ar));
                    Clipboard.setData(ClipboardData(text: product.title_ar));
                    
                    if (product.finalVideo == null) {
                      Fluttertoast.showToast(
                        msg: "no final video!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                      return;
                    }
                    final id = googleDrive.getIdfromLink(product.finalVideo!);
                    final video = await googleDrive.downloadGoogleDriveFile(
                        fNameWithExt: '$id.mp4',
                        gdID: id,
                        callBack: (prg) =>
                            setState(() => _longPressDownloadProgress = prg));
                    if (video != null) ShareExtend.share(video, "image");
                    Fluttertoast.showToast(
                      msg: "Sharing..",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                    _longPressDownloadProgress = null;
                  }
                },
                child: IconButton(
                  onPressed: () {
                    product.uploadedVideoFiles?.flutterFFmpeg.cancel();
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
            ),
            title: FittedBox(
              child: Text(
                'Studio',
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
                      if (product.uploadedVideoFiles!.mainVideos.isNotEmpty)
                        try {
                          setState(() {
                            processTitle = 'initializing..';
                            Wakelock.enable();
                          });
                          final result = await product.uploadedVideoFiles!
                              .processFinalVideo(
                            callBack: (title, prg) => setState(() {
                              processProgress = prg;
                              processTitle = title;
                            }),
                          );
                          setState(() {
                            processTitle = 'Uploading..';
                          });
                          if (result != null) {
                            // await ImageGallerySaver.saveFile(result);
                            final videoFile = File(result);
                            final uploadedVideoLink =
                                await googleDrive.uploadFilesToGoogleDrive(
                              files: [
                                PlatformFile.fromMap(
                                  {
                                    'path': videoFile.path,
                                    'name': videoFile.path.split('/').last,
                                    // 'bytes': await videoFile.readAsBytes(),
                                    'size': await videoFile.length(),
                                  },
                                  readStream: videoFile.openRead(),
                                )
                              ],
                              product: product,
                            );

                            try {
                              if (product.finalVideo != null) {
                                print(
                                    'deleting old finalVideo ${product.finalVideo}');
                                await googleDrive.deleteFileFromDrive(
                                  googleDrive
                                      .getIdfromLink(product.finalVideo!),
                                );
                                product.finalVideo = null;
                              }
                            } catch (err) {
                              print(err);
                            }
                            print('New finalVideo: $uploadedVideoLink');
                            if (uploadedVideoLink != null)
                              product.finalVideo = uploadedVideoLink[0]!;
                          }
                          await ProductsRecord().addProduct(product);
                          setState(() {
                            processTitle = null;
                            Wakelock.disable();
                          });
                          FilePicker.platform.clearTemporaryFiles();
                          Navigator.of(context)..pop()..pop();
                        } catch (err) {
                          print(err);
                          setState(() {
                            processTitle = '$err';
                            Wakelock.disable();
                          });
                          await Future.delayed(Duration(seconds: 20));
                        }
                      setState(() {
                        processTitle = null;
                        Wakelock.disable();
                      });
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
          floatingActionButtonLocation: floatingActionButtonLocation,
          // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButton: recordMode == RecordMode.stoped
              ? SpeedDial(
                  child: _longPressDownloadProgress == null
                      ? null
                      : Text(
                          '${_longPressDownloadProgress!.toStringAsFixed(0)}%',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                  openCloseDial: isDialOpen,
                  animatedIcon: _longPressDownloadProgress == null
                      ? AnimatedIcons.menu_close
                      : null,
                  animatedIconTheme: _longPressDownloadProgress == null
                      ? IconThemeData(size: 22, color: MyTheme.tertiaryColor)
                      : null,
                  backgroundColor: MyTheme.primaryColor,
                  curve: Curves.bounceIn,
                  buttonSize: 55,
                  spaceBetweenChildren: 8,
                  children: [
                    // FAB 1
                    SpeedDialChild(
                      key: Key('FAB1'),
                      onTap: () async {
                        bool result = await record.hasPermission();
                        if (!result) return;
                        FocusNode().requestFocus(FocusNode());
                        await Future.delayed(Duration(milliseconds: 200));
                        setState(() {
                          recordMode = RecordMode.playing;
                          floatingActionButtonLocation =
                              FloatingActionButtonLocation.centerFloat;
                        });
                        final appDir = await getTemporaryDirectory();
                        final outputPath =
                            '${appDir.path}/myproimmobilier_${product.hashtag}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.m4a';
                        await record.start(
                          path: outputPath,
                          encoder: AudioEncoder.AAC,
                          bitRate: 128000,
                          samplingRate: 44100,
                        );
                      },
                      backgroundColor: MyTheme.primaryColor,
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                      label: 'Create a voice record',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16.0),
                      labelBackgroundColor: MyTheme.primaryColor,
                    ),
                    // FAB 2
                    SpeedDialChild(
                      key: Key('FAB2'),
                      backgroundColor: MyTheme.primaryColor,
                      child: Icon(
                        Icons.upload,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        final pickFileResult =
                            await FilePicker.platform.pickFiles(
                          withData: false,
                          // withReadStream: true,
                          allowMultiple: true,
                          type: FileType.audio,
                        );
                        if (pickFileResult != null) {
                          for (var file in pickFileResult.files) {
                            product.uploadedVideoFiles!.recordList.add({
                              'audioPath': file.path,
                              'audioName': 'myproimmobilier_${file.name}',
                              'audioDuration': await product.uploadedVideoFiles!
                                  .getAudioDuration(file.path!),
                            });
                            setState(() {});
                          }
                        }
                      },
                      label: 'Upload a voice record',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16.0),
                      labelBackgroundColor: MyTheme.primaryColor,
                    ),
                    // Fab 3
                    SpeedDialChild(
                      key: Key('FAB3'),
                      backgroundColor: MyTheme.primaryColor,
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return BackgroundVideoMusic(
                              uploadedVideoFiles: product.uploadedVideoFiles!,
                            );
                          },
                        );
                        if (product.uploadedVideoFiles!.backgroundMusic !=
                            null) {
                          setState(() {});
                          final audioDuration = await product
                              .uploadedVideoFiles!
                              .getAudioDuration(
                            product.uploadedVideoFiles!
                                .backgroundMusic!['audioPath'],
                          );
                          if (audioDuration.inSeconds < mainVideoDuration) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Background music duration less then video duration!'),
                              ),
                            );
                          }
                        }
                        print('done');
                      },
                      label: 'Change background music',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16.0),
                      labelBackgroundColor: MyTheme.primaryColor,
                    ),
                    //Fab 4
                    SpeedDialChild(
                      key: Key('FAB4'),
                      backgroundColor: MyTheme.primaryColor,
                      child: Icon(
                        Icons.video_call,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                            UploadVideosScreen.routeName,
                            arguments: product);
                      },
                      label: 'Upload videos',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16.0),
                      labelBackgroundColor: MyTheme.primaryColor,
                    ),
                    //Fab 5
                    SpeedDialChild(
                      key: Key('FAB5'),
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (alertDialogContext) {
                            return AlertDialog(
                              title: Text('Delete videos!'),
                              content: Text(
                                  'Do you really want to delete the videos?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(alertDialogContext);
                                    await ProductsRecord()
                                        .deleteVideos(product);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: 'Delete videos',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16.0),
                      labelBackgroundColor: Colors.red,
                    )
                  ],
                )
              : Container(
                  decoration: BoxDecoration(
                    color: MyTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1, 3.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  width: 140.0,
                  height: 50.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 50,
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[500],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.stop,
                                color: Colors.red[900],
                                size: 27,
                              ),
                              onPressed: () async {
                                final result = await record.stop();
                                if (result == null) return;
                                product.uploadedVideoFiles!.recordList.add({
                                  'audioPath': result,
                                  'audioName': result.split('/').last,
                                  'audioDuration': await product
                                      .uploadedVideoFiles!
                                      .getAudioDuration(result),
                                });

                                setState(() {
                                  recordMode = RecordMode.stoped;
                                  floatingActionButtonLocation =
                                      FloatingActionButtonLocation.endFloat;
                                });
                              },
                            )),
                      ),
                      Expanded(
                        flex: 42,
                        child: Container(
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor,
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(30)),
                            ),
                            alignment: Alignment.centerLeft,
                            child: recordMode == RecordMode.paused
                                ? IconButton(
                                    icon: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    onPressed: () async {
                                      await record.resume();
                                      setState(() {
                                        recordMode = RecordMode.playing;
                                      });
                                    },
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    onPressed: () async {
                                      await record.pause();
                                      setState(() {
                                        recordMode = RecordMode.paused;
                                      });
                                    },
                                  )),
                      ),
                    ],
                  ),
                ),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 9 / 16,
                color: Colors.grey[50],
                child: chewieController != null
                    ? Chewie(controller: chewieController!)
                    : null,
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  margin: EdgeInsets.only(bottom: 85),
                  padding: EdgeInsets.only(bottom: 15),
                  child: recordMode != RecordMode.stoped
                      ? SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Caracteristics(
                                    'Prix:',
                                    '${NumberFormat.currency(
                                      locale: 'eu',
                                      symbol: '',
                                    ).format(product.prix ?? 0.0)}Dhs'),
                                Caracteristics('Ville:', product.ville ?? ''),
                                Caracteristics(
                                    'Secteur:', product.secteur ?? ''),
                                Caracteristics(
                                    'Address:', product.address ?? ''),
                                Divider(
                                  thickness: 0.5,
                                  indent: 50,
                                  endIndent: 50,
                                  color: MyTheme.secondaryColor,
                                ),
                                Container(
                                  width: 300,
                                  height: 110,
                                  constraints: BoxConstraints(
                                    maxWidth: double.infinity,
                                    maxHeight: double.infinity,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0x00FFFFFF),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    child: GridView(
                                      padding: EdgeInsets.zero,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                        childAspectRatio: 1,
                                        mainAxisExtent: 90,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        DetaitsDuBienWidget(
                                          value: (product.surfaceTotal ?? 0.0)
                                              .toInt(),
                                          icon: Icon(
                                            Icons.architecture,
                                            size: 22,
                                          ),
                                        ),
                                        DetaitsDuBienWidget(
                                          value: product.nbrCuisine ?? 0,
                                          icon: Icon(
                                            Icons.room_service_sharp,
                                            color: Colors.black,
                                            size: 22,
                                          ),
                                        ),
                                        DetaitsDuBienWidget(
                                          value: product.nbrChambres ?? 0,
                                          icon: FaIcon(
                                            FontAwesomeIcons.bed,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                        DetaitsDuBienWidget(
                                          value: product.nbrSalons ?? 0,
                                          icon: Icon(
                                            Icons.chair,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                        DetaitsDuBienWidget(
                                          value: product.nbrSallesDeBain ?? 0,
                                          icon: FaIcon(
                                            FontAwesomeIcons.shower,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                        DetaitsDuBienWidget(
                                          value: product.nbrEtage ?? 0,
                                          icon: Icon(
                                            Icons.stairs,
                                            color: Colors.black,
                                            size: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  thickness: 0.5,
                                  indent: 50,
                                  endIndent: 50,
                                  color: MyTheme.secondaryColor,
                                ),
                                Container(
                                  height: productFeatures.length * 30,
                                  width: 300,
                                  child: GridView(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 3.9,
                                      // mainAxisExtent: 90,
                                    ),
                                    children: productFeatures
                                        .map((f) => Capsule(value: f))
                                        .toList(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : StreamBuilder(
                          stream: audioPlayer.onAudioPositionChanged,
                          builder: (context, snapshot) {
                            return product.uploadedVideoFiles != null
                                ? ReorderableListView.builder(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, right: 20, left: 20),
                                    itemBuilder: (context, index) {
                                      return DisplaySound(
                                        key: Key(product.uploadedVideoFiles!
                                            .recordList[index]['audioPath']),
                                        audioPlayer: audioPlayer,
                                        file: product.uploadedVideoFiles!
                                            .recordList[index],
                                        isPlaying: audioPlayer.state ==
                                                PlayerState.PLAYING &&
                                            playingAudioIndex == index,
                                        title:
                                            '${playingAudioIndex == index && snapshot.hasData ? product.uploadedVideoFiles!.formatDuration(snapshot.data as Duration) : '00:00:00'}/${product.uploadedVideoFiles!.formatDuration(product.uploadedVideoFiles!.recordList[index]['audioDuration'])}',
                                        onDismissed: (direction) async {
                                          audioPlayer.stop();
                                          final tempHolder = product
                                              .uploadedVideoFiles!
                                              .recordList[index];
                                          setState(() {
                                            product
                                                .uploadedVideoFiles!.recordList
                                                .removeAt(index);
                                          });
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: const Text(
                                                'Voice Record deleted!'),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () {
                                                setState(() {
                                                  product.uploadedVideoFiles!
                                                      .recordList
                                                      .insert(
                                                          index, tempHolder);
                                                });
                                              },
                                            ),
                                          ));
                                        },
                                        onTap: audioPlayer.state ==
                                                    PlayerState.PLAYING &&
                                                playingAudioIndex == index
                                            ? () {
                                                audioPlayer.stop();
                                                setState(() {
                                                  playingAudioIndex = null;
                                                });
                                              }
                                            : () async {
                                                await audioPlayer.play(
                                                    product.uploadedVideoFiles!
                                                            .recordList[index]
                                                        ['audioPath'],
                                                    isLocal: true);
                                                setState(() {
                                                  playingAudioIndex = index;
                                                });
                                              },
                                      );
                                    },
                                    itemCount: product
                                        .uploadedVideoFiles!.recordList.length,
                                    onReorder: (oldIndex, newIndex) {
                                      if (newIndex > oldIndex) {
                                        newIndex -= 1;
                                      }
                                      setState(() {
                                        final audio = product
                                            .uploadedVideoFiles!
                                            .recordList[oldIndex];
                                        product.uploadedVideoFiles!.recordList
                                            .removeAt(oldIndex);
                                        product.uploadedVideoFiles!.recordList
                                            .insert(newIndex, audio);
                                      });
                                    },
                                  )
                                : Container();
                          },
                        ),
                ),
              )
            ],
          ),
        ),
        if (processTitle != null)
          Container(
            alignment: Alignment.center,
            color: Colors.black.withOpacity(.8),
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(.7),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 100,
                        spreadRadius: DateTime.now().millisecond % 15)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (processProgress != null)
                    Text(
                      '${processProgress!.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 40,
                          ),
                    ),
                  Text(
                    '$processTitle',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        ),
                  )
                ],
              ),
            ),
          )
      ]),
    );
  }
}

class Capsule extends StatelessWidget {
  const Capsule({Key? key, required this.value}) : super(key: key);
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CircleAvatar(
              child: Icon(
                Icons.check,
                size: 15,
                color: Colors.white,
              ),
              backgroundColor: MyTheme.secondaryColor,
              maxRadius: 13,
            ),
          ),
          Container(
            child: Text(
              value,
              style: TextStyle(fontSize: 11),
            ),
          ),
        ]),
      ),
    );
  }
}

class Caracteristics extends StatelessWidget {
  final String detailsKey;
  final String value;
  Caracteristics(this.detailsKey, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            child: Text(
              detailsKey,
              style:
                  Theme.of(context).textTheme.headline3!.copyWith(fontSize: 16),
            ),
          ),
          Container(
            width: 160,
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: MyTheme.secondaryColor, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

class DetaitsDuBienWidget extends StatelessWidget {
  const DetaitsDuBienWidget({Key? key, required this.icon, required this.value})
      : super(key: key);

  final int value;
  final icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x00FFFFFF),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          icon,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('$value'),
          )
        ],
      ),
    );
  }
}
