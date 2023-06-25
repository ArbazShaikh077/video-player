import 'package:flutter_bloc/flutter_bloc.dart';

class DurationBloc extends Cubit<double?>{
  DurationBloc() : super(null);

  void updateTheDuration(double duration){
    emit(duration);
  }
  
}