import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_account_screen_widget.dart' show CreateAccountScreenWidget;
import 'package:flutter/material.dart';

class CreateAccountScreenModel
    extends FlutterFlowModel<CreateAccountScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
