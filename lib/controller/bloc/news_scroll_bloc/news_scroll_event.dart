part of 'news_scroll_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class FetchInitialNews extends NewsEvent {
  final NewsCategory category;
  const FetchInitialNews({this.category = NewsCategory.general});

  @override
  List<Object> get props => [category];
}

class FetchNextPage extends NewsEvent {
  final int currentIndex;
  final NewsCategory category;
  const FetchNextPage(this.currentIndex, this.category);

  @override
  List<Object> get props => [currentIndex, category];
}

class UpdateNewsIndex extends NewsEvent {
  final int newIndex;
  const UpdateNewsIndex(this.newIndex);

  @override
  List<Object> get props => [newIndex];
}
