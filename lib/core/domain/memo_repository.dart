import '../domain/memo.dart';

/// ドメイン層が定義するリポジトリの抽象インターフェース
/// 具体的な永続化手段（SharedPreferences / Firestore など）には依存しない
abstract interface class MemoRepository {
  Future<void> saveAll(List<Memo> memos);
  List<Memo> fetchAll();
  Future<void> deleteAll();
}
