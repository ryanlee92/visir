import 'dart:typed_data';

class MailFileEntity {
  final Uint8List? data;
  final String name;
  final String id;
  final String cid;
  final String mimeType;
  final String? base64String;

  MailFileEntity({required this.name, required this.data, required this.id, required this.cid, required this.mimeType, this.base64String});

  MailFileEntity copyWith({Uint8List? data, String? name, String? id, String? cid, String? mimeType}) {
    return MailFileEntity(
      data: data ?? this.data,
      name: name ?? this.name,
      id: id ?? this.id,
      cid: cid ?? this.cid,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'name': name,
      'id': id,
      'cid': cid,
      'mimeType': mimeType,
    };
  }
}
