class Message {
  final String? role;
  final String? text;

  Message({this.role, this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      text: json['parts'][0]['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'parts': [
        {
          'text': text,
        },
      ],
    };
  }
}
