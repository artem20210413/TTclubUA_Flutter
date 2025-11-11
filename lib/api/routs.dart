
// const _HOST = 'https://tt.tishchenko.kiev.ua';
const _HOST = 'https://ttclub.com.ua';

Map<String, String> HEADERS([String? token = null]) {
  return {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

const URL_LOGIN = '${_HOST}/api/login';
const URL_LOGOUT = '${_HOST}/api/logout';
const URL_USER = '${_HOST}/api/user';
const URL_USER_EXPORT = '${_HOST}/api/user/export';
const URL_USER_FIND = '${_HOST}/api/user/{id}';
const URL_CHANGE_PASSWORD = '${_HOST}/api/change-password';
const URL_USER_CHANGE_PASSWORD = '${_HOST}/api/user/{id}/change-password';
const URL_SEARCH_USER_OLD = '${_HOST}/api/user/search/';
const URL_SEARCH_USER = '${_HOST}/api/user/search';
const URL_USER_PICTURE = '${_HOST}/api/user/profile-picture';
const URL_USER_PICTURE_BY_ID = '${_HOST}/api/user/{id}/profile-picture';
const URL_USER_CHANGE_ACTIVE = '${_HOST}/api/user/{id}/change-active';
const URL_USER_UPDATE_BY_ID = '${_HOST}/api/user/{id}/update';

const URL_REGISTATION_LIST = '${_HOST}/api/registration/list';
const URL_REGISTATION_COUNT = '${_HOST}/api/registration/count';
const URL_REGISTATION_CHANHE_ACTIVE = '${_HOST}/api/registration/{id}/change-active';
const URL_REGISTATION_APPROVE = '${_HOST}/api/registration/{id}/approve';

const URL_FINANCE_LIST = '${_HOST}/api/finance/user/{userId}';
const URL_FINANCE_STATISTICS = '${_HOST}/api/finance/user/{userId}/statistics';
const URL_FINANCE_DELETE = '${_HOST}/api/finance/{financeId}';
const URL_FINANCE_SET = '${_HOST}/api/finance/user/{userId}';
const URL_REDIRECT_JAK = '${_HOST}/redirect-jar-monobank?userId={userId}';
const URL_JAK = '${_HOST}/api/finance/jar-monobank?userId={userId}';

const URL_COSTS_LIST = '${_HOST}/api/costs';
const URL_COSTS_DELETE = '${_HOST}/api/costs/{costsId}';
const URL_COSTS_SET = '${_HOST}/api/costs';

const URL_SEARCH_CAR = '${_HOST}/api/car/search';
const URL_CAR_CREATE = '${_HOST}/api/car/create';
const URL_CAR_UPDATE = '${_HOST}/api/car/{id}';
const URL_CAR_DELETE = '${_HOST}/api/car/{id}';
const URL_MENTION_CAR= '${_HOST}/api/mention/car/';
const URL_CAR_ADD_COLLECTIONS = '${_HOST}/api/car/{id}/collections';
const URL_CAR_FIND = '${_HOST}/api/car/{id}';

const URL_CITIES = '${_HOST}/api/cities';

const URL_MODELS = '${_HOST}/api/models';
const URL_GENES = '${_HOST}/api/genes';
const URL_COLOR = '${_HOST}/api/colors';