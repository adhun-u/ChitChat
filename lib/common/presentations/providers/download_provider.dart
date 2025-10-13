import 'dart:developer';
import 'dart:io';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadProvider extends ChangeNotifier {
  double indication = 0;
  bool isDownloading = false;
  String downloadingFileId = "";
  //Using for cancelling download
  CancelToken _cancelToken = CancelToken();

  //For cancelling the downloading process
  void cancelDownloading() {
    _cancelToken.cancel();
    _cancelToken = CancelToken();
    indication = 0.0;
    downloadingFileId == "";
    isDownloading = false;
    notifyListeners();
  }

  //For downloading a files
  Future<Either<String?, ErrorMessageModel?>> downloadAndSaveFile({
    required String fileUrl,
    required String chatId,
    required String fileType,
  }) async {
    downloadingFileId = chatId;
    notifyListeners();
    try {
      isDownloading = true;
      notifyListeners();
      final Directory dir = await getApplicationDocumentsDirectory();
      final String pathToDownload = "${dir.path}/media/$fileType/$chatId";
      await Dio().download(
        fileUrl,
        pathToDownload,
        cancelToken: _cancelToken,
        onReceiveProgress: (progress, total) {
          indication = progress / total;
          notifyListeners();
        },
      );
      isDownloading = false;
      notifyListeners();
      return left(pathToDownload);
    } catch (e) {
      log("Download Err : $e");
      isDownloading = false;
      indication = 0.0;
      downloadingFileId = "";
      notifyListeners();
      return right(
        ErrorMessageModel(message: 'An error occured while downloading'),
      );
    }
  }
}
