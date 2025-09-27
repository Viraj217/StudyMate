class Note {
  String title;
  DateTime date;
  String content;
  
  Note({
    required this.title,
    required this.date,
    required this.content,
  });
  
  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'content': content,
    };
  }
  
  // Create from Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      date: DateTime.parse(map['date']),
      content: map['content'],
    );
  }
}