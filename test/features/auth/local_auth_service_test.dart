import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/auth/local_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalAuthService service;
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.create();
    service = LocalAuthService(storage);
  });

  test('registers and logs in a local account', () async {
    final registered = await service.register(
      fullName: 'Darpan Chelani',
      username: 'darpan',
      email: 'darpan@example.com',
      password: 'secret12',
    );

    expect(registered.username, 'darpan');
    expect(
      await service.login(email: 'darpan@example.com', password: 'secret12'),
      isNotNull,
    );
    expect(
      await service.login(email: 'darpan', password: 'secret12'),
      isNotNull,
    );
  });

  test('rejects an incorrect password', () async {
    await service.register(
      fullName: 'Darpan Chelani',
      username: 'darpan',
      email: 'darpan@example.com',
      password: 'secret12',
    );

    expect(
      await service.login(email: 'darpan@example.com', password: 'incorrect'),
      isNull,
    );
  });

  test('keeps multiple local accounts and logs each in separately', () async {
    await service.register(
      fullName: 'Darpan Chelani',
      username: 'darpan',
      email: 'darpan@example.com',
      password: 'secret12',
    );
    await service.register(
      fullName: 'Sara Khan',
      username: 'sara',
      email: 'sara@example.com',
      password: 'secret34',
    );

    expect((await service.getAccounts()).map((item) => item.username), [
      'darpan',
      'sara',
    ]);
    expect(
      (await service.login(
        email: 'darpan@example.com',
        password: 'secret12',
      ))?.username,
      'darpan',
    );
    expect(
      (await service.login(email: 'sara', password: 'secret34'))?.username,
      'sara',
    );
  });

  test('logout clears only the active session', () async {
    await service.register(
      fullName: 'Darpan Chelani',
      username: 'darpan',
      email: 'darpan@example.com',
      password: 'secret12',
    );

    await service.logout();

    expect(await storage.getString(StorageKeys.activeAccountId), isNull);
    expect(await service.getAccounts(), hasLength(1));
    expect(
      await service.login(email: 'darpan@example.com', password: 'secret12'),
      isNotNull,
    );
  });
}
