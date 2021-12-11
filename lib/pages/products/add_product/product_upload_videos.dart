import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mypro_immobilier/components/videoPlayer.dart';
import 'package:mypro_immobilier/providers/google_drive.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:mypro_immobilier/providers/uploaded_videos.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wakelock/wakelock.dart';

class UploadVideosScreen extends StatefulWidget {
  static const routeName = 'upload-product-video';

  @override
  _UploadVideosScreenState createState() => _UploadVideosScreenState();
}

class _UploadVideosScreenState extends State<UploadVideosScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleDrive googleDrive;

  late Product product;
  Function? submit;
  bool isUploading = false;
  Map<String, Object?>? selectedVideo;
  bool isSharing = false;
  bool init = true;

  @override
  void didChangeDependencies() {
    if (init) {
      googleDrive = Provider.of<GoogleDrive>(context);
      product = ModalRoute.of(context)!.settings.arguments as Product;
      product.uploadedVideoFiles =
          product.uploadedVideoFiles ?? UploadedVideoFiles();
      init = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    product.uploadedVideoFiles!.flutterFFmpeg
        .listExecutions()
        .then((listExecutions) {
      if (listExecutions.length > 0)
        product.uploadedVideoFiles!.flutterFFmpeg.cancel();
    });
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
            'Videos',
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
              child: isUploading
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: SpinKitThreeBounce(
                        color: Colors.black,
                        size: 20,
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        setState(() {
                          isUploading = true;
                          Wakelock.enable();
                        });
                        try {
                          if (product.uploadedVideoFiles!.isListChanged(
                              product.uploadedVideoFiles!.mainVideos)) {
                            // mainVideo
                            await product.uploadedVideoFiles!.addPadding(
                              videos: product.uploadedVideoFiles!.mainVideos,
                              callBack: () => setState(() {}),
                            );
                            await product.uploadedVideoFiles!.downloadVideos(
                              videos: product.uploadedVideoFiles!.mainVideos,
                              callBack: () => setState(() {}),
                            );
                            var result =
                                await product.uploadedVideoFiles!.concat(
                              videos: product.uploadedVideoFiles!.mainVideos,
                              name: 'mainVideo',
                              removeSound: true,
                            );
                            if (result != null) {
                              final videoFile = File(result);
                              final uploadedVideoLink =
                                  await googleDrive.uploadFilesToGoogleDrive(
                                files: [
                                  PlatformFile.fromMap(
                                    {
                                      'path': videoFile.path,
                                      'name': videoFile.path.split('/').last,
                                      'size': await videoFile.length(),
                                    },
                                    readStream: videoFile.openRead(),
                                  )
                                ],
                                product: product,
                              );

                              try {
                                if (product.mainVideo != null) {
                                  print(
                                      'deleting old mainVideo ${product.mainVideo}');
                                  await googleDrive.deleteFileFromDrive(
                                    googleDrive
                                        .getIdfromLink(product.mainVideo!),
                                  );
                                  product.mainVideo = null;
                                }
                              } catch (err) {
                                print(err);
                              }
                              print('New mainVideo: $uploadedVideoLink');
                              if (uploadedVideoLink != null)
                                product.mainVideo = uploadedVideoLink[0]!;
                            }
                          }
                          // introVideo
                          if (product.uploadedVideoFiles!.isListChanged(
                              product.uploadedVideoFiles!.introVideos)) {
                            await product.uploadedVideoFiles!.scale(
                              videos: product.uploadedVideoFiles!.introVideos,
                              callBack: () => setState(() {}),
                            );
                            await product.uploadedVideoFiles!.downloadVideos(
                              videos: product.uploadedVideoFiles!.introVideos,
                              callBack: () => setState(() {}),
                            );

                            final result =
                                await product.uploadedVideoFiles!.concat(
                              videos: product.uploadedVideoFiles!.introVideos,
                              name: 'introVideo',
                            );
                            if (result != null) {
                              final videoFile = File(result);
                              final uploadedVideoLink =
                                  await googleDrive.uploadFilesToGoogleDrive(
                                files: [
                                  PlatformFile.fromMap(
                                    {
                                      'path': videoFile.path,
                                      'name': videoFile.path.split('/').last,
                                      'bytes': await videoFile.readAsBytes(),
                                      'size': await videoFile.length(),
                                    },
                                    readStream:
                                        videoFile.readAsBytes().asStream(),
                                  )
                                ],
                                product: product,
                              );

                              try {
                                if (product.introVideo != null) {
                                  print(
                                      'deleting old introVideo ${product.introVideo}');
                                  await googleDrive.deleteFileFromDrive(
                                    googleDrive
                                        .getIdfromLink(product.introVideo!),
                                  );
                                  product.introVideo = null;
                                }
                              } catch (err) {
                                print(err);
                              }
                              print('New introVideo: $uploadedVideoLink');
                              if (uploadedVideoLink != null)
                                product.introVideo = uploadedVideoLink[0]!;
                            }
                          }

                          await ProductsRecord().addProduct(product);
                          setState(() {
                            isUploading = false;
                            Wakelock.disable();
                          });
                          FilePicker.platform.clearTemporaryFiles();
                          submit?.call();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        } catch (err) {
                          print(err);
                          setState(() {
                            isUploading = false;
                            Wakelock.disable();
                          });
                        }
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
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () async {
                if (selectedVideo != null) {
                  if ((selectedVideo!['videoPath'] as String).contains('http'))
                    await product.uploadedVideoFiles!.downloadVideos(
                      videos: [selectedVideo!],
                      callBack: () => setState(() {}),
                    );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrimmerView(
                        uploadedVideoFiles: product.uploadedVideoFiles!,
                        videoPath: selectedVideo!['videoPath'] as String,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  image: selectedVideo == null
                      ? null
                      : DecorationImage(
                          image: MemoryImage(
                              selectedVideo!['thumbnail'] as Uint8List),
                        ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_arrow,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    icon: isSharing
                        ? Padding(
                            padding: EdgeInsets.all(5),
                            child: CircularProgressIndicator(),
                          )
                        : Icon(Icons.share),
                    onPressed: () async {
                      if (selectedVideo != null && !isSharing) {
                        setState(() {
                          isSharing = true;
                        });
                        try {
                          if ((selectedVideo!['videoPath'] as String)
                              .contains('http'))
                            await product.uploadedVideoFiles!.downloadVideos(
                              videos: [selectedVideo!],
                              callBack: () => setState(() {}),
                            );

                          ShareExtend.share(
                              '${selectedVideo!['videoPath']}', "video");
                        } catch (err) {
                          print(err);
                        }
                        setState(() {
                          isSharing = false;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      if (selectedVideo != null)
                        await showDialog(
                          context: context,
                          builder: (alertDialogContext) {
                            return AlertDialog(
                              title: Text('Delete video!'),
                              content: Text(
                                  'Do you really want to delete this video?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      if ('${selectedVideo!['driveLink']}'
                                          .contains('http')) {
                                        await googleDrive.deleteFileFromDrive(
                                          googleDrive.getIdfromLink(
                                            '${selectedVideo!['driveLink']}',
                                          ),
                                        );
                                        if ('${selectedVideo!['location']}' ==
                                            'MainVideos')
                                          product.mainVideo = '';

                                        if ('${selectedVideo!['location']}' ==
                                            'IntroVideos')
                                          product.introVideo = '';
                                      }
                                      if ('${selectedVideo!['location']}' ==
                                          'MainVideos')
                                        product.uploadedVideoFiles!.mainVideos
                                            .remove(product
                                                .uploadedVideoFiles!.mainVideos
                                                .firstWhere((video) =>
                                                    '${video['videoPath']}' ==
                                                    selectedVideo![
                                                        'videoPath']));
                                      else if ('${selectedVideo!['location']}' ==
                                          'IntroVideos')
                                        product.uploadedVideoFiles!.introVideos
                                            .remove(product
                                                .uploadedVideoFiles!.introVideos
                                                .firstWhere((video) =>
                                                    '${video['videoPath']}' ==
                                                    selectedVideo![
                                                        'videoPath']));
                                      if ('${selectedVideo!['driveLink']}'
                                          .contains('http'))
                                        product.changed = true;
                                        product.reference
                                            ?.update(product.toMap());
                                      setState(() => selectedVideo = null);
                                      Navigator.pop(alertDialogContext);
                                    } catch (err) {
                                      print(err);
                                    }
                                  },
                                  child: Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 20, bottom: 20),
              child: Text(
                'Main video:',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            VideosListView(
              uploadedVideos: product.uploadedVideoFiles!.mainVideos,
              callBack: (Map<String, Object?> video) => setState(() {
                selectedVideo = video;
                selectedVideo?['location'] = 'MainVideos';
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 20, bottom: 20),
              child: Text(
                'Intro video:',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            VideosListView(
              uploadedVideos: product.uploadedVideoFiles!.introVideos,
              callBack: (Map<String, Object?> video) => setState(() {
                selectedVideo = video;
                selectedVideo?['location'] = 'IntroVideos';
              }),
            )
          ],
        ),
      )),
    );
  }
}

class VideosListView extends StatefulWidget {
  VideosListView({
    Key? key,
    required this.uploadedVideos,
    // required this.selectedVideo,
    this.callBack,
  }) : super(key: key);
  final List<Map<String, Object?>> uploadedVideos;
  // final Map<String, Object?>? selectedVideo;
  final Function(Map<String, Object?>)? callBack;

  @override
  _VideosListViewState createState() => _VideosListViewState();
}

class _VideosListViewState extends State<VideosListView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  key: ValueKey('uploadVideoButton'),
                  onTap: () async {
                    setState(() => isLoading = true);
                    try {
                      final pickFileResult =
                          await FilePicker.platform.pickFiles(
                        allowCompression: true,
                        withData: false,
                        // withReadStream: true,
                        allowMultiple: true,
                        type: FileType.video,
                      );
                      if (pickFileResult != null) {
                        List<PlatformFile> videosfiles = pickFileResult.files;

                        //uploading files...
                        for (var i = 0; i < videosfiles.length; i++) {
                          setState(() => isLoading = true);
                          // final result =
                          //     await googleDrive.uploadFilesToGoogleDrive(
                          //   files: [videosfiles[i]],
                          //   folderId: product.googleDriveFolderId,
                          // );
                          // final result = ['video $i'];
                          // if (result != null) {
                          // product.videos = product.videos ?? [];
                          // product.videos!.add(result[0]);
                          widget.uploadedVideos.add({
                            'videoPath': videosfiles[i].path,
                            'videoName': videosfiles[i].name,
                            // 'link': result[0],
                            'thumbnail': await VideoThumbnail.thumbnailData(
                              video: videosfiles[i].path ?? '',
                              timeMs: 200,
                              imageFormat: ImageFormat.JPEG,
                              maxWidth:
                                  700, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                              quality: 25,
                            ),

                            'progressPercentage': null,
                            'changed': true,
                            'hasPadding': false,
                          });
                        }
                        setState(() => isLoading = false);
                      }
                    } catch (err) {
                      print(err);
                    }
                    setState(() => isLoading = false);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFFEEEEEE),
                    ),
                    child: isLoading
                        ? Container(
                            padding: EdgeInsets.all(40),
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator())
                        : Icon(
                            Icons.video_call,
                            color: Colors.black,
                            size: 40,
                          ),
                  ),
                ),
                Expanded(
                  // width: MediaQuery.of(context).size.width,
                  child: ReorderableListView.builder(
                    padding: EdgeInsets.all(8),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        key: Key('vd-$index'),
                        onTap: () {
                          widget.callBack?.call(widget.uploadedVideos[index]);
                          setState(() {});
                        },
                        child: Container(
                          width: 120,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              color: Color(0xFFEEEEEE),
                              image: DecorationImage(
                                  image: MemoryImage(
                                      widget.uploadedVideos[index]['thumbnail']
                                          as Uint8List))),
                          child: widget.uploadedVideos[index]
                                      ['progressPercentage'] !=
                                  null
                              ? Container(
                                  color: Colors.black.withAlpha(180),
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          '${(widget.uploadedVideos[index]['progressPercentage'] as double?)!.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                              color: MyTheme.primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SpinKitDualRing(
                                            lineWidth: 4.0,
                                            color: MyTheme.primaryColor),
                                      ]),
                                )
                              : null,
                        ),
                      );
                    },
                    itemCount: widget.uploadedVideos.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      setState(() {
                        final video = widget.uploadedVideos[oldIndex];
                        widget.uploadedVideos.removeAt(oldIndex);
                        widget.uploadedVideos.insert(newIndex, video);
                      });
                    },
                  ),
                ),
              ])),
    );
  }
}
