import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class DownloadService {
  static final Dio _dio = Dio();
  static CancelToken? _cancelToken;
  static File? _downloadedFile;

  // ================= DOWNLOAD ONLY =================
  static Future<File> downloadApk(
    String apkUrl,
    String appId, {
    required Function(double progress) onProgress,
  }) async {
    _cancelToken = CancelToken();

    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      throw Exception('Storage not available');
    }

    final file = File('${dir.path}/$appId.apk');

    if (file.existsSync()) {
      file.deleteSync();
    }

    await _dio.download(
      apkUrl,
      file.path,
      cancelToken: _cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );

    _downloadedFile = file;
    return file;
  }

  // ================= OPEN INSTALLER =================
  static Future<void> openInstaller() async {
    if (_downloadedFile != null && _downloadedFile!.existsSync()) {
      await OpenFilex.open(_downloadedFile!.path);
    }
  }

  // ================= CANCEL =================
  static Future<void> cancelDownload() async {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }
  }

  // ================= LEGACY SUPPORT (update_dialog.dart) =================
  static Future<void> downloadAndInstall(String apkUrl) async {
    final file = await downloadApk(
      apkUrl,
      "update_temp",
      onProgress: (_) {},
    );

    await OpenFilex.open(file.path);
  }
}
