abstract class SignInEvent {
  const SignInEvent();
}

class SignInSubmitted extends SignInEvent {
  final String email;
  final String password;

  const SignInSubmitted({
    required this.email,
    required this.password,
  });
}

class SignInWithGoogleSubmitted extends SignInEvent {
  const SignInWithGoogleSubmitted();
}

class PasswordVisibilityToggled extends SignInEvent {
  const PasswordVisibilityToggled();
}