import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:app/ivs/stage.dart';
import 'package:web/web.dart';

import '../../ivs/ivs.dart';
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0) {
    print('cubit');
    // final strategy = Strategy();
    // final stage = Stage('');
    // print(Stage);
  }

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
