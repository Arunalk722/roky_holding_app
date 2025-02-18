class APIHost {
  final String APIURL = 'http://127.0.0.1:8002/RN/public/apis/controllers';
  final String APIImage = 'http://220.247.246.76:8002/RN/src/img';
}

class APIToken {
  String? _token;
  APIToken._privateConstructor();
  static final APIToken _instance = APIToken._privateConstructor();

  factory APIToken() {
    return _instance;
  }
  set token(String? value) => _token = value;
  String? get token => _token;
}
