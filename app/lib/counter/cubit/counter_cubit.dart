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
