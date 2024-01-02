import 'dart:isolate';

import 'package:auth/data/db.dart';
import 'package:auth/data/user/user.dart';
import 'package:auth/env.dart';
import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:auth/utils.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/src/server/call.dart';
import 'dart:async';

import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:stormberry/stormberry.dart';

class AuthRpc extends AuthRpcServiceBase {
  @override
  Future<ResponseDto> deleteUser(ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetadata(call);
    await db.users.deleteOne(id);
    return ResponseDto(message: 'User deleted');
  }

  @override
  Future<UserDto> fetchUser(ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetadata(call);
    final user = await db.users.queryUser(id);
    if (user == null) throw GrpcError.notFound('User not found');
    return Utils.convertUserDto(user);
  }

  @override
  Future<TokensDto> refreshToken(ServiceCall call, TokensDto request) async {
    if (request.refreshToken.isEmpty) {
      throw GrpcError.invalidArgument('Refresh token not found');
    }
    final id = Utils.getIdFromToken(request.refreshToken);
    final user = await db.users.queryUser(id);
    if (user == null) throw GrpcError.notFound('User not found');
    return _createTokens(user.id);
  }

  @override
  Future<TokensDto> signIn(ServiceCall call, UserDto request) async {
    if (request.email.isEmpty) {
      throw GrpcError.invalidArgument('Email not found');
    }
    if (request.password.isEmpty) {
      throw GrpcError.invalidArgument('Password not found');
    }

    final hashPassword = Utils.getHashPassword(request.password);
    final users = await db.users.queryUsers(QueryParams(
        where: "email=@email",
        values: {'email': Utils.encryptField(request.email)}));
    if (users.isEmpty) throw GrpcError.notFound('User not found');
    final user = users.first;
    if (hashPassword != user.password) {
      throw GrpcError.unauthenticated('Password is wrong');
    }

    return _createTokens(user.id);
  }

  @override
  Future<TokensDto> signUp(ServiceCall call, UserDto request) async {
    if (request.email.isEmpty) {
      throw GrpcError.invalidArgument('Email not found');
    }
    if (request.password.isEmpty) {
      throw GrpcError.invalidArgument('Password not found');
    }
    if (request.username.isEmpty) {
      throw GrpcError.invalidArgument('Username not found');
    }

    final id = await db.users.insertOne(UserInsertRequest(
        username: request.username,
        email: Utils.encryptField(request.email),
        password: Utils.getHashPassword(request.password)));

    return _createTokens(id);
  }

  @override
  Future<UserDto> updateUser(ServiceCall call, UserDto request) async {
    final id = Utils.getIdFromMetadata(call);
    await db.users.updateOne(UserUpdateRequest(
        id: id,
        username: request.username.isEmpty ? null : request.username,
        email: request.email.isEmpty ? null : Utils.encryptField(request.email),
        password: request.password.isEmpty
            ? null
            : Utils.getHashPassword(request.password)));
    final user = await db.users.queryUser(id);
    if (user == null) throw GrpcError.notFound('User not found');
    return Utils.convertUserDto(user);
  }

  TokensDto _createTokens(int id) {
    final accessTokenSet = JwtClaim(
        maxAge: Duration(hours: Env.accessTokenLife),
        otherClaims: {'user_id': id.toString()});
    final refreshTokenSet = JwtClaim(
        maxAge: Duration(hours: Env.refreshTokenLife),
        otherClaims: {'user_id': id.toString()});

    return TokensDto(
        accessToken: issueJwtHS256(accessTokenSet, Env.sk),
        refreshToken: issueJwtHS256(refreshTokenSet, Env.sk));
  }

  @override
  Future<ListUsersDto> findUser(ServiceCall call, FindDto request) async {
    final limit = int.tryParse(request.limit) ?? 100;
    final offset = int.tryParse(request.offset) ?? 0;
    final key = request.key;
    if (key.isEmpty) return ListUsersDto(users: []);
    final query = "username LIKE '%$key%'";
    final usersList = await db.users.queryUsers(QueryParams(
        limit: limit, offset: offset, orderBy: 'username', where: query));
    return await Isolate.run(() => Utils.convertUsersDto(usersList));
  }
}
