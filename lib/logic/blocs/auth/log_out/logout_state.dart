abstract class LogoutState {
  const LogoutState();
}

class LogoutInitial extends LogoutState {
  const LogoutInitial();
}

class LogoutLoading extends LogoutState {
  const LogoutLoading();
}

class LogoutSuccess extends LogoutState {
  final String message;

  const LogoutSuccess({this.message = 'Logged out sucessfully'});
}

class LogoutFailure extends LogoutState {
  final String error;

  const LogoutFailure({required this.error});
}
