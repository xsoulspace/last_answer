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
  final int typeId = 3;

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
      updated: fields[4] as DateTime,
      isCompleted: fields[1] as bool,
      newAnswerText: fields[6] as String,
      newQuestion: fields[7] as IdeaProjectQuestion?,
      answers: (fields[5] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProject obj) {
    writer
      ..writeByte(8)
      ..writeByte(5)
      ..write(obj.answers)
      ..writeByte(6)
      ..write(obj.newAnswerText)
      ..writeByte(7)
      ..write(obj.newQuestion)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.updated);
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
  final int typeId = 4;

  @override
  IdeaProjectAnswer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProjectAnswer(
      text: fields[0] as String,
      question: fields[1] as IdeaProjectQuestion,
      id: fields[2] as String,
      created: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProjectAnswer obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.created);
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

class IdeaProjectQuestionAdapter extends TypeAdapter<IdeaProjectQuestion> {
  @override
  final int typeId = 5;

  @override
  IdeaProjectQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProjectQuestion(
      id: fields[0] as String,
      title: fields[1] as LocalizedText,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProjectQuestion obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaProjectQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalizedTextAdapter extends TypeAdapter<LocalizedText> {
  @override
  final int typeId = 8;

  @override
  LocalizedText read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalizedText(
      en: fields[1] as String,
      ru: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalizedText obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.ru)
      ..writeByte(1)
      ..write(obj.en);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizedTextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteProjectAdapter extends TypeAdapter<NoteProject> {
  @override
  final int typeId = 6;

  @override
  NoteProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteProject(
      id: fields[0] as String,
      created: fields[3] as DateTime,
      updated: fields[4] as DateTime,
      note: fields[5] as String,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoteProject obj) {
    writer
      ..writeByte(5)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.updated);
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
  final int typeId = 7;

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
    )..updated = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, StoryProject obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.updated);
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

Emoji _$EmojiFromJson(Map<String, dynamic> json) => Emoji(
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      keywords: json['keywords'] as String,
    );

Map<String, dynamic> _$EmojiToJson(Emoji instance) => <String, dynamic>{
      'category': instance.category,
      'emoji': instance.emoji,
      'keywords': instance.keywords,
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
