import 'package:inflection2/inflection2.dart';

import 'schema.dart';

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
}

String generateCollection(String rawColName, Collection collection) {
  final colName = SINGULAR.convert(rawColName).inCaps;
  final fieldStatic =
      collection.fields.keys.map(generateFieldStaticKey).join('\n');
  return """class ${colName}Document extends Document{
    ${colName}Doc.fromSnapshot(DocumentSnapshot snapshot){
      overwritefromSnapshot(snapshot);
    }
    static String collectionName = '$colName';
    $fieldStatic
  }""";
}

String generateFieldStaticKey(String fieldName) {
  query(UserDoc(), orderBy: UserFields.bio);
  return "static String ${fieldName}Key = '$fieldName';";
}

class Doc<T> {}

enum UserFields {
  uid,
  userName,
  bio,
}

enum TweetFields {
  tweetText,
  likesSum,
}

class UserDoc extends Doc<UserFields> {}

query<T extends Doc<K>, K>(T doc, {K orderBy, bool descending}) {}
