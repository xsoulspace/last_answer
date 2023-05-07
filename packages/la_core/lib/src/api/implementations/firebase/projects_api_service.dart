import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/models.dart';
import '../../interfaces/interfaces.dart';

class ProjectsApiRemoteServiceFirebaseImpl implements ProjectsApiService {
  ProjectsApiRemoteServiceFirebaseImpl();
  FirebaseFirestore get _store => FirebaseFirestore.instance;
  User get _user => FirebaseAuth.instance.currentUser!;
  CollectionReference<Map<String, dynamic>> get _collection =>
      _store.collection('projects').doc(_user.uid).collection('root');

  CollectionReference<ProjectModel> get _docCollection =>
      _collection.withConverter(
        fromFirestore: ProjectModel.fromFirestore,
        toFirestore: ProjectModel.toFirestore,
      );

  @override
  Future<ProjectModel?> getByProjectId(final ProjectModelId remoteId) async {
    final ref = _docCollection.doc(remoteId.value);
    final snapshot = await ref.get();
    return snapshot.data();
  }

  @override
  Query<ProjectModel> get projectQuery =>
      _docCollection.orderBy('completedAt', descending: true);

  @override
  Future<ProjectModel> upsertProject(final ProjectModel model) async {
    ProjectModel? project;
    if (model.remoteId.isNotEmpty) {
      project = await getByProjectId(model.remoteId);
    }
    if (project != null) {
      // update
      await _docCollection.doc(model.remoteId.value).set(model);
    } else {
      // create
      final docRef = await _docCollection.add(model);
      final newRemoteId = docRef.id;
      project = model.copyWith(remoteId: ProjectModelId(value: newRemoteId));
      await _docCollection.doc(newRemoteId).set(project);
    }

    return project;
  }

  @override
  Future<void> deleteProject(final ProjectModel model) async {
    await _docCollection.doc(model.remoteId.value).delete();
  }
}
