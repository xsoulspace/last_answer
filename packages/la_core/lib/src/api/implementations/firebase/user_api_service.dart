import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/models.dart';
import '../../interfaces/interfaces.dart';

class UserApiRemoteServiceFirebaseImpl implements UserApiService {
  FirebaseFirestore get _store => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _collection =>
      _store.collection('users');
  CollectionReference<UserModel> get _docCollection =>
      _collection.withConverter(
        fromFirestore: UserModel.fromFirestore,
        toFirestore: UserModel.toFirestore,
      );
  @override
  Future<UserModel?> getUserById(final String id) async {
    final ref = _docCollection.doc(id);
    final snapshot = await ref.get();
    return snapshot.data();
  }

  @override
  Future<void> upsertUser(final UserModel model) async {
    await _docCollection.doc(model.remoteId.value).set(model);
  }
}
