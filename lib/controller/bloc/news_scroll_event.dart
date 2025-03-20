import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();
  
  @override
  List<Object> get props => [];
}

class FetchInitialNews extends NewsEvent {}

class FetchNextPage extends NewsEvent {
  final int currentIndex;
  const FetchNextPage(this.currentIndex);

  @override
  List<Object> get props => [currentIndex];
}