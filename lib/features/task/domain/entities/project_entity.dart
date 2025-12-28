import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';

class ProjectEntity {
  final String _id;
  final String ownerId;
  final String? parentId;
  final String name;
  final String? description;
  final Color? color;
  final VisirIconType? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? _colorId;
  final bool isEncrypted; // 암호화 여부 플래그

  ProjectEntity({
    required String id,
    required this.ownerId,
    this.parentId,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.createdAt,
    this.updatedAt,
    String? colorId,
    this.isEncrypted = false, // 기본값은 false (기존 데이터 호환)
  }) : _id = id,
       _colorId = colorId;

  bool get isMigrated => _colorId != null && createdAt?.year == 0 && updatedAt?.year == 0;

  bool isParent(String? parentId) => parentId == null ? false : parentId == _id || parentId == _colorId;
  bool isPointedProject(TaskEntity task) => task.projectId == _id || task.projectId == _colorId;
  bool isPointedProjectId(String? projectId) => projectId == null ? false : projectId == _id || projectId == _colorId;
  String get uniqueId => _colorId ?? _id;
  bool get isDefault => ownerId == uniqueId;

  factory ProjectEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    final isEncrypted = json['is_encrypted'] as bool? ?? false;
    // 암호화된 데이터 자동 감지: base64로 디코딩하면 "Salted__"로 시작함
    bool isEncryptedData(String? value) {
      if (value == null || value.isEmpty) return false;
      try {
        final decoded = base64Decode(value);
        return decoded.length >= 8 && String.fromCharCodes(decoded.take(8)) == 'Salted__';
      } catch (e) {
        return false;
      }
    }
    // is_encrypted 플래그가 false여도 실제 데이터가 암호화되어 있으면 복호화 시도
    final shouldDecrypt = local != true && (isEncrypted || isEncryptedData(json['name'] as String?));

    String? decryptField(String? value) {
      if (value == null || value.isEmpty) return value;
      if (!shouldDecrypt) return value;
      // 암호화된 데이터인지 확인
      if (!isEncryptedData(value)) return value;
      try {
        return Utils.decryptAESCryptoJS(value, aesKey);
      } catch (e) {
        return value; // 복호화 실패 시 원본 반환
      }
    }

    return ProjectEntity(
      id: json['id'],
      ownerId: json['owner_id'],
      parentId: json['parent_id'],
      colorId: json['color_id'],
      name: decryptField(json['name'] as String) ?? '',
      description: decryptField(json['description'] as String?),
      color: json['color'] != null ? ColorX.fromHex(json['color']) : null,
      icon: json['icon'] != null ? VisirIconType.values.firstWhere((e) => e.name == json['icon']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isEncrypted: isEncrypted,
    );
  }

  Map<String, dynamic> toJson({bool? local}) {
    String? encryptField(String? value) {
      if (value == null || value.isEmpty) return value;
      if (local == true) return value; // 로컬 저장소는 평문
      return Utils.encryptAESCryptoJS(value, aesKey);
    }

    return {
      'id': _id,
      'owner_id': ownerId,
      'parent_id': parentId,
      'name': encryptField(name) ?? '',
      'description': encryptField(description),
      'color_id': _colorId,
      'color': color?.toHex(),
      'icon': icon?.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_encrypted': local != true, // 로컬이 아니면 암호화됨
    };
  }

  ProjectEntity copyWith({
    required String? parentId,
    required VisirIconType? icon,
    String? id,
    String? ownerId,
    String? name,
    String? description,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? colorId,
    bool? isEncrypted,
  }) {
    return ProjectEntity(
      id: id ?? this._id,
      ownerId: ownerId ?? this.ownerId,
      parentId: parentId,
      name: name ?? this.name,
      description: description ?? this.description,
      colorId: colorId ?? this._colorId,
      color: color ?? this.color,
      icon: icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}

extension ProjectEntityExtension on List<ProjectEntity> {
  List<ProjectEntityWithDepth> get sortedProjectWithDepth {
    final result = <ProjectEntityWithDepth>[];

    List<ProjectEntityWithDepth> getChildProjects(ProjectEntity project, int depth) {
      return this
          .where((e) => project.isParent(e.parentId))
          .map((e) {
            return [ProjectEntityWithDepth(project: e, depth: depth + 1), ...getChildProjects(e, depth + 1)];
          })
          .expand((e) => e)
          .toList();
    }

    for (final project in this) {
      if (project.parentId == null) {
        result.add(ProjectEntityWithDepth(project: project, depth: 0));
        result.addAll(getChildProjects(project, 0));
      }
    }

    return result;
  }
}

class ProjectEntityWithDepth {
  final ProjectEntity project;
  final int depth;

  ProjectEntityWithDepth({required this.project, required this.depth});
}
