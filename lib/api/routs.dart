
const _HOST = 'https://tt.tishchenko.kiev.ua';

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
const URL_USER_FIND = '${_HOST}/api/user/{id}';
const URL_CHANGE_PASSWORD = '${_HOST}/api/change-password';
const URL_SEARCH_USER = '${_HOST}/api/user/search/';
const URL_USER_PICTURE = '${_HOST}/api/user/profile-picture';
const URL_USER_CHANGE_ACTIVE = '${_HOST}/api/user/{id}/change-active';
const URL_USER_UPDATE_BY_ID = '${_HOST}/api/user/{id}/update';
const URL_REGISTATION_LIST = '${_HOST}/api/registration/list';
const URL_REGISTATION_CHANHE_ACTIVE = '${_HOST}/api/registration/{id}/change-active';
const URL_REGISTATION_APPROVE = '${_HOST}/api/registration/{id}/approve';

const URL_SEARCH_CAR = '${_HOST}/api/car/search/';
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