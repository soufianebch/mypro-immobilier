import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as driveApi;
import 'package:file_picker/file_picker.dart';
import 'package:mypro_immobilier/providers/products.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:googleapis_auth/googleapis_auth.dart';
// import 'package:googleapis/youtube/v3.dart' as YT;

class GoogleDrive with ChangeNotifier {
  final _googleSignInWithGoogleDrive =
      GoogleSignIn.standard(scopes: [driveApi.DriveApi.driveFileScope]);//driveApi.DriveApi.driveScope
  GoogleSignInAccount? _googleDriveUser;
  static driveApi.DriveApi? drive;
  // GoogleDrive() {
  //   initialise();
  // }

  initialise() async {
    // if (!await _googleSignInWithGoogleDrive.isSignedIn())
    _googleDriveUser = await _googleSignInWithGoogleDrive.signInSilently();
    await _getDriverApiAccess();
    return this;
  }

  Future<List<String?>?> uploadFilesToGoogleDrive(
      {required List<PlatformFile> files, required Product product}) async {
    if (product.googleDriveFolderId == null)
      product.googleDriveFolderId =
          await createNewDriveFolder('${product.hashtag}');
    final folderId = product.googleDriveFolderId;
    print('uploading files to Google drive..');
    final filesUrl = Stream.fromIterable(files)
        .asyncMap(
          (file) => _uploadFileToGoogleDrive(file, folderId: folderId),
        )
        .toList();
    return await filesUrl;
  }

  Future<driveApi.DriveApi?> _getDriverApiAccess() async {
    try {
      if (_googleDriveUser == null) return null;
      final authHeaders = await _googleDriveUser!.authHeaders;
      final authenticateClient = _GoogleAuthClient(authHeaders);
      final driveApiAccess = driveApi.DriveApi(authenticateClient);
      drive = driveApiAccess;
      return drive;
    } catch (err) {
      print(err.toString());
    }
  }

  Future<String?> createNewDriveFolder(String name) async {
    try {
      await initialise();
      driveApi.File folderToCreate = driveApi.File(
          mimeType: 'application/vnd.google-apps.folder', name: name);
      final response = await drive!.files.create(folderToCreate);
      if (response.id == null) return null;
      // change file permission
      await drive!.permissions.create(
          driveApi.Permission(role: "writer", type: "anyone"), response.id!);

      return response.id;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  Future<String?> _uploadFileToGoogleDrive(PlatformFile file,
      {String? folderId}) async {
    try {
      await initialise();
      driveApi.File fileToUpload = driveApi.File(
        name: file.name,
        // permissions: [driveApi.Permission(role: "writer", type: "anyone")],
      );
      fileToUpload.parents = folderId == null ? null : [folderId];
      final media = driveApi.Media(file.readStream!, file.size);

      //uploading files
      var response = await drive!.files.create(
        fileToUpload,
        uploadMedia: media,
        uploadOptions: driveApi.UploadOptions.resumable,
      );

      if (response.id == null) return null;
      // change file permission
      await drive!.permissions.create(
          driveApi.Permission(role: "writer", type: "anyone"), response.id!);

      print(response.id);
      return ('https://drive.google.com/uc?export=view&id=' + response.id!);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  Future<String?> downloadGoogleDriveFile(
      {required String fNameWithExt,
      required String? gdID,
      Function(double?)? callBack}) async {
    if (gdID == null || gdID.isEmpty) return null;
    await initialise();
    driveApi.Media file = await drive!.files.get(gdID,
        downloadOptions: driveApi.DownloadOptions.fullMedia) as driveApi.Media;
    final directory = await getTemporaryDirectory();
    final saveFile = File(
        '${directory.path}/$fNameWithExt'); //${new DateTime.now().millisecondsSinceEpoch}_
    try {
      double receivedDataLength = 0.0;
      final out = saveFile.openWrite();
      await file.stream.listen(
        (data) {
          receivedDataLength += data.length;
          final progress = receivedDataLength / file.length! * 100;
          callBack?.call(progress);
          out.add(data);
        },
      ).asFuture();
      out.close();
      // List<int> dataStore = [];
      // await file.stream.listen(
      //   (data) {
      //     final progress = dataStore.length / file.length! * 100;
      //     callBack?.call(progress);
      //     dataStore.insertAll(dataStore.length, data);
      //   },
      // ).asFuture();
      // await saveFile.writeAsBytes(dataStore);
      callBack?.call(null);
      return saveFile.path;
    } catch (err) {
      print(err);
      callBack?.call(null);
      return null;
    }
  }

  String? getIdfromLink(String? link) {
    if (link == null || link.isEmpty) return null;
    return link.replaceAll('https://drive.google.com/uc?export=view&id=', '');
  }

  Future<void> deleteFileFromDrive(String? fileId) async {
    if (fileId == null || fileId.isEmpty) return;
    try {
      await initialise();
      return drive?.files.delete(fileId);
    } catch (err) {
      print(err);
    }
  }

  // Future<void> uploadToYoutube() async {
  //   try {
  //     final _googleSignInWithGoogleDrive =
  //         GoogleSignIn.standard(scopes: [YT.YouTubeApi.youtubeScope]);
  //     _googleDriveUser = await _googleSignInWithGoogleDrive.signIn();
  //     if (_googleDriveUser == null) return null;
  //     final authHeaders = await _googleDriveUser!.authHeaders;
  //     final authenticateClient = _GoogleAuthClient(authHeaders);
  //     var youTubeApi = YT.YouTubeApi(authenticateClient);

  //     YT.Video video = new YT.Video();
  //     video.snippet = new YT.VideoSnippet();
  //     video.snippet!.title = "Default Video Title";
  //     video.snippet!.description = "Default Video Description";
  //     video.snippet!.tags = ["tag1", "tag2"];
  //     video.snippet!.categoryId =
  //         "22"; // See https://developers.google.com/youtube/v3/docs/videoCategories/list
  //     video.status = new YT.VideoStatus();
  //     video.status!.privacyStatus = "unlisted"; // or "private" or "public"
  //     final filePickerResult = await FilePicker.platform.pickFiles(
  //         allowMultiple: false, withReadStream: true, type: FileType.video);

  //     Stream<List<int>> stream = filePickerResult!.files.first.readStream!;
  //     int length = await stream.length;
  //     var media = new YT.Media(stream, length);
  //     print('heere');
  //     var videosInsertRequest = await youTubeApi.videos
  //         .insert(video, ["snippet", "status"], uploadMedia: null)
  //         .whenComplete(() => print("COMPLETED"));
  //     print(videosInsertRequest.id);
  //     // videosInsertRequest.timeout(Duration(seconds: 60));
  //     // videosInsertRequest.then((value) => {print("THEN")});
  //     // videosInsertRequest.whenComplete(() => {print("COMPLETED")});
  //     // videosInsertRequest.onError((error, stackTrace) {
  //     //   print("ERROR");
  //     //   return video;
  //     // });
  //     // client.close();
  //   } catch (err) {
  //     print(err);
  //   }
  // }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  _GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
