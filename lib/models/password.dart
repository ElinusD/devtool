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
  Map<String, dynamic> convertToEncryptJson() {
    return {
      'id': id,
      'title': encryptText(title!),
      'login': encryptText(login!),
      'password': encryptText(password!),
      'url': encryptText(url!),
      'comment': encryptText(comment!),
    };
  }

}
