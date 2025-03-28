import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsai/models/bookmark_repo.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkRepository repository;

  BookmarkBloc(this.repository) : super(BookmarkInitial()) {
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<LoadBookmarksEvent>(_onLoadBookmarks);
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await repository.toggleBookmark(event.article);
      add(LoadBookmarksEvent());
    } catch (e) {
      emit(BookmarkError('Failed to toggle bookmark: $e'));
    }
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarksEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final bookmarks = await repository.getBookmarks();
      emit(BookmarksLoaded(bookmarks));
    } catch (e) {
      emit(BookmarkError('Failed to load bookmarks: $e'));
    }
  }
}
