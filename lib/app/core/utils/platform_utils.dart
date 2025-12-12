import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';

bool get isWeb => kIsWeb || 
                  [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux]
                      .contains(defaultTargetPlatform);
