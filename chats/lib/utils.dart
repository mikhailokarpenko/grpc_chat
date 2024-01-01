import 'package:chats/data/chat/chat.dart';
import 'package:chats/env.dart';
import 'package:chats/generated/chats.pb.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class Utils {
  static int getIdFromToken(String token) {
    final jwtClaim = verifyJwtHS256Signature(token, Env.sk);
    final id = int.tryParse(jwtClaim['user_id']);
    if (id == null) throw GrpcError.dataLoss('User ID not found');
    return id;
  }

  static int getIdFromMetadata(ServiceCall call) {
    final accessToken = call.clientMetadata?['access_token'] ?? '';
    return getIdFromToken(accessToken);
  }

  static ListChatsDto convertChats(List<ChatView> list) {
    try {
      return ListChatsDto(chats: [
        ...list.map((chat) => ChatDto(
            authorId: chat.authorId, id: chat.id.toString(), name: chat.name))
      ]);
    } catch (_) {
      rethrow;
    }
  }
}
