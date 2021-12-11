import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mypro_immobilier/shared/my_theme.dart';
import 'package:share_extend/share_extend.dart';

class DisplaySound extends StatelessWidget {
  DisplaySound({
    Key? key,
    required this.audioPlayer,
    this.isPlaying = false,
    this.title = '',
    required this.file,
    this.color,
    this.onDismissed,
    this.onTap,
    this.leadingHeight = 50,
    this.leadingWidth = 50,
  }) : super(key: key);

  final Color? color;
  final double leadingWidth;
  final double leadingHeight;
  final bool isPlaying;
  final AudioPlayer audioPlayer;
  final String title;
  final Map<String, dynamic> file;
  final void Function(DismissDirection)? onDismissed;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        // borderRadius: BorderRadius.circular(30),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: Dismissible(
          key: Key(file['audioPath']),
          direction: DismissDirection.startToEnd,
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.red,
            ),
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.delete,
              color: MyTheme.tertiaryColor,
              size: 30,
            ),
          ),
          onDismissed: onDismissed?.call,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            tileColor: color,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            minLeadingWidth: leadingWidth + 20,
            leading: Container(
              height: leadingHeight,
              width: leadingWidth,
              child: CircleAvatar(
                minRadius: 50,
                child: isPlaying
                    ? Lottie.asset('assets/lottiefiles/audio-playing.zip')
                    : Icon(Icons.play_arrow),
              ),
            ),
            title: Text(title),
            trailing: IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () async {
                ShareExtend.share(file['audioPath'], "audio");
              },
            ),
          ),
        ),
      ),
    );
  }
}
