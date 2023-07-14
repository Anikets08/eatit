import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookmarkProvider = StateNotifierProvider<BookmarkProvider, List<dynamic>>(
  (ref) => BookmarkProvider(),
);

class BookmarkProvider extends StateNotifier<List<dynamic>> {
  BookmarkProvider() : super([]);

  void addBookmark(String postId) {
    state = [...state, postId];
  }

  void addAllBookmark(List<dynamic> postIds) {
    state = postIds;
  }

  void removeBookmark(String postId) {
    state = state.where((id) => id != postId).toList();
  }
}
