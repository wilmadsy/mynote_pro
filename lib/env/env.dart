import 'package:envied/envied.dart';
import 'package:flutter/cupertino.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'APIKEY', obfuscate: true)
  static final String androApiKey = _Env.androApiKey;

  @EnviedField(varName: 'APPID', obfuscate: true)
  static final String androAppId = _Env.androAppId;

  @EnviedField(varName: 'MESSAGING_SENDER_ID', obfuscate: true)
  static final String androMess = _Env.androMess;

  @EnviedField(varName: 'PROJECT_ID', obfuscate: true)
  static final String androProj = _Env.androProj;

  @EnviedField(varName: 'STORAGE_BUCKET', obfuscate: true)
  static final String androStor = _Env.androStor;

  @EnviedField(varName: 'APIKEY_IOS', obfuscate: true)
  static final String iosApiKey = _Env.iosApiKey;

  @EnviedField(varName: 'APPID_IOS', obfuscate: true)
  static final String iosAppId = _Env.iosAppId;

  @EnviedField(varName: 'MESSAGING_SENDER_ID_IOS', obfuscate: true)
  static final String iosMess = _Env.iosMess;

  @EnviedField(varName: 'PROJECT_ID_IOS', obfuscate: true)
  static final String iosProj = _Env.iosProj;

  @EnviedField(varName: 'STORAGE_BUCKET_IOS', obfuscate: true)
  static final String iosStor = _Env.iosStor;

  @EnviedField(varName: 'IOS_BUNDLE_ID_IOS', obfuscate: true)
  static final String iosBundleId = _Env.iosBundleId;
}
