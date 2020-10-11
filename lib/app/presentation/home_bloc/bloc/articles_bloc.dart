import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as get_x;

import '../../../domain/entities/article.dart';
import '../../../domain/usecases/get_local_articles.dart';
import '../../../domain/usecases/get_remote_articles.dart';

import '../../../core/network/network_info.dart';
import '../../../core/errors/failure.dart';

import 'articles_event.dart';
import 'articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  // construct bloc with initial state
  ArticlesBloc(initialState) : super(initialState);

  // get dependencies
  final network = get_x.Get.find<NetworkInfo>();
  final getRemoteArticles = get_x.Get.find<GetRemoteArticles>();
  final getLocalArticles = get_x.Get.find<GetLocalArticles>();

  // state history
  final stateHistory = <ArticlesState>[Initial()];

  @override
  Stream<ArticlesState> mapEventToState(ArticlesEvent event) async* {
    // handle GetData event
    if (event is GetData) {
      yield Loading();
      // check for network connection
      final connectivity = await network.isConnected();
      Either<Failure, List<Article>> failureOrArticles;
      if (connectivity) {
        failureOrArticles = await getRemoteArticles.call();
      } else {
        failureOrArticles = await getLocalArticles.call();
        waitForConnectivityAndNotifyGetDataEvent();
        get_x.Get.snackbar('Offline mode', 'There is no internet connection',
            snackPosition: get_x.SnackPosition.BOTTOM);
      }
      // yield new ArticlesState
      yield failureOrArticles.fold(
          (failure) => Error(failure), (articles) => Success(articles));
    }
  }

  void waitForConnectivityAndNotifyGetDataEvent() {
    StreamSubscription subscription;
    subscription = network.onConnectivityChanged.listen((event) {
      if (event != ConnectivityResult.none) {
        subscription.cancel();
        add(GetData());
      }
    });
  }

  @override
  void onTransition(Transition<ArticlesEvent, ArticlesState> transition) {
    super.onTransition(transition);
    stateHistory.add(transition.nextState);
  }
}