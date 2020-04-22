import 'package:meta/meta.dart';

abstract class ErrorMessageFormatter {
  @protected
  String getErrorMessage(dynamic result) {
    return (result['errors'] as List).map((error) => error['msg']).join(', ');
  }
}
