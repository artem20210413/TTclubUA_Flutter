// const _HOST = 'https://tt.tishchenko.kiev.ua';
const _HOST = 'https://ttclub.com.ua';

Map<String, String> HEADERS([String? token = null]) {
  return {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

const URL_SYSTEM_USER_STATS = '${_HOST}/api/system/user-stats';

const URL_LOGIN = '${_HOST}/api/login';
const URL_LOGIN_TG_VERIFY = '${_HOST}/api/login/tg/verify';
const URL_LOGIN_TG_SEND_CODE = '${_HOST}/api/login/tg/send-code';
const URL_LOGOUT = '${_HOST}/api/logout';
const URL_USER = '${_HOST}/api/user';
const URL_USER_EXPORT = '${_HOST}/api/user/export';
const URL_USER_FIND = '${_HOST}/api/user/{id}';
const URL_CHANGE_PASSWORD = '${_HOST}/api/change-password';
const URL_DELETE_ACCOUNT = '${_HOST}/api/delete-account';
const URL_USER_CHANGE_PASSWORD = '${_HOST}/api/user/{id}/change-password';
const URL_SEARCH_USER_OLD = '${_HOST}/api/user/search/';
const URL_SEARCH_USER = '${_HOST}/api/user/search';
const URL_USER_PICTURE = '${_HOST}/api/user/profile-picture';
const URL_USER_PICTURE_DELETE = '${_HOST}/api/user/profile-picture';
const URL_USER_PICTURE_BY_ID = '${_HOST}/api/user/{id}/profile-picture';
const URL_USER_CHANGE_ACTIVE = '${_HOST}/api/user/{id}/change-active';
const URL_USER_UPDATE_BY_ID = '${_HOST}/api/user/{id}/update';

const URL_REGISTATION_LIST = '${_HOST}/api/registration/list';
const URL_REGISTATION_COUNT = '${_HOST}/api/registration/count';
const URL_REGISTATION_CHANHE_ACTIVE =
    '${_HOST}/api/registration/{id}/change-active';
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

const URL_GOODS_LIST = '${_HOST}/api/goods';
const URL_GOODS_CREATE = '${_HOST}/api/goods';
const URL_GOODS_UPDATE = '${_HOST}/api/goods/{goods}';
const URL_GOODS_CHANGE_ACTIVE = '${_HOST}/api/goods/{goods}/active/{active}';
const URL_GOODS_IMAGE_DELETE = '${_HOST}/api/goods/{goods}/images/{mediaId}';
const URL_GOODS_IMAGE_CREATE = '${_HOST}/api/goods/{goods}/images';


const URL_CALENDAR_LIST = '${_HOST}/api/calendar';
const URL_EVENT_LIST = '${_HOST}/api/event';
const URL_EVENT_CREATE = '${_HOST}/api/event';
const URL_EVENT_UPLOAD = '${_HOST}/api/event/{event}';
const URL_EVENT_ADD_IMAGE = '${_HOST}/api/event/{event}/image';
const URL_EVENT_DELETE_IMAGE = '${_HOST}/api/event/{event}/image';
const URL_EVENT_COLLECTIONS_IMAGE = '${_HOST}/api/event/{event}/collections/{mediaId}';
const url_event_change_active = '${_HOST}/api/event/{event}/active/{active}';

const URL_EVENT_TYPE_LIST = '${_HOST}/api/event/type';

const URL_SUGGESTIONS_SEND = '${_HOST}/api/suggestions/send';

const URL_SEARCH_CAR = '${_HOST}/api/car/search';
const URL_CAR_CREATE = '${_HOST}/api/car/create';
const URL_CAR_UPDATE = '${_HOST}/api/car/{id}';
const URL_CAR_DELETE = '${_HOST}/api/car/{id}';
const URL_MENTION_CAR = '${_HOST}/api/mention/car/';
const URL_CAR_ADD_COLLECTIONS = '${_HOST}/api/car/{id}/collections';
const URL_CAR_DELETE_COLLECTIONS = '${_HOST}/api/car/{car}/collections/{images}';
const URL_CAR_FIND = '${_HOST}/api/car/{id}';

const URL_CITIES = '${_HOST}/api/cities';

const URL_MODELS = '${_HOST}/api/models';
const URL_GENES = '${_HOST}/api/genes';
const URL_COLOR = '${_HOST}/api/colors';
