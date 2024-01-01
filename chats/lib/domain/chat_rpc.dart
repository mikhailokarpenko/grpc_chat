import 'package:chats/data/chat/chat.dart';
import 'package:chats/data/db.dart';
import 'package:chats/generated/chats.pbgrpc.dart';
import 'package:chats/utils.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/src/server/call.dart';

class ChatRpc extends ChatsRpcServiceBase {
  @override
  Future<ResponseDto> createChat(ServiceCall call, ChatDto request) async {
    final id = Utils.getIdFromMetadata(call);
    if (request.name.isEmpty) {
      throw GrpcError.invalidArgument('Chat name is empty');
    }
    await db.chats.insertOne(
        ChatInsertRequest(name: request.name, authorId: id.toString()));
    return ResponseDto(message: 'Chat created');
  }

  @override
  Future<ResponseDto> deleteChat(ServiceCall call, ChatDto request) {
    // TODO: implement deleteChat
    throw UnimplementedError();
  }

  @override
  Future<ResponseDto> deleteMessage(ServiceCall call, MessageDto request) {
    // TODO: implement deleteMessage
    throw UnimplementedError();
  }

  @override
  Future<ListChatsDto> fetchAllChats(ServiceCall call, RequestDto request) {
    // TODO: implement fetchAllChats
    throw UnimplementedError();
  }

  @override
  Future<ChatDto> fetchChat(ServiceCall call, ChatDto request) {
    // TODO: implement fetchChat
    throw UnimplementedError();
  }

  @override
  Stream<MessageDto> listenChat(ServiceCall call, ChatDto request) {
    // TODO: implement listenChat
    throw UnimplementedError();
  }

  @override
  Future<ResponseDto> sendMessage(ServiceCall call, MessageDto request) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }
}
