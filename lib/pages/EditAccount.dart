import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ta/model/User.dart';
import 'package:ta/network/network.dart';
import 'package:ta/res/Strings.dart';
import 'package:ta/widgets/EditText.dart';

import '../tools.dart';

class EditAccount extends StatefulWidget {
  EditAccount() {
    this.user = User.blank();
  }

  EditAccount.fromUser(User user) {
    this.user = user.copy();
  }

  User user;

  @override
  _EditAccountState createState() => _EditAccountState(user);
}

class _EditAccountState extends State<EditAccount> {
  TextEditingController _aliasController;
  TextEditingController _studentNumberController;
  TextEditingController _passwordController;
  bool _isSaveLoading = false;
  bool _addNew;
  bool _receive;
  final _studentNumberErrorText = ErrorText(null);
  final _passwordErrorText = ErrorText(null);

  _EditAccountState(User user) {
    _aliasController = TextEditingController(text: user.displayName);
    _studentNumberController = TextEditingController(text: user.number);
    _passwordController = TextEditingController(text: user.password);
    _receive = user.receiveNotification;
    _addNew = user.number == "";
  }

  @override
  Widget build(BuildContext context) {
    var _oldUser = widget.user;
    return Scaffold(
        appBar: AppBar(
          title: Text(_oldUser.number != ""
              ? Strings.get("edit") + " " + _oldUser.number
              : Strings.get("add_a_new_account")),
          actions: <Widget>[
            Builder(
              builder: (context) {
                return (!_isSaveLoading & !_addNew)
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          var confirm = false;
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(Strings.get("remove_account") +
                                      " " +
                                      _oldUser.number +
                                      Strings.get("?")),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                          Strings.get("cancel").toUpperCase()),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                          Strings.get("remove").toUpperCase()),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        confirm = true;
                                      },
                                    ),
                                  ],
                                );
                              });
                          if (confirm == true) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return SimpleDialog(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 28, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            CircularProgressIndicator(),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Text(
                                              Strings.get("removing"),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                });
                            try {
                              await deregi(_oldUser);
                              removeUser(_oldUser.number);
                              if (userList.length > 0) {
                                Navigator.popUntil(context,
                                    ModalRoute.withName('/accounts_list'));
                              } else {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login', (Route<dynamic> route) => false);
                              }
                            } catch (e) {
                              _handleError(e, context);
                              Navigator.pop(context);
                            }
                          }
                        },
                      )
                    : Container(width: 0.0, height: 0.0);
              },
            ),
            _isSaveLoading
                ? Stack(
                    alignment: Alignment(0, 0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: CircularProgressIndicator(
                            backgroundColor: Theme.of(context).canvasColor),
                      )
                    ],
                  )
                : Container(width: 0.0, height: 0.0),
            Builder(
              builder: (context) {
                return !_isSaveLoading
                    ? IconButton(
                        icon: Icon(Icons.done),
                        onPressed: () async {
                          if (_studentNumberController.text == "") {
                            setState(() {
                              _studentNumberErrorText.text =
                                  Strings.get("plz_fill_in_ur_student_number");
                            });
                            return;
                          }
                          if (_passwordController.text == "") {
                            setState(() {
                              _passwordErrorText.text =
                                  Strings.get("plz_fill_in_ur_pwd");
                            });
                            return;
                          }

                          if (_addNew) {
                            var _dual = false;
                            userList.forEach((item) {
                              if (item.number ==
                                  _studentNumberController.text) {
                                setState(() {
                                  _studentNumberErrorText.text = Strings.get(
                                      "this_account_already_exists");
                                });
                                _dual = true;
                                return;
                              }
                            });
                            if (_dual) {
                              return;
                            }
                          }

                          setState(() {
                            _isSaveLoading = true;
                          });

                          var user = User(_studentNumberController.text,
                              _passwordController.text, _receive,
                              displayName: _aliasController.text);

                          try {
                            if (_addNew) {
                              await regi(user);
                              addUser(user);
                            } else {
                              await deregi(_oldUser);
                              await regi(user);
                              editUser(user, _oldUser.number);
                            }

                            Navigator.pop(context);
                          } catch (e) {
                            print(e);
                            _handleError(e, context);
                          }
                          setState(() {
                            _isSaveLoading = false;
                          });
                        },
                      )
                    : Container(width: 0.0, height: 0.0);
              },
            )
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            EditText(
                controller: _aliasController,
                maxWidth: 400,
                hint: Strings.get("alias_optional"),
                errorText: ErrorText(null),
                icon: Icons.stars),
            SizedBox(height: 12),
            EditText(
              controller: _studentNumberController,
              maxWidth: 400,
              hint: Strings.get("student_number"),
              errorText: _studentNumberErrorText,
              icon: Icons.account_circle,
              inputType: TextInputType.numberWithOptions(
                  signed: false, decimal: false),
            ),
            SizedBox(height: 12),
            EditText(
              controller: _passwordController,
              maxWidth: 400,
              hint: Strings.get("password"),
              errorText: _passwordErrorText,
              icon: Icons.lock,
              isPassword: true,
            ),
            SizedBox(height: 12),
            ListTile(
              title: Text(Strings.get("receive_notifications")),
              leading: Icon(_receive
                  ? Icons.notifications_active
                  : Icons.notifications_off),
              trailing: Switch(
                value: _receive,
                onChanged: (val) {
                  setState(() {
                    _receive = val;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _receive = !_receive;
                });
              },
            )
          ],
        ));
  }

  _handleError(Exception e, BuildContext context) {
    if (e is SocketException) {
      if (e.message == "Connection failed") {
        showSnackBar(context, Strings.get("connection_failed"));
      } else {
        showSnackBar(context, e.message);
      }
    } else if (e is HttpException) {
      switch (e.message) {
        case "401":
          {
            setState(() {
              _passwordErrorText.text =
                  Strings.get("student_number_or_password_incorrect");
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
      showSnackBar(context, e.toString());
    }
  }
}

class _editAccountAppbar extends StatefulWidget {
  @override
  __editAccountAppbarState createState() => __editAccountAppbarState();
}

class __editAccountAppbarState extends State<_editAccountAppbar> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}
