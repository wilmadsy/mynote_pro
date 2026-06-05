import 'package:envied/envied.dart';
import 'package:flutter/cupertino.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'APIKEY', obfuscate: true)
  static final String androapikey = _Env.androapikey;

  @EnviedField(varName: 'APPID', obfuscate: true)
  static final String androappid = _Env.androappid;

  @EnviedField(varName: 'MESSAGING_SENDER_ID', obfuscate: true)
  static final String andromess = _Env.andromess;

  @EnviedField(varName: 'PROJECT_ID', obfuscate: true)
  static final String androproj = _Env.androproj;

  @EnviedField(varName: 'STORAGE_BUCKET', obfuscate: true)
  static final String androstor = _Env.androstor;

  @EnviedField(varName: 'APIKEY_IOS', obfuscate: true)
  static final String iosapikey = _Env.iosapikey;

  @EnviedField(varName: 'APPID_IOS', obfuscate: true)
  static final String iosappid = _Env.iosappid;

  @EnviedField(varName: 'MESSAGING_SENDER_ID_IOS', obfuscate: true)
  static final String iosmess = _Env.iosmess;

  @EnviedField(varName: 'PROJECT_ID_IOS', obfuscate: true)
  static final String iosproj = _Env.iosproj;

  @EnviedField(varName: 'STORAGE_BUCKET_IOS', obfuscate: true)
  static final String iosstor = _Env.iosstor;

  @EnviedField(varName: 'IOS_BUNDLE_ID_IOS', obfuscate: true)
  static final String iosbundleid = _Env.iosbundleid;
}
