import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triacore_mobile/models/user.dart';
import 'package:triacore_mobile/services/triacore/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

const String backendUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: "basetria.xyz",
);

@riverpod
UserService userService(Ref ref) {
  return UserService(backendUrl: backendUrl);
}

@riverpod
Future<String?> getUserId(Ref ref) async {
  final service = ref.watch(userServiceProvider);
  final userId = service.getUserId();
}

@riverpod
Future<User?> getUserDetails(Ref ref) async {
  final service = ref.watch(userServiceProvider);
  final userId = service.getUserDetails();
}
