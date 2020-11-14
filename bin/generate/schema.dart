import 'package:enum_to_string/enum_to_string.dart';

class Schema {
  Map<String, Collection> collections;

  Schema.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> collections = json['collections'];
    this.collections = collections
        .map((key, value) => MapEntry(key, Collection.fromJson(value)));
  }
}

class Collection {
  Map<String, Field> fields;
  Rules rules;

  Collection.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> fields = json['fields'];
    this.fields =
        fields.map((key, value) => MapEntry(key, Field.fromJson(value)));
    rules = Rules.fromJson(json['rules']);
  }
}

class Field {
  FieldType type;
  FieldProperty property;

  Field.fromJson(Map<String, dynamic> json) {
    property = json['property'] != null
        ? FieldProperty.fromJson(json['property'])
        : null;
    type = FieldType.fromJson(json['type']);
  }

  @override
  String toString() {
    if (type != null) {
      return type.toString();
    }
    return '';
  }
}

class FieldProperty {
  bool isUnique;
  bool isOptional;
  bool isComputed;

  FieldProperty.fromJson(Map<String, dynamic> json) {
    isUnique = json['isUnique'];
    isOptional = json['isOptional'];
    isComputed = json['isComputed'];
  }
}

class FieldType {
  StringField string;
  DatetimeField timestamp;
  ReferenceField path;
  IntField int;
  IntField float;
  Sum sum;
  Count count;
  SyncFrom syncFrom;

  FieldType.fromJson(Map<String, dynamic> json) {
    string =
        json['string'] != null ? StringField.fromJson(json['string']) : null;
    timestamp = json['timestamp'] != null
        ? DatetimeField.fromJson(json['timestamp'])
        : null;
    path = json['path'] != null ? ReferenceField.fromJson(json['path']) : null;
    int = json['int'] != null ? IntField.fromJson(json['int']) : null;
    float = json['float'] != null ? IntField.fromJson(json['float']) : null;
    sum = json['sum'] != null ? Sum.fromJson(json['sum']) : null;
    count = json['count'] != null ? Count.fromJson(json['count']) : null;
    syncFrom =
        json['syncFrom'] != null ? SyncFrom.fromJson(json['syncFrom']) : null;
  }

  String toStringFromSchema(Schema schema, Collection thisCollection) {
    if (string != null) {
      return 'String';
    }
    if (timestamp != null) {
      return 'DateTime';
    }
    if (path != null) {
      return 'DocumentReference';
    }
    if (int != null) {
      return 'int';
    }
    if (float != null) {
      return 'double';
    }
    if (syncFrom != null) {
      final targetCollection =
          thisCollection.fields[syncFrom.reference].type.path.collection;
      return schema.collections[targetCollection].fields[syncFrom.field].type
          .toStringFromSchema(schema, thisCollection);
    }
    if (sum != null || count != null) {
      return 'int';
    }
    return '';
  }
}

class StringField {
  bool isOwnerUid;
  int minLength;
  int maxLength;
  bool isKey;

  StringField.fromJson(Map<String, dynamic> json) {
    isOwnerUid = json['isOwnerUid'];
    minLength = json['minLength'];
    maxLength = json['maxLength'];
    isKey = json['isKey'];
  }
}

class DatetimeField {
  bool serverTimestamp;

  DatetimeField.fromJson(Map<String, dynamic> json) {
    serverTimestamp = json['serverTimestamp'];
  }
}

class ReferenceField {
  bool isKey;
  bool isOwnerDocRef;
  String collection;

  ReferenceField.fromJson(Map<String, dynamic> json) {
    isOwnerDocRef = json['isOwnerDocRef'];
    collection = json['collection'];
    isKey = json['isKey'];
  }
}

class IntField {
  bool isOwnerUid;
  int min;
  int max;
  int deleteDocWhen;

  IntField.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
    deleteDocWhen = json['deleteDocWhen'];
  }
}

class Sum {
  String collection;
  String field;
  String reference;

  Sum.fromJson(Map<String, dynamic> json) {
    collection = json['collection'];
    field = json['field'];
    reference = json['reference'];
  }
}

class Count {
  String collection;
  String reference;

  Count.fromJson(Map<String, dynamic> json) {
    collection = json['collection'];
    reference = json['reference'];
  }
}

class SyncFrom {
  String field;
  String reference;

  SyncFrom.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    reference = json['reference'];
  }
}

class Rules {
  Rule get;
  Rule list;
  Rule create;
  Rule update;
  Rule delete;

  Rules.fromJson(Map<String, dynamic> json) {
    get = EnumToString.fromString(Rule.values, json['get']);
    list = EnumToString.fromString(Rule.values, json['list']);
    create = EnumToString.fromString(Rule.values, json['create']);
    update = EnumToString.fromString(Rule.values, json['update']);
    delete = EnumToString.fromString(Rule.values, json['delete']);
  }
}

enum Rule { all, owner, authenticated, none }
