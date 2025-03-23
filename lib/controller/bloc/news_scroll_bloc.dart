import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:newsai/controller/bloc/news_scroll_event.dart';
import 'package:newsai/controller/bloc/news_scroll_state.dart';
import 'package:newsai/controller/services/news_services.dart';


class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsService newsService;
  int _page = 1;
  bool _hasReachedMax = false;
  final int _pageSize = 10;

  NewsBloc({required this.newsService}) : super(NewsInitial()) {
    on<FetchInitialNews>(_onFetchInitialNews);
    on<FetchNextPage>(_onFetchNextPage);
  }

  Future<void> _onFetchInitialNews(
    FetchInitialNews event,
    Emitter<NewsState> emit,
  ) async {
    try {
      emit(NewsLoading());
      final articles = await newsService.fetchGeneralNews(page: 1, pageSize: _pageSize);
      emit(NewsLoaded(
        articles: articles,
        hasReachedMax: articles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError('Failed to load news: $e'));
    }
  }

  Future<void> _onFetchNextPage(
    FetchNextPage event,
    Emitter<NewsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NewsLoaded || _hasReachedMax) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));
      
      final newArticles = await newsService.fetchGeneralNews(
        page: _page + 1,
        pageSize: _pageSize,
      );

      _hasReachedMax = newArticles.length < _pageSize;
      _page++;

      emit(NewsLoaded(
        articles: [...currentState.articles, ...newArticles],
        hasReachedMax: _hasReachedMax,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(NewsError('Failed to load more news: $e'));
    }
  }

  bool shouldLoadMore(int currentIndex) {
    return currentIndex >= (state as NewsLoaded).articles.length - 3;
  }
}