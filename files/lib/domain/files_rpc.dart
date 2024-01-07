import 'dart:async';
import 'dart:typed_data';

import 'package:files/domain/i_storage.dart';
import 'package:files/generated/files.pbgrpc.dart';
import 'package:files/utils.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/src/server/call.dart';

const String _avatars = 'avatars';

final class FilesRpc extends FilesRpcServiceBase {
  final IStorage storage;

  FilesRpc(this.storage);

  @override
  Future<ResponseDto> deleteAvatar(ServiceCall call, FileDto request) async {
    try {
      final userId = Utils.getIdFromMetadata(call);
      await storage.deleteFile(bucket: _avatars, name: userId.toString());
      return ResponseDto(isComplete: true, message: 'Avatar deleted');
    } on Object catch (e) {
      throw GrpcError.internal('Avatar is not deleted $e');
    }
  }

  @override
  Future<ResponseDto> deleteFile(ServiceCall call, FileDto request) async {
    _checkFields(request);

    try {
      final String message =
          await storage.deleteFile(bucket: request.bucket, name: request.name);
      return ResponseDto(isComplete: true, message: message);
    } on Object catch (e) {
      throw GrpcError.internal('Delete file is error $e');
    }
  }

  @override
  Future<FileDto> fetchAvatar(ServiceCall call, FileDto request) async {
    final userId = Utils.getIdFromMetadata(call);
    final list = <int>[];
    final stream = storage.fetchFile(bucket: _avatars, name: userId.toString());
    final streamData = await stream.toList();
    for (var element in streamData) {
      list.addAll(element);
    }
    return FileDto(data: Uint8List.fromList(list));
  }

  @override
  Stream<FileDto> fetchFile(ServiceCall call, FileDto request) async* {
    _checkFields(request);

    try {
      yield* storage
          .fetchFile(bucket: request.bucket, name: request.name)
          .transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          final arr = Uint8List.fromList(data);
          sink.add(FileDto(data: arr));
        },
      ));
    } on Object catch (e) {
      throw GrpcError.internal('Fetch file failed with error: $e');
    }
  }

  void _checkFields(FileDto request) {
    if (request.bucket.isEmpty) {
      throw GrpcError.invalidArgument('Bucket argument is empty');
    }
    if (request.name.isEmpty) {
      throw GrpcError.invalidArgument('Name argument is empty');
    }
  }

  @override
  Future<ResponseDto> putAvatar(ServiceCall call, FileDto request) async {
    if (request.data.isEmpty) throw GrpcError.invalidArgument('File is empty');
    if (request.data.length > 1000000) {
      throw GrpcError.invalidArgument('File too large');
    }
    try {
      final userId = Utils.getIdFromMetadata(call);
      final tag = await storage.putFile(
        bucket: _avatars,
        name: userId.toString(),
        data: request.data as Uint8List,
      );
      return ResponseDto(isComplete: true, message: 'Avatar updated', tag: tag);
    } on Object catch (e) {
      throw GrpcError.internal('Avatar not updated $e');
    }
  }

  @override
  Future<ResponseDto> putFile(ServiceCall call, FileDto request) async {
    _checkFields(request);
    if (request.data.isEmpty) throw GrpcError.invalidArgument('File is empty');

    try {
      final tag = await storage.putFile(
          bucket: request.bucket,
          name: request.name,
          data: request.data as Uint8List);
      return ResponseDto(isComplete: true, tag: tag, message: 'File added');
    } on Object catch (e) {
      throw GrpcError.internal('File not added $e');
    }
  }
}
