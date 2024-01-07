import 'dart:typed_data';

import 'package:files/domain/i_storage.dart';
import 'package:files/env.dart';
import 'package:minio/minio.dart';

final class MinioStorage implements IStorage {
  late final Minio minio;

  MinioStorage() {
    minio = Minio(
        port: Env.storagePort,
        endPoint: Env.storageHost,
        accessKey: Env.accessKey,
        secretKey: Env.secretKey,
        useSSL: Env.storageUseSSL);
  }

  @override
  Future<String> putFile(
      {required String bucket,
      required String name,
      required Uint8List data}) async {
    try {
      if (!await minio.bucketExists(bucket)) {
        minio.makeBucket(bucket);
      }
      final tag =
          await minio.putObject(bucket, name, Stream<Uint8List>.value(data));
      return tag;
    } on Object catch (_) {
      rethrow;
    }
  }
}
