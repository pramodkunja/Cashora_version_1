import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/app_colors.dart';

class AttachmentCard extends StatelessWidget {
  final dynamic attachment;
  final int index;

  const AttachmentCard({
    Key? key,
    required this.attachment,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = 'Attachment ${index + 1}';
    String size = 'Unknown';
    XFile? xFile;
    String? url;

    if (attachment is Map) {
      name = attachment['name'] ?? name;
      size = attachment['size']?.toString() ?? size;

      if (attachment['file'] is XFile) {
        xFile = attachment['file'];
        name = xFile?.name ?? name;
      } else {
        url =
            attachment['file'] as String? ??
            attachment['file_url'] as String? ??
            attachment['url'] as String? ??
            attachment['attachment'] as String? ??
            attachment['path'] as String?;
        if (url != null && name == 'Attachment ${index + 1}')
          name = url.split('/').last;
      }
    } else if (attachment is String) {
      url = attachment;
      name = url?.split('/').last ?? name;
    }

    return GestureDetector(
      onTap: () => _handleDownload(xFile, url),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insert_drive_file,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    size,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Optional: Keep download icon or change to "Open" indicator
            const Icon(
              Icons.remove_red_eye,
              size: 20,
              color: AppColors.textSlate,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDownload(XFile? file, String? url) async {
    try {
      if (file != null) {
        if (kIsWeb) {
          await file.saveTo(file.name);
          Get.snackbar(
            'Success',
            'Download started',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          final result = await OpenFile.open(file.path);
          if (result.type != ResultType.done) {
            Get.snackbar(
              'Error',
              'Could not open file: ${result.message}',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      } else if (url != null && url.isNotEmpty) {
        if (kIsWeb) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        } else {
          await _downloadRemoteFile(url);
        }
      } else {
        Get.snackbar(
          'Error',
          'Attachment not available',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to handle attachment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _downloadRemoteFile(String url) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        if (Platform.isAndroid &&
            await Permission.manageExternalStorage.status.isGranted) {
          status = PermissionStatus.granted;
        }
      }

      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) dir = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = await getDownloadsDirectory();
      }

      if (dir == null) {
        Get.snackbar(
          'Error',
          'Could not determine download path',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final fileName = url.split('/').last.split('?').first;
      final savePath = '${dir.path}/$fileName';

      Get.snackbar(
        'Downloading',
        'Downloading $fileName...',
        showProgressIndicator: true,
        snackPosition: SnackPosition.BOTTOM,
      );

      await Dio().download(url, savePath);

      Get.snackbar(
        'Success',
        'Saved to $savePath',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => OpenFile.open(savePath),
          child: const Text(
            'OPEN',
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Download failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
