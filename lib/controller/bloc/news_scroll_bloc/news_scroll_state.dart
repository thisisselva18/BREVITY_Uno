part of 'news_scroll_bloc.dart';

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
  final int currentIndex;

  const NewsLoaded({
    required this.articles,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    required this.category,
    this.currentIndex = 0,
  });

  NewsLoaded copyWith({
    List<Article>? articles,
    bool? hasReachedMax,
    bool? isLoadingMore,
    NewsCategory? category,
    int? currentIndex,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [
    articles,
    hasReachedMax,
    isLoadingMore,
    category,
    currentIndex,
  ];
}

class NewsError extends NewsState {
  final String message;
  const NewsError(this.message);

  @override
  List<Object> get props => [message];
}