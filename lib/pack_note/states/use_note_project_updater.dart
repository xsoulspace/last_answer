part of pack_note;

@immutable
class NoteProjectUpdateDto {
  const NoteProjectUpdateDto({
    this.charactersLimitChanged = false,
    this.positionChanged = false,
  });
  final bool positionChanged;
  final bool charactersLimitChanged;
}

NoteProjectUpdaterState useNoteProjectUpdaterState({
  required final ValueNotifier<NoteProject> noteNotifier,
  required final StreamController<NoteProjectUpdateDto> updatesStream,
  required final NoteProjectsNotifier notesNotifier,
  required final CurrentFolderNotifier folderNotifier,
  required final ServerProjectsSyncService projectsSyncService,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useNoteProjectUpdaterState',
        state: NoteProjectUpdaterState(
          noteNotifier: noteNotifier,
          projectsSyncService: projectsSyncService,
          updatesStream: updatesStream,
          folderNotifier: folderNotifier,
          notesNotifier: notesNotifier,
        ),
      ),
    );

class NoteProjectUpdaterState extends ContextfulLifeState {
  NoteProjectUpdaterState({
    required this.folderNotifier,
    required this.notesNotifier,
    required this.noteNotifier,
    required this.updatesStream,
    required this.projectsSyncService,
  });
  final ServerProjectsSyncService projectsSyncService;
  final ValueNotifier<NoteProject> noteNotifier;
  final StreamController<NoteProjectUpdateDto> updatesStream;
  final NoteProjectsNotifier notesNotifier;
  final CurrentFolderNotifier folderNotifier;

  @override
  @mustCallSuper
  void initState() {
    updatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onUpdateByDto);
    super.initState();
  }

  NoteProject get note => noteNotifier.value;
  @mustCallSuper
  // ignore: avoid_positional_boolean_parameters
  Future<void> onUpdateByDto(final NoteProjectUpdateDto dto) async {
    notesNotifier.put(key: note.id, value: note);

    if (dto.positionChanged) {
      note.folder?.sortProjectsByDate(project: note);
      folderNotifier.notify();
    }

    await note.save();
    if (dto.charactersLimitChanged) setState();
    await projectsSyncService.upsert([note]);
  }
}
