part of 'AppStore.dart';

mixin _$AppStore on AppStoreBase, Store {
  final _$setLanguageAsyncAction = AsyncAction('AppStoreBase.setLanguage');

  @override
  Future<void> setLanguage(String val, {BuildContext? context}) {
    return _$setLanguageAsyncAction
        .run(() => super.setLanguage(val, context: context));
  }

  @override
  String toString() {
    return '''
    ''';
  }
}
