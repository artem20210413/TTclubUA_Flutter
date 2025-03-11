
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
const URL_CHANGE_PASSWORD = '${_HOST}/api/change-password';
const URL_SEARCH_USER = '${_HOST}/api/user/search/';

const URL_CITIES = '${_HOST}/api/cities';

const URL_MODELS = '${_HOST}/api/models';
const URL_GENES = '${_HOST}/api/genes';