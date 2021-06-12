import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just/just.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          actions: [
            IconButton(
                icon: Icon(Icons.upload_file),
                onPressed: () async {
                  final channel = 'com.mdreamfever.fstar/qiniu';
                  final methodChannel = MethodChannel(channel);
                  ImagePicker picker;
                  switch (getCurrentPlatform()) {
                    case FPlatform.android:
                    case FPlatform.iOS:
                    case FPlatform.web:
                      picker = ImagePicker();
                      break;
                    case FPlatform.fuchsia:
                    case FPlatform.linux:
                    case FPlatform.macOS:
                    case FPlatform.windows:
                      EasyLoading.showError('平台无相关实现');
                      return;
                      break;
                  }

                  ///上传图片首先进行学生身份验证，然后进行权限账号登录
                  ///这里考虑到的是怕有人上传无关图片
                  switch (basenameWithoutExtension(url)) {
                    //上传校车时刻表
                    case 'schoolBus':
                      _uploadFile(
                          context: context,
                          key: 'schoolBus',
                          methodChannel: methodChannel,
                          picker: picker);
                      break;
                    //上传校历
                    case 'schoolCalender':
                      _uploadFile(
                          context: context,
                          key: 'schoolCalender',
                          methodChannel: methodChannel,
                          picker: picker);
                      break;
                  }
                }),
          ],
        ),
        body: PhotoView(
          backgroundDecoration: BoxDecoration(
              color: isDarkMode(context) ? Colors.black : Colors.white),
          filterQuality: FilterQuality.high,
          imageProvider: NetworkImage(
              url + '?timeStamp=${DateTime.now().millisecondsSinceEpoch}'),
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

Future<bool> _autoLogin(BuildContext context) async {
  bool loginSuccess = true;
  EasyLoading.show(status: '请稍等');
  final prefs = await SharedPreferences.getInstance();
  var username = prefs.getString('fstarUsername');
  var password = prefs.getString('fstarPassword');
  if (username == null || password == null) {
    final fstarUserController = TextEditingController();
    final fstarPasswordController = TextEditingController();
    EasyLoading.showToast('请先登录');
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Text(
              '这是繁星内上传文件必要的账号，与学校系统无关',
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromRGBO(240, 240, 240, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: fstarUserController,
              decoration: InputDecoration(
                labelText: '用户名',
                hintText: '必填',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromRGBO(240, 240, 240, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: fstarPasswordController,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '必填',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
      btnOk: ElevatedButton(
        onPressed: () async {
          if (fstarUserController.text.isEmpty ||
              fstarPasswordController.text.isEmpty) {
            EasyLoading.showToast('用户名或密码不能为空');
            return;
          }
          try {
            EasyLoading.show(status: '正在登录');
            var result = await FStarNet().login(
                username: fstarUserController.text.trim(),
                password: fstarPasswordController.text.trim());
            checkResult(result);
            prefs.setString('fstarUsername', fstarUserController.text.trim());
            prefs.setString(
                'fstarPassword', fstarPasswordController.text.trim());
            EasyLoading.dismiss();
            Navigator.pop(context);
          } catch (e) {
            Log.logger.e(e.toString());
            EasyLoading.showError(e.toString());
          }
        },
        child: Text('登录'),
      ),
      btnCancel: ElevatedButton(
        onPressed: () async {
          if (fstarUserController.text.isEmpty ||
              fstarPasswordController.text.isEmpty) {
            EasyLoading.showToast('用户名或密码不能为空');
            return;
          }
          try {
            EasyLoading.show(status: '正在注册');
            var result = await FStarNet().register(
                username: fstarUserController.text.trim(),
                password: fstarPasswordController.text.trim());
            checkResult(result);
            prefs.setString('fstarUsername', fstarUserController.text.trim());
            prefs.setString(
                'fstarPassword', fstarPasswordController.text.trim());
            EasyLoading.dismiss();
            Navigator.pop(context);
          } catch (e) {
            Log.logger.e(e.toString());
            EasyLoading.showError(e.toString());
          }
        },
        child: Text('注册'),
      ),
    ).show();
  }
  try {
    username = prefs.getString('fstarUsername');
    password = prefs.getString('fstarPassword');
    var result = await FStarNet().login(username: username, password: password);
    checkResult(result);
    if (result.data['token'] == null) {
      return false;
    }
    FStarNet().setHeader({
      result.data['tokenHeader']:
          '${result.data['tokenPrefix']} ${result.data['token']}'
    });
    EasyLoading.dismiss();
  } catch (e) {
    EasyLoading.showError(e.toString());
    loginSuccess = false;
  }
  return loginSuccess;
}

void _uploadFile(
    {@required BuildContext context,
    @required String key,
    @required MethodChannel methodChannel,
    @required ImagePicker picker}) async {
  try {
    EasyLoading.show(status: '正在验证身份');
    final userData = getUserData();
    if (userData.jwAccount == null || userData.jwPassword == null) {
      EasyLoading.showError('请先验证教务系统账号再上传');
      return;
    }
    await JUST.instance
        .validate(username: userData.jwAccount, password: userData.jwPassword);
    await Future.delayed(Duration(milliseconds: 500));
    if (!await _autoLogin(context)) {
      EasyLoading.showError('登录失败');
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return;
    }
    EasyLoading.dismiss();
    final image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    EasyLoading.show(status: '正在上传');
    var token = await FStarNet().getUploadToken(key);
    print(token);
    checkResult(token);
    await methodChannel.invokeMethod('upload',
        {'key': key, 'token': token.data, 'data': await image.readAsBytes()});
    EasyLoading.dismiss();
    Navigator.pop(context);
  } catch (e) {
    Log.logger.e(e.toString());
    EasyLoading.showError(e.toString());
  }
}
