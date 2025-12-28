import 'package:json_annotation/json_annotation.dart';

part 'outlook_mail_label.g.dart';

/// Represents a mail folder in a mailbox.
@JsonSerializable()
class OutlookMailLabel {
  /// The folder's unique identifier.
  final String? id;

  /// The folder's display name.
  final String? displayName;

  /// The number of immediate child folders in the folder.
  final int? childFolderCount;

  /// The number of items in the folder.
  final int? totalItemCount;

  /// The number of unread items in the folder.
  final int? unreadItemCount;

  /// The parent folder's ID, or null if it's a root folder.
  final String? parentFolderId;

  final String? wellKnownName;

  OutlookMailLabel({
    this.id,
    this.displayName,
    this.childFolderCount,
    this.totalItemCount,
    this.unreadItemCount,
    this.parentFolderId,
    this.wellKnownName,
  });

  const OutlookMailLabel.empty()
      : id = null,
        displayName = null,
        childFolderCount = null,
        totalItemCount = null,
        unreadItemCount = null,
        wellKnownName = null,
        parentFolderId = null;

  factory OutlookMailLabel.fromJson(Map<String, dynamic> json) => _$OutlookMailLabelFromJson(json);
  Map<String, dynamic> toJson() => _$OutlookMailLabelToJson(this);

  OutlookMailLabel copyWith({
    int? totalItemCount,
    int? unreadItemCount,
    String? parentFolderId,
    String? displayName,
    int? childFolderCount,
    String? id,
    String? wellKnownName,
    List<String>? labelIds,
  }) {
    return OutlookMailLabel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      childFolderCount: childFolderCount ?? this.childFolderCount,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      unreadItemCount: unreadItemCount ?? this.unreadItemCount,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      wellKnownName: wellKnownName ?? this.wellKnownName,
    );
  }
}
