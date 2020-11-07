import 'package:inflection2/inflection2.dart';

import 'schema.dart';

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
}

String generateCollection(
  Schema schema,
  String rawColName,
  Collection collection,
) {
  final colName = SINGULAR.convert(rawColName).inCaps;
  String generateFinalTypeFieldName() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      content +=
          'final ${field.toStringFromSchema(schema, collection)} $fieldName;\n';
    });
    return content;
  }

  bool isFieldAssignable(Field field) {
    bool isComputed = field?.isComputed ?? false;
    bool isServerTimestamp = field?.type?.timestamp?.serverTimestamp ?? false;
    bool isSum = field?.sum != null;
    bool isCount = field?.count != null;
    return !isComputed && !isServerTimestamp && !isSum && !isCount;
  }

  bool isFieldRequired(Field field) {
    bool isKey = field?.isKey ?? false;
    // bool isReference = field?.type?.path != null;
    return isKey;
    // return isKey || isReference;
  }

  final assignableFields = Map.from(collection.fields)
    ..removeWhere((_, field) => !isFieldAssignable(field));

  String generatePublicConstructorFieldName() {
    return assignableFields
        .map((fieldName, field) {
          final fieldRequired = isFieldRequired(field) ? '@required' : '';
          final fieldString = field.toStringFromSchema(schema, collection);
          return MapEntry(fieldName, '$fieldRequired $fieldString $fieldName,');
        })
        .values
        .join('\n');
  }

  String generatePrivateConstructorFieldName() {
    return collection.fields
        .map((fieldName, field) {
          final fieldString = field.toStringFromSchema(schema, collection);
          return MapEntry(fieldName, '$fieldString $fieldName,');
        })
        .values
        .join('\n');
  }

  String generateTypeFieldName() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      content +=
          '${field.toStringFromSchema(schema, collection)} $fieldName,\n';
    });
    return content;
  }

  String assignString(String fieldName, Field field) {
    if (field?.type?.timestamp != null) {
      return "data['$fieldName'] is DateTime ? data['$fieldName'] : data['$fieldName']?.toDate()";
    } else if (field?.type?.float != null) {
      return "data['$fieldName']?.toDouble()";
    }
    return "data['$fieldName']";
  }

  String generateFromMap() {
    return collection.fields
        .map((fieldName, field) {
          final assign = assignString(fieldName, field);
          return MapEntry(fieldName, "$fieldName: $assign");
        })
        .values
        .join(',');
  }

  String generateWithDefaultValue() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      String value = '';
      if (field.sum != null || field.count != null) {
        value = '0';
      } else if (field?.type?.timestamp?.serverTimestamp == true) {
        value = 'DateTime.now()';
      }
      if (value != '') {
        content += "'$fieldName': $value,\n";
      }
    });
    return content;
  }

  String generateToDataMap() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      content += "'$fieldName': data.$fieldName,";
    });
    return content;
  }

  String firestoreCreateFields() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      if (field.type != null &&
          field?.type?.timestamp?.serverTimestamp == null) {
        content += "'$fieldName',";
      }
    });
    return content;
  }

  String sum() {
    String content = '';
    schema.collections.forEach((cName, c) {
      if (cName != rawColName) {
        c.fields.forEach((fName, f) {
          if (f.sum != null && f.sum.collection == rawColName) {
            content += """Sum(
              field: '${f.sum.field}',
              sumDocument: data.${f.sum.reference},
              sumField: '$fName',
            ),""";
          }
        });
      }
    });
    return content;
  }

  String count() {
    String content = '';
    schema.collections.forEach((cName, c) {
      if (cName != rawColName) {
        c.fields.forEach((fName, f) {
          if (f.count != null && f.count.collection == rawColName) {
            content += """Count(
              countDocument: data.${f.count.reference},
              countField: '$fName',
            ),""";
          }
        });
      }
    });
    return content;
  }

  String generateShouldBeDeleted() {
    String content = 'false';
    collection.fields.forEach((fieldName, field) {
      final deleteDocWhen = field?.type?.int?.deleteDocWhen;
      if (deleteDocWhen != null) {
        content = 'data.$fieldName == $deleteDocWhen';
      }
    });
    return content;
  }

  String generateKeys() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      if (field?.isKey != null) {
        if (field?.type?.string != null) {
          content += "data.$fieldName";
        } else if (field?.type?.path != null) {
          content += "data?.$fieldName?.id,";
        }
      }
    });
    return content;
  }

  return """
  class _${colName}Data {
    _${colName}Data({
      ${collection.fields.keys.map((e) => 'this.$e,').join('')}
    });
    ${generateFinalTypeFieldName()}
  }
  class ${colName} extends Document{
    ${colName}({
      ${generatePublicConstructorFieldName()}
    }): data =_${colName}Data(
      ${assignableFields.keys.map((e) => '$e:$e,').join('')}
    );

    ${colName}._({
      ${generatePrivateConstructorFieldName()}
    }): data =_${colName}Data(
      ${collection.fields.keys.map((e) => '$e:$e,').join('')}
    );

    final _${colName}Data data;

    @override
    String get collectionName => '$rawColName';

    @override
    ${colName} fromMap(Map<String, dynamic> data) {
      return ${colName}._(
        ${generateFromMap()}
      );
    }

    @override
    Map<String, dynamic> get defaultValueMap {
      return {
        ${generateWithDefaultValue()}
      };
    }


    @override
    Map<String, dynamic> toDataMap() {
      return {
        ${generateToDataMap()}
      };
    }

    @override
    List<String> firestoreCreateFields() {
      return [
        ${firestoreCreateFields()}
      ];
    }


    @override
    List<Sum> get sums =>
      [
        ${sum()}
      ];

    @override
    List<Count> get counts =>
      [
        ${count()}
      ];




    @override
    bool get shouldBeDeleted => ${generateShouldBeDeleted()};

    @override
    List<String> get keys => [${generateKeys()}];

    @override
    ${colName} fromSnapshot(DocumentSnapshot snapshot){
      return super.fromSnapshot(snapshot) as ${colName};
    }

    @override
    ${colName} withDefaultValue(){
      return super.withDefaultValue() as ${colName};
    }

    @override
    ${colName} mergeDataWith(Document other){
      return super.mergeDataWith(other) as ${colName};
    }

    ${colName} copyWith({
      ${generateTypeFieldName()}
    }) {
      return ${colName}._(
        ${collection.fields.keys.map((e) => '$e: $e ?? data.$e,').join()}
      );
    }
  }
  """;
}
