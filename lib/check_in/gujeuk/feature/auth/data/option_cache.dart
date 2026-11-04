import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/core/storage/hive_setup.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/data/remote_residence_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/reservation_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/residence_repository.dart';
import 'package:gujeuk_check_in_flutter_v2/check_in/gujeuk/feature/auth/domain/visit_purpose.dart';
import 'package:hive_ce/hive_ce.dart';

/// 마지막으로 받은 목록을 담아 두는 곳. 개인정보가 없어 암호화하지 않습니다.
abstract interface class OptionStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

class HiveOptionStore implements OptionStore {
  static const _boxName = 'gujeuk_options';

  final Future<void> Function() _init;

  HiveOptionStore({this._init = ensureHiveInitialized});

  Future<Box<String>> _opened() async {
    await _init();
    return Hive.openBox<String>(_boxName);
  }

  @override
  Future<String?> read(String key) async => (await _opened()).get(key);

  @override
  Future<void> write(String key, String value) async {
    final box = await _opened();
    await box.put(key, value);
    await box.flush();
  }
}

/// 전체 방문 목적과 그중 예약 시설. 같은 때 받은 한 묶음입니다.
typedef PurposeLists = ({
  List<VisitPurpose> all,
  List<VisitPurpose> reservable,
});

/// 방문 목적, 예약 시설, 거주지를 받아 저장하고, 서버에서 못 받으면 저장본을 돌려줍니다.
/// 저장본도 없으면 예외를 던집니다.
class OptionsLoader {
  /// 화면을 오래 막지 않게 짧게 기다립니다. 미리 받아 둘 때는 쓰지 않습니다.
  static const _screenLimit = Duration(seconds: 3);
  static const _purposesKey = 'purposes';
  static const _residencesKey = 'residences';

  final ReservationRepository _reservations;
  final ResidenceRepository _residences;
  final OptionStore _store;

  const OptionsLoader(this._reservations, this._residences, this._store);

  /// 하나만 새 목록이면 새 예약 시설이 시간 없이 기록될 수 있어, 하나라도 못 받으면 둘 다 저장본을 씁니다.
  Future<PurposeLists> purposeLists() => _load(
    _purposesKey,
    _fetchPurposeLists().timeout(_screenLimit),
    _encodePurposeLists,
    _decodePurposeLists,
  );

  Future<List<String>> residences() => _load(
    _residencesKey,
    _residences.fetchResidences().timeout(_screenLimit),
    jsonEncode,
    (source) => (jsonDecode(source) as List<dynamic>).cast<String>(),
  );

  /// 아무도 화면을 열지 않아도 장애에 대비해 목록을 받아 둡니다.
  /// 실패해도 예외를 던지지 않고, 모두 받았을 때만 true를 돌려줍니다.
  Future<bool> refresh() async {
    final (purposesDone, residencesDone) = await (
      _refresh(_purposesKey, _fetchPurposeLists, _encodePurposeLists),
      _refresh(_residencesKey, _residences.fetchResidences, jsonEncode),
    ).wait;
    return purposesDone && residencesDone;
  }

  Future<PurposeLists> _fetchPurposeLists() async {
    final (all, reservable) = await (
      _reservations.fetchVisitPurposes(),
      _reservations.fetchReservablePurposes(),
    ).wait;
    return (all: all, reservable: reservable);
  }

  Future<bool> _refresh<T>(
    String key,
    Future<T> Function() fetch,
    String Function(T) encode,
  ) async {
    try {
      await _write(key, encode(await fetch()));
      return true;
    } catch (error) {
      debugPrint('options: $key 미리 받기 실패 (${error.runtimeType})');
      return false;
    }
  }

  Future<T> _load<T>(
    String key,
    Future<T> request,
    String Function(T) encode,
    T Function(String) decode,
  ) async {
    final T value;
    try {
      value = await request;
    } catch (_) {
      final cached = await _read(key);
      if (cached == null) rethrow;
      return decode(cached);
    }
    await _write(key, encode(value));
    return value;
  }

  Future<String?> _read(String key) async {
    try {
      return await _store.read(key);
    } catch (error) {
      debugPrint('options: $key 읽기 실패 (${error.runtimeType})');
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _store.write(key, value);
    } catch (error) {
      debugPrint('options: $key 저장 실패 (${error.runtimeType})');
    }
  }

  static String _encodePurposeLists(PurposeLists lists) => jsonEncode({
    'all': [for (final purpose in lists.all) purpose.toJson()],
    'reservable': [for (final purpose in lists.reservable) purpose.toJson()],
  });

  static PurposeLists _decodePurposeLists(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return (
      all: _decodePurposes(json['all'] as List<dynamic>),
      reservable: _decodePurposes(json['reservable'] as List<dynamic>),
    );
  }

  static List<VisitPurpose> _decodePurposes(List<dynamic> json) =>
      json.cast<Map<String, dynamic>>().map(VisitPurpose.fromJson).toList();
}

final optionStoreProvider = Provider<OptionStore>((ref) => HiveOptionStore());

final optionsLoaderProvider = Provider<OptionsLoader>((ref) {
  return OptionsLoader(
    ref.watch(reservationRepositoryProvider),
    ref.watch(residenceRepositoryProvider),
    ref.watch(optionStoreProvider),
  );
});
