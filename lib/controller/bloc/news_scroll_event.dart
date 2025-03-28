// import 'package:equatable/equatable.dart';
import 'package:newsai/models/news_category.dart';
// abstract class NewsEvent extends Equatable {
//   const NewsEvent();

//   @override
//   List<Object> get props => [];
// }

// class FetchInitialNews extends NewsEvent {}

// class FetchNextPage extends NewsEvent {
//   final int currentIndex;
//   const FetchNextPage(this.currentIndex);

//   @override
//   List<Object> get props => [currentIndex];
// }
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
