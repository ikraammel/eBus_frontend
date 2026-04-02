class PasswordUtils {
  static String? validatePassword(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return "Les mots de passe ne correspondent pas";
    }

    if (password.length < 8) {
      return "Le mot de passe doit contenir au moins 8 caractères";
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Le mot de passe doit contenir au moins une majuscule";
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return "Le mot de passe doit contenir au moins un chiffre";
    }

    return null;
  }
}