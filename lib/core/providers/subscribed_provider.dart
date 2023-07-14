import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscribedProvider = StateNotifierProvider<SubscribedProvider, List<Map>>(
  (ref) => SubscribedProvider(),
);

class SubscribedProvider extends StateNotifier<List<Map>> {
  SubscribedProvider() : super([]);

  void addOne(String key, String value) {
    state = [
      ...state,
      {key: value}
    ];
  }

  void addAllToList(List<Map> list) {
    state = list;
  }

  void removeOne(String key) {
    state = state.where((element) => element.keys.first != key).toList();
  }
}
