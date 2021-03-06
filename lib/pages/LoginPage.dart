import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta/model/User.dart';
import 'package:ta/network/network.dart';
import 'package:ta/pages/InitPage.dart';
import 'package:ta/res/Strings.dart';
import 'package:ta/tools.dart';
import 'package:ta/widgets/BetterState.dart';
import 'package:ta/widgets/EditText.dart';

class LoginPage extends StatefulWidget {
  LoginPage() : super();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends BetterState<LoginPage> with AfterLayoutMixin {
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentNumberFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  ErrorText _studentNumberErrorText = ErrorText(null);
  ErrorText _passwordErrorText = ErrorText(null);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(body: Builder(
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 24),
              children: <Widget>[
                SizedBox(
                  height: 28,
                ),
                Image.asset(
                  "assets/icons/app_logo.png",
                  height: 130,
                ),
                Center(
                  child: Text(
                    "YRDSB",
                    style: TextStyle(fontSize: 26),
                  ),
                ),
                Center(child: Text("Teach Assist Pro", style: TextStyle(fontSize: 24))),
                SizedBox(
                  height: 80,
                ),
                Center(
                  widthFactor: 0,
                  child: Text(Strings.get("login_your_account", context), style: Theme.of(context).textTheme.title),
                ),
                SizedBox(height: 18),
                EditText(
                  textInputAction: TextInputAction.next,
                  nextFocusNode: _passwordFocusNode,
                  focusNode: _studentNumberFocusNode,
                  controller: _studentNumberController,
                  hint: Strings.get("student_number"),
                  errorText: _studentNumberErrorText,
                  icon: Icons.account_circle,
                  inputType: TextInputType.numberWithOptions(signed: false, decimal: false),
                ),
                SizedBox(height: 12),
                EditText(
                  textInputAction: TextInputAction.done,
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  hint: Strings.get("password"),
                  errorText: _passwordErrorText,
                  icon: Icons.lock,
                  isPassword: true,
                  onSubmitted: (s) {
                    if (!_isLoading) {
                      _startLogin(context);
                    }
                  },
                ),
                ButtonBar(
                  children: <Widget>[
                    _isLoading
                        ? CircularProgressIndicator()
                        : Placeholder(
                            fallbackWidth: 0,
                            fallbackHeight: 0,
                          ),
                    RaisedButton(
                      color: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        Strings.get("login").toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: !_isLoading
                          ? () {
                              FocusScope.of(context).unfocus();
                              _startLogin(context);
                            }
                          : null,
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    appLoadDone();
  }

  _startLogin(BuildContext context) async {
    if (_studentNumberController.text == "") {
      setState(() {
        _studentNumberErrorText.text = Strings.get("plz_fill_in_ur_student_number");
      });
      return;
    }
    if (_passwordController.text == "") {
      setState(() {
        _passwordErrorText.text = Strings.get("plz_fill_in_ur_pwd");
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var user = User(_studentNumberController.text, _passwordController.text, true);

    try {
      await regiAndSave(user);
      addUser(user);
      setCurrentUser(user);
      await getAndSaveCalendar();
      Navigator.pushReplacementNamed(
        context,
        "/summary",
      );
    } catch (e) {
      _handleError(e, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  _handleError(Exception e, BuildContext context) {
    if (e is SocketException) {
      if (e.message == "Connection failed" || e.osError.message == "Connection refused") {
        showSnackBar(context, Strings.get("connection_failed"));
      } else {
        showSnackBar(context, Strings.get("error") + (e.message != "" ? e.message : e.osError.message));
      }
    } else if (e is HttpException) {
      switch (e.message) {
        case "401":
          {
            setState(() {
              _passwordErrorText.text = Strings.get("student_number_or_password_incorrect");
            });
            break;
          }
        case "500":
          {
            showSnackBar(context, Strings.get("server_internal_error"));
            break;
          }
        default:
          {
            showSnackBar(context, Strings.get("error_code") + e.message);
          }
      }
    } else {
      showSnackBar(context, Strings.get("error") + e.toString());
    }
  }
}
