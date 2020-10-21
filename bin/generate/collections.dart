import 'package:inflection2/inflection2.dart';

import 'schema.dart';

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
}

String generateCollection(
  // TODO: cast method di super jadi class childnya (document as TweetDocument)
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

  String generateRequiredTypeFieldName() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      final fieldRequired = field?.isKey == true ? '@required' : '';
      content +=
          '$fieldRequired ${field.toStringFromSchema(schema, collection)} $fieldName,\n';
    });
    return content;
  }

  String generateTypeFieldName() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      content +=
          '${field.toStringFromSchema(schema, collection)} $fieldName,\n';
    });
    return content;
  }

  String generateFromMap() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      final adapter = field?.type?.timestamp != null ? '?.toDate()' : '';
      content += "$fieldName: data['$fieldName']$adapter,\n";
    });
    return content;
  }

  String generateWithDefaultValue() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      String value;
      if (field.sum != null || field.count != null) {
        value = '0';
      } else if (field?.type?.timestamp?.serverTimestamp == true) {
        value = 'DateTime.now()';
      } else {
        value = 'data.$fieldName';
      }
      content += "$fieldName: $value,\n";
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

  String generateToFirestoreCreateMap() {
    String content = '';
    collection.fields.forEach((fieldName, field) {
      if (field.type != null &&
          field?.type?.timestamp?.serverTimestamp == null) {
        content += "'$fieldName': data.$fieldName,";
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
  class _${colName}DocumentData {
    ${generateFinalTypeFieldName()}
    _${colName}DocumentData({
      ${collection.fields.keys.map((e) => 'this.$e,').join('')}
    });
  }
  class ${colName}Document extends Document{
    ${colName}Document({
      ${generateRequiredTypeFieldName()}
    }): data =_${colName}DocumentData(
      ${collection.fields.keys.map((e) => '$e:$e,').join('')}
    );

    final _${colName}DocumentData data;

    @override
    String get collectionName => '$rawColName';

    @override
    ${colName}Document fromMap(Map<String, dynamic> data) {
      return ${colName}Document(
        ${generateFromMap()}
      );
    }

    @override
    ${colName}Document withDefaultValue() {
      return ${colName}Document(
        ${generateWithDefaultValue()}
      );
    }


    @override
    Map<String, dynamic> toDataMap() {
      return {
        ${generateToDataMap()}
      };
    }

    @override
    Map<String, dynamic> toFirestoreCreateMap() {
      return {
        ${generateToFirestoreCreateMap()}
      };
    }


    @override
    bool get shouldBeDeleted => ${generateShouldBeDeleted()};

    @override
    List<String> get keys => [${generateKeys()}];

    @override
    ${colName}Document fromSnapshot(DocumentSnapshot snapshot){
      return super.fromSnapshot(snapshot) as ${colName}Document;
    }

    ${colName}Document copyWith({
      ${generateTypeFieldName()}
    }) {
      return ${colName}Document(
        ${collection.fields.keys.map((e) => '$e: $e ?? this.data.$e,').join()}
      );
    }
  }
  """;
}
