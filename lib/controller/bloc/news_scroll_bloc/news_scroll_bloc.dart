import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:brevity/controller/bloc/news_scroll_bloc/news_scroll_event.dart';
import 'package:brevity/controller/bloc/news_scroll_bloc/news_scroll_state.dart';
import 'package:brevity/controller/services/news_services.dart';
import 'package:brevity/models/article_model.dart';
import 'package:brevity/models/news_category.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsService newsService;
  int _page = 1;
  bool _hasReachedMax = false;
  final int _pageSize = 10;
  NewsCategory _currentCategory = NewsCategory.general;

  NewsBloc({required this.newsService}) : super(NewsInitial()) {
    on<FetchInitialNews>(_onFetchInitialNews);
    on<FetchNextPage>(_onFetchNextPage);
  }

  Future<void> _onFetchInitialNews(
    FetchInitialNews event,
    Emitter<NewsState> emit,
  ) async {
    try {
      _currentCategory = event.category;
      _page = 1;
      _hasReachedMax = false;

      emit(NewsLoading());
      final articles = await _fetchCategoryNews();
      emit(
        NewsLoaded(
          articles: articles,
          hasReachedMax: articles.length < _pageSize,
          category: _currentCategory,
        ),
      );
    } catch (e) {
      emit(NewsError('Failed to load news: $e'));
    }
  }

  Future<void> _onFetchNextPage(
    FetchNextPage event,
    Emitter<NewsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NewsLoaded ||
        _hasReachedMax ||
        _currentCategory != event.category) {
      return;
    }

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final newArticles = await _fetchCategoryNews(page: _page + 1);

      _hasReachedMax = newArticles.length < _pageSize;
      _page++;

      emit(
        NewsLoaded(
          articles: [...currentState.articles, ...newArticles],
          hasReachedMax: _hasReachedMax,
          isLoadingMore: false,
          category: _currentCategory,
        ),
      );
    } catch (e) {
      emit(NewsError('Failed to load more news: $e'));
    }
  }

  Future<List<Article>> _fetchCategoryNews({int? page}) async {
    switch (_currentCategory) {
      case NewsCategory.technology:
        return newsService.fetchTechnologyNews(page: page ?? _page);
      case NewsCategory.sports:
        return newsService.fetchSportsNews(page: page ?? _page);
      case NewsCategory.entertainment:
        return newsService.fetchEntertainmentNews(page: page ?? _page);
      case NewsCategory.business:
        return newsService.fetchBusinessNews(page: page ?? _page);
      case NewsCategory.health:
        return newsService.fetchHealthNews(page: page ?? _page);
      case NewsCategory.politics:
        return newsService.fetchPoliticsNews(page: page ?? _page);
      default:
        return newsService.fetchGeneralNews(page: page ?? _page);
    }
  }
}
