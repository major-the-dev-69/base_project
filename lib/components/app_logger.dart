import 'dart:developer';

import 'package:flutter/foundation.dart';

void printMessage(String msg) {
  if (kDebugMode) {
    log(msg);
  }
}
