import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/network/api_client.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/data/remote_visitor_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/info_check/domain/visitor_repository.dart';

final visitorRepositoryProvider = Provider<VisitorRepository>((ref) {
  return RemoteVisitorRepository(ref.watch(apiClientProvider));
});
