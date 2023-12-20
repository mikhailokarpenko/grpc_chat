import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:grpc/src/server/call.dart';

class AuthRpc extends AuthRpcServiceBase {
  @override
  Future<ResponseDto> deleteUser(ServiceCall call, RequestDto request) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<UserDto> fetchUser(ServiceCall call, RequestDto request) {
    // TODO: implement fetchUser
    throw UnimplementedError();
  }

  @override
  Future<TokensDto> refreshToken(ServiceCall call, TokensDto request) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<TokensDto> signIn(ServiceCall call, UserDto request) {
    return Future(() => TokensDto(accessToken: "test", refreshToken: "test"));
  }

  @override
  Future<TokensDto> signUp(ServiceCall call, UserDto request) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<UserDto> updateUser(ServiceCall call, UserDto request) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}
