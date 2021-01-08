import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:moegirl_plus/api/article.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'compute_md5.dart';

const _rootDirName = 'reading_history';
const _imageDirName = 'images';
const _dataFileName = 'data.json';

class ReadingHistoryManager {
  static Future<void> add(String pageName, [String displayPageName]) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final mainImage = await ArticleApi.getMainImage(pageName, 250)
      .catchError((e) {
        print('获取浏览历史配图失败');
        print(e);
        return null;
      });

    final dataFile = await _getDataFile();
    final List data = jsonDecode(await dataFile.readAsString());
    data.removeWhere((item) => item['pageName'] == pageName);

    var readingHistory = {
      'pageName': pageName,
      'timestamp': timestamp,
      'imgPath': null,
      'displayPageName': displayPageName
    };

    if (mainImage != null) {
      final imgSuffixName = RegExp(r'^.+\.([^\.]+)$').firstMatch(mainImage['source'])[1];
      final imgSavePath = await _createImagePath(pageName, imgSuffixName);
      
      try {
        await Dio().download(mainImage['source'], imgSavePath);
        readingHistory['imgPath'] = imgSavePath;
      } catch(e) {
        print('下载浏览历史配图失败');
        print(e);
      }
    }

    data.insert(0, readingHistory);
    return dataFile.writeAsString(jsonEncode(data));
  }

  static Future<List<ReadingHistory>> getList() async {
    final dataFile = await _getDataFile();
    final data = jsonDecode(await dataFile.readAsString());
    return data.map<ReadingHistory>((item) => ReadingHistory.fromMap(item)).toList();
  }

  static Future<void> clear() async {
    final rootDir = Directory(await _basePath());
    return rootDir.delete(recursive: true);
  }
}

class ReadingHistory {
  String pageName;
  String displayPageName;
  int timestamp;
  String imgPath;

  ReadingHistory({
    this.pageName,
    this.displayPageName,
    this.timestamp,
    this.imgPath
  });

  ReadingHistory.fromMap(Map map) {
    pageName = map['pageName'];
    displayPageName = map['displayPageName'];
    timestamp = map['timestamp'];
    imgPath = map['imgPath'];
  }

  Map toMap() {
    return {
      'pageName': pageName,
      'displayPageName': displayPageName,
      'timestamp': timestamp,
      'imgPath': imgPath
    };
  }
}

Future<String> _basePath() async {
  final docPath = (await getApplicationDocumentsDirectory()).path;
  return p.join(docPath, _rootDirName);
}

Future<String> _createImagePath(String name, String imgSuffixName) async {
  final basePath = await _basePath();
  // final source = SettingsProvider.of(OneContext().context).source;
  return p.join(basePath, _imageDirName, computeMd5(settingsStore.source + name) + '.$imgSuffixName');
}

Future<File> _getDataFile() async {
  final dataFilePath = p.join(await _basePath(), _dataFileName);
  final dataFile = File(dataFilePath);
  final dataFileStat = await dataFile.stat();
  if (dataFileStat.type == FileSystemEntityType.notFound) {
    await dataFile.create(recursive: true);
    await dataFile.writeAsString('[]');
  }

  return dataFile;
}