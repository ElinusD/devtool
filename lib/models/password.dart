import '../utils/common.dart';

class Password {
  int? id;
  String? title;
  String? login;
  String? password;
  String? url;
  String? comment;

  Password(
     this.id,
     this.title,
     this.login,
     this.password,
     this.url,
     this.comment
  );

  // Method to convert a Product to JSON
  Map<String, dynamic> convertToJson() {
    return {
      'id': id,
      'title': title,
      'login': login,
      'password': password,
      'url': url,
      'comment': comment,
    };
  }

  // Method to convert a Product to JSON
  Future<Map<String, dynamic>> convertToEncryptJson() async {
    return {
      'id': id,
      'title': await encryptText(title!),
      'login': await encryptText(login!),
      'password': await encryptText(password!),
      'url': await encryptText(url!),
      'comment': await encryptText(comment!),
    };
  }

}
