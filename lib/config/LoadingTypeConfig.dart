enum LoadingType { public, standard }

class LoadingTypeConfig {
  static LoadingType type = LoadingType.standard;

  static bool get isStandard => type == LoadingType.standard;
  // static bool get isStandard => false;


  // Приклад обмеження функцій
  static bool get hasClickingOnLink => isStandard;
  static bool get hasDeletedAccount => isStandard;
  static bool get showFinanceScreen => isStandard;
  static bool get showProfileEditPage => isStandard;
  static bool get hasFaFA => isStandard;
  static bool get hasLogout=> isStandard;
  static bool get hasChangePhoto => isStandard;

  static String personalInformationMask(String? realValue, {String defaultValue = '---'}) {
    if (isStandard) {
      return realValue ?? defaultValue;
    }
    return defaultValue;
  }


}