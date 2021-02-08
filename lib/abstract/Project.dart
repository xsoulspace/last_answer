class Project {
  final int id;
  bool isCompleted;
  String title;

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Project && other.id == id;

  Project({required this.id, required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
        'title': title,
        'isCompleted': isCompleted,
        'id': id,
      };

  Project.fromJson(Map<String, dynamic> m)
      : title = m['title'],
        isCompleted = m['isCompleted'],
        id = m['id'];
}
