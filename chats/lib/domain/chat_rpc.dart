import 'dart:async';
import 'dart:isolate';

import 'package:chats/data/chat/chat.dart';
import 'package:chats/data/db.dart';
import 'package:chats/data/message/message.dart';
import 'package:chats/generated/chats.pbgrpc.dart';
import 'package:chats/utils.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/src/server/call.dart';
import 'package:protobuf/protobuf.dart';
import 'package:stormberry/stormberry.dart';

class ChatRpc extends ChatsRpcServiceBase {
  final StreamController<MessageDto> _streamController =
      StreamController.broadcast();
  @override
  Future<ResponseDto> createChat(ServiceCall call, ChatDto request) async {
    final id = Utils.getIdFromMetadata(call);
    if (request.name.isEmpty) {
      throw GrpcError.invalidArgument('Chat name is empty');
    }
    if (request.memberId.isEmpty) {
      throw GrpcError.invalidArgument('Member id is empty');
    }
    await db.chats.insertOne(ChatInsertRequest(
        name: request.name,
        authorId: id.toString(),
        memberId: request.memberId));
    return ResponseDto(message: 'Chat created');
  }

  @override
  Future<ResponseDto> deleteChat(ServiceCall call, ChatDto request) async {
    final authorId = Utils.getIdFromMetadata(call);
    final chatId = int.tryParse(request.id);
    if (chatId == null) throw GrpcError.invalidArgument('Chat id invalid');
    final chat = await db.chats.queryShortView(chatId);
    if (chat == null) throw GrpcError.notFound('Chat not found');
    if (chat.authorId != authorId.toString()) {
      throw GrpcError.permissionDenied('Only author can delete chat');
    } else {
      await db.chats.deleteOne(chatId);
      return ResponseDto(message: 'Chat deleted');
    }
  }

  @override
  Future<ResponseDto> deleteMessage(
      ServiceCall call, MessageDto request) async {
    final messageId = int.tryParse(request.id);
    if (messageId == null) {
      throw GrpcError.invalidArgument('Message id invalid');
    }
    final message = await db.messages.queryMessage(messageId);
    if (message == null) throw GrpcError.notFound('Message not found');
    final userId = Utils.getIdFromMetadata(call);
    if (message.authorId == userId.toString()) {
      await db.messages.deleteOne(messageId);
      return ResponseDto(message: 'Message deleted');
    } else {
      throw GrpcError.permissionDenied('Only author can delete the message');
    }
  }

  @override
  Future<ListChatsDto> fetchAllChats(
      ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetadata(call);
    final listChats = await db.chats.queryShortViews(QueryParams(
        where: "author_id=@author_id OR member_id=@member_id",
        values: {'author_id': id, 'member_id': id}));
    if (listChats.isEmpty) return ListChatsDto(chats: []);
    return await Isolate.run(() => Utils.convertChats(listChats));
  }

  @override
  Future<ChatDto> fetchChat(ServiceCall call, ChatDto request) async {
    final chatId = int.tryParse(request.id);
    if (chatId == null) throw GrpcError.invalidArgument('Chat id invalid');
    final chat = await db.chats.queryFullView(chatId);
    if (chat == null) throw GrpcError.notFound('Chat not found');
    final userId = Utils.getIdFromMetadata(call);
    if (chat.authorId == userId.toString() ||
        chat.memberId == userId.toString()) {
      return await Isolate.run(() => Utils.convertChatDto(chat));
    } else {
      throw GrpcError.permissionDenied();
    }
  }

  @override
  Stream<MessageDto> listenChat(ServiceCall call, ChatDto request) async* {
    if (request.id.isEmpty) throw GrpcError.invalidArgument('Chat id is empty');
    yield* _streamController.stream
        .where((event) => event.chatId == request.id);
  }

  @override
  Future<ResponseDto> sendMessage(ServiceCall call, MessageDto request) async {
    final authorId = Utils.getIdFromMetadata(call);
    final chatId = int.tryParse(request.chatId);
    if (chatId == null) throw GrpcError.invalidArgument('Chat id invalid');
    final chat = await db.chats.queryShortView(chatId);
    if (chat == null) throw GrpcError.notFound('Chat not found');
    if (request.body.isEmpty) throw GrpcError.invalidArgument('Body is empty');
    final id = await db.messages.insertOne(MessageInsertRequest(
        body: request.body, authorId: authorId.toString(), chatId: chatId));
    _streamController.add(request.deepCopy()
      ..authorId = authorId.toString()
      ..id = id.toString());
    return ResponseDto(message: 'Message sent');
  }
}
