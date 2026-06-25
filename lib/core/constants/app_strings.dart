class AppStrings {
AppStrings._();

// Dialog Titles
static const String warningTitle = 'Warning';
static const String successTitle = 'Success';
static const String errorTitle = 'Error';
static const String networkErrorTitle = 'Network Error';

// Validation Messages
static const String errorEmptyFields = 'Please fill in all required fields.';
static const String errorInvalidEmail = 'Please enter a valid email address.';
static const String errorPasswordLength = 'Password must be at least 6 characters long.';
static const String errorPasswordMismatch = 'Passwords do not match.';

// Login Messages
static const String successLogin = 'Login successful!';
static const String errorLogin = 'Incorrect email or password.';

// Register Messages
static const String successRegister = 'Account registered successfully!';
static const String errorRegister = 'Unable to register account.';

// General Messages
static const String networkErrorMessage = 'Network connection error. Please check your internet connection and try again.';

// Google Sign-In Messages
static const String errorGoogleSignIn = 'Google Sign-In failed. Please try again.';
static const String successGoogleSignIn = 'Signed in with Google successfully!';
}
