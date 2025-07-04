import 'package:brevity/models/news_category.dart';

abstract class NewsEvent {}

class FetchInitialNews extends NewsEvent {
  final NewsCategory category;
  FetchInitialNews({this.category = NewsCategory.general});
}

class FetchNextPage extends NewsEvent {
  final int currentIndex;
  final NewsCategory category;
  FetchNextPage(this.currentIndex, this.category);
}
