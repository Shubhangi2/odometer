import 'base_prefs.dart';

class UserPrefs extends BasePrefs {
  // Future<UserModel?> getUserModel() async {
  //   String userModelStr = await getString(Constants.USER_MODEL);
  //   if (userModelStr.isNotEmpty) {
  //     return UserModel.fromJson(jsonDecode(userModelStr));
  //   }
  //   return null;
  // }

  // Future<void> saveUserModel(UserModel userModel) async {
  //   await setString(Constants.USER_MODEL, jsonEncode(userModel.toJson()));
  // }

  // Future<void> logoutUser() async {
  //   bool isUserAgreementDone = await getIsUserAgreementDone();
  //   await clearPrefs();
  //   await setIsUserAgreementDone(isUserAgreementDone);
  // }

  // Future<void> saveUserCredentials({required Credentials credentials}) async {
  //   // await setString(Constants.USERNAME, email);
  //   // await setString(Constants.PASSWORD, password);
  //   await setString(Constants.USER_CREDENTIALS, jsonEncode(credentials.toJson()));
  // }

  // Future<void> saveApiCredentials(Credentials credentials) async {
  //   String apiCredentials = jsonEncode(credentials.toJson());
  //   await setString(Constants.API_CREDENTIALS, apiCredentials);
  // }

  // Future<Credentials> getApiCredentials() async {
  //   String apiCredentialsStr = await getString(Constants.API_CREDENTIALS);
  //   if (apiCredentialsStr.isEmpty) return Credentials(userName: '', password: '');
  //   return Credentials.fromJson(jsonDecode(apiCredentialsStr));
  // }
}
