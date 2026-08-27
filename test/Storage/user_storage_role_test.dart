import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt_club_ua/Storage/UserStorage.dart';

Future<void> _loginWithRoles(List<String> roles) async {
  await UserStorage.clearUserInfo();
  await UserStorage.saveToken('test-token');
  await UserStorage.saveUserInfo({'id': 1, 'roles': roles});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('canEditContent', () {
    test('true for copywriter alone', () async {
      await _loginWithRoles(['copywriter']);
      expect(await UserStorage.canEditContent(), isTrue);
    });

    test('true for head-copywriter alone', () async {
      await _loginWithRoles(['head-copywriter']);
      expect(await UserStorage.canEditContent(), isTrue);
    });

    test('true for admin alone', () async {
      await _loginWithRoles(['admin']);
      expect(await UserStorage.canEditContent(), isTrue);
    });

    test('true for admin combined with copywriter', () async {
      await _loginWithRoles(['admin', 'copywriter']);
      expect(await UserStorage.canEditContent(), isTrue);
    });

    test('false for no roles', () async {
      await _loginWithRoles([]);
      expect(await UserStorage.canEditContent(), isFalse);
    });

    test('false for an unrecognized role string', () async {
      await _loginWithRoles(['some-unknown-role']);
      expect(await UserStorage.canEditContent(), isFalse);
    });

    test('false for editor/user', () async {
      await _loginWithRoles(['editor']);
      expect(await UserStorage.canEditContent(), isFalse);
      await _loginWithRoles(['user']);
      expect(await UserStorage.canEditContent(), isFalse);
    });
  });

  group('canDeleteContent', () {
    test('false for copywriter alone', () async {
      await _loginWithRoles(['copywriter']);
      expect(await UserStorage.canDeleteContent(), isFalse);
    });

    test('true for head-copywriter alone', () async {
      await _loginWithRoles(['head-copywriter']);
      expect(await UserStorage.canDeleteContent(), isTrue);
    });

    test('true for admin alone', () async {
      await _loginWithRoles(['admin']);
      expect(await UserStorage.canDeleteContent(), isTrue);
    });

    test('true for admin combined with copywriter', () async {
      await _loginWithRoles(['admin', 'copywriter']);
      expect(await UserStorage.canDeleteContent(), isTrue);
    });

    test('false for no roles', () async {
      await _loginWithRoles([]);
      expect(await UserStorage.canDeleteContent(), isFalse);
    });

    test('false for an unrecognized role string', () async {
      await _loginWithRoles(['some-unknown-role']);
      expect(await UserStorage.canDeleteContent(), isFalse);
    });
  });
}
