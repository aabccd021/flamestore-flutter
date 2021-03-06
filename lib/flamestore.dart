import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';

part 'src/document_field/count.dart';
part 'src/document_field/document_field.dart';
part 'src/document_field/dynamic_link.dart';
part 'src/document_field/float.dart';
part 'src/document_field/image.dart';
part 'src/document_field/int.dart';
part 'src/document_field/reference.dart';
part 'src/document_field/server_timestamp.dart';
part 'src/document_field/string.dart';
part 'src/document_field/sum.dart';
part 'src/config/flamestore_config.dart';
part 'src/config/project_config.dart';
part 'src/document/_document_firestore_adapter.dart';
part 'src/document/_document_manager.dart';
part 'src/document/_document_state.dart';
part 'src/document/_document_util.dart';
part 'src/document/document_definition.dart';
part 'src/document/document.dart';
part 'src/document_list/_document_list_firestore_adapter.dart';
part 'src/document_list/_document_list_manager.dart';
part 'src/document_list/_document_list_state.dart';
part 'src/document_list/document_list.dart';
part 'src/document_list/document_list_state.dart';
part 'src/flamestore/_flamestore.dart';
part 'src/flamestore/flamestore.dart';
part 'src/misc/extension.dart';
part 'src/widgets/document_builder.dart';
part 'src/widgets/image_picker.dart';
part 'src/widgets/reference_list_builder.dart';
part 'src/widgets/dynamic_link_handler.dart';
