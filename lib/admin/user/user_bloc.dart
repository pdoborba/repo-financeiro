import 'package:flutter_bloc/flutter_bloc.dart';

import 'repository/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  ///UserBloc
  UserBloc({
    required this.repository,
  }) : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is UserLoad) {
      yield* _mapUserLoadToState();
    }
  }

  Stream<UserState> _mapUserLoadToState() async* {
    try {
      yield UserLoadInProgress();
      var result = await repository.listUsers();
      yield UserLoadSuccess(result);
    } on Exception catch (_) {
      yield UserLoadFailure();
    }
  }
}
