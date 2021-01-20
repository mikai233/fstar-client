import 'package:flutter/material.dart';
import 'package:fstar/utils/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class UrlImage extends StatelessWidget {
  final String url;
  final String title;

  const UrlImage({Key key, @required this.url, @required this.title})
      : assert(url != null),
        assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: PhotoView(
          backgroundDecoration: BoxDecoration(
              color: isDarkMode(context) ? Colors.black : Colors.white),
          filterQuality: FilterQuality.high,
          imageProvider: NetworkImage(url),
          loadingBuilder: (context, event) {
            if (event == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final value =
                event.cumulativeBytesLoaded / event.expectedTotalBytes;
            final percentage = (100 * value).floor();
            return Center(
              child: Column(
                children: [
                  NeumorphicProgress(
                    percent: value,
                    style: ProgressStyle(
                        variant: Theme.of(context).backgroundColor,
                        accent: Theme.of(context).primaryColor),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(fontSize: 18),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            );
          },
        ),
      );
}
