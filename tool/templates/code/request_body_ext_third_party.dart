// ignore_for_file: non_constant_identifier_names

import 'package:shelf_plus/shelf_plus.dart';

class OtherBodyFormat {}

dynamic ThirdPartyLib;

//@start
extension OtherFormatBodyParserAccessor on RequestBodyAccessor {
  Future<OtherBodyFormat> get asOtherFormat async {
    return ThirdPartyLib().process(request.read());
  }
}
//@end
