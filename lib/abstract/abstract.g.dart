// GENERATED CODE - DO NOT MODIFY BY HAND

part of abstract;

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnswerAdapter extends TypeAdapter<Answer> {
  @override
  final int typeId = 2;

  @override
  Answer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Answer(
      title: fields[0] as String,
      questionId: fields[1] as String,
      id: fields[3] as String,
      created: fields[4] as DateTime,
      positionIndex: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Answer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.questionId)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.created)
      ..writeByte(5)
      ..write(obj.positionIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 1;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      title: fields[2] as String,
      created: fields[4] as DateTime,
      isCompleted: fields[1] as bool,
      answers: (fields[3] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.answers)
      ..writeByte(4)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IdeaProjectAdapter extends TypeAdapter<IdeaProject> {
  @override
  final int typeId = 4;

  @override
  IdeaProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProject(
      id: fields[0] as String,
      title: fields[2] as String,
      created: fields[3] as DateTime,
      answers: (fields[4] as HiveList?)?.castHiveList(),
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProject obj) {
    writer
      ..writeByte(5)
      ..writeByte(4)
      ..write(obj.answers)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IdeaProjectAnswerAdapter extends TypeAdapter<IdeaProjectAnswer> {
  @override
  final int typeId = 5;

  @override
  IdeaProjectAnswer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProjectAnswer(
      text: fields[4] as String,
      question: fields[5] as IdeaProjectQuestion,
      index: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProjectAnswer obj) {
    writer
      ..writeByte(5)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(5)
      ..write(obj.question)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.created)
      ..writeByte(8)
      ..write(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaProjectAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteProjectAdapter extends TypeAdapter<NoteProject> {
  @override
  final int typeId = 7;

  @override
  NoteProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteProject(
      id: fields[0] as String,
      title: fields[2] as String,
      created: fields[3] as DateTime,
      isCompleted: fields[1] as bool,
      note: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NoteProject obj) {
    writer
      ..writeByte(5)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoryProjectAdapter extends TypeAdapter<StoryProject> {
  @override
  final int typeId = 8;

  @override
  StoryProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryProject(
      id: fields[0] as String,
      title: fields[2] as String,
      created: fields[3] as DateTime,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StoryProject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      id: json['id'] as String,
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
    };

IdeaProjectQuestion _$IdeaProjectQuestionFromJson(Map<String, dynamic> json) =>
    IdeaProjectQuestion(
      id: json['id'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IdeaProjectQuestionToJson(
        IdeaProjectQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

LocalizedText _$LocalizedTextFromJson(Map<String, dynamic> json) =>
    LocalizedText(
      en: json['en'] as String,
      ru: json['ru'] as String,
    );

Map<String, dynamic> _$LocalizedTextToJson(LocalizedText instance) =>
    <String, dynamic>{
      'ru': instance.ru,
      'en': instance.en,
    };
