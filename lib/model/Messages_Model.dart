class Messages_Model {
  Messages_Model({
    required this.msg,
    required this.read,
    required this.fromId,
    required this.toId,
    required this.type,
    required this.sent,
  });
  late final String msg;
  late final String read;
  late final String fromId;
  late final String toId;
  late final String sent;
  late final Type type;

  Messages_Model.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    fromId = json['from_Id'].toString();
    toId = json['to_Id'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['from_Id'] = fromId;
    data['to_Id'] = toId;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
