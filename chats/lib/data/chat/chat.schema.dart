// ignore_for_file: annotate_overrides

part of 'chat.dart';

extension ChatRepositories on Database {
  ChatRepository get chats => ChatRepository._(this);
}

abstract class ChatRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<ChatInsertRequest>,
        ModelRepositoryUpdate<ChatUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory ChatRepository._(Database db) = _ChatRepository;

  Future<ChatView?> queryChat(int id);
  Future<List<ChatView>> queryChats([QueryParams? params]);
}

class _ChatRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<ChatInsertRequest>,
        RepositoryUpdateMixin<ChatUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements ChatRepository {
  _ChatRepository(super.db) : super(tableName: 'chats', keyName: 'id');

  @override
  Future<ChatView?> queryChat(int id) {
    return queryOne(id, ChatViewQueryable());
  }

  @override
  Future<List<ChatView>> queryChats([QueryParams? params]) {
    return queryMany(ChatViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(List<ChatInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var values = QueryValues();
    var rows = await db.query(
      'INSERT INTO "chats" ( "name", "author_id" )\n'
      'VALUES ${requests.map((r) => '( ${values.add(r.name)}:text, ${values.add(r.authorId)}:text )').join(', ')}\n'
      'RETURNING "id"',
      values.values,
    );
    var result = rows.map<int>((r) => TextEncoder.i.decode(r.toColumnMap()['id'])).toList();

    return result;
  }

  @override
  Future<void> update(List<ChatUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.query(
      'UPDATE "chats"\n'
      'SET "name" = COALESCE(UPDATED."name", "chats"."name"), "author_id" = COALESCE(UPDATED."author_id", "chats"."author_id")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8::int8, ${values.add(r.name)}:text::text, ${values.add(r.authorId)}:text::text )').join(', ')} )\n'
      'AS UPDATED("id", "name", "author_id")\n'
      'WHERE "chats"."id" = UPDATED."id"',
      values.values,
    );
  }
}

class ChatInsertRequest {
  ChatInsertRequest({
    required this.name,
    required this.authorId,
  });

  final String name;
  final String authorId;
}

class ChatUpdateRequest {
  ChatUpdateRequest({
    required this.id,
    this.name,
    this.authorId,
  });

  final int id;
  final String? name;
  final String? authorId;
}

class ChatViewQueryable extends KeyedViewQueryable<ChatView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "chats".*, "messages"."data" as "messages"'
      'FROM "chats"'
      'LEFT JOIN ('
      '  SELECT "messages"."chat_id",'
      '    to_jsonb(array_agg("messages".*)) as data'
      '  FROM (${MessageViewQueryable().query}) "messages"'
      '  GROUP BY "messages"."chat_id"'
      ') "messages"'
      'ON "chats"."id" = "messages"."chat_id"';

  @override
  String get tableAlias => 'chats';

  @override
  ChatView decode(TypedMap map) => ChatView(
      id: map.get('id'),
      name: map.get('name'),
      authorId: map.get('author_id'),
      messages: map.getListOpt('messages', MessageViewQueryable().decoder) ?? const []);
}

class ChatView {
  ChatView({
    required this.id,
    required this.name,
    required this.authorId,
    required this.messages,
  });

  final int id;
  final String name;
  final String authorId;
  final List<MessageView> messages;
}
