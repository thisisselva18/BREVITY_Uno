import 'package:equatable/equatable.dart';
import 'package:brevity/models/article_model.dart';
import 'package:brevity/models/news_category.dart';

abstract class NewsState extends Equatable {
  const NewsState();
  
  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final NewsCategory category;

  const NewsLoaded({
    required this.articles,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    required this.category,
  });

  NewsLoaded copyWith({
    List<Article>? articles,
    bool? hasReachedMax,
    bool? isLoadingMore,
    NewsCategory? category,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
    );
  }

  @override
  List<Object> get props => [articles, hasReachedMax, isLoadingMore, category];
}

class NewsError extends NewsState {
  final String message;
  const NewsError(this.message);

  @override
  List<Object> get props => [message];
}