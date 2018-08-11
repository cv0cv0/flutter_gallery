import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/phone_number_formatter.dart';
import '../../widget/password_field.dart';

class TextFormFieldPage extends StatefulWidget {
  const TextFormFieldPage();

  static const routeName = '/material/text_form_field';
  
  @override
  State<StatefulWidget> createState() => _TextFormFieldPageState();
}

class _TextFormFieldPageState extends State<TextFormFieldPage> {
  var person = Person();

  bool _autovalidate = false;
  bool _formWasEdited = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _phoneNumberFormatter = UsPhoneNumberFormatter();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Text fields'),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Form(
            key: _formKey,
            autovalidate: _autovalidate,
            onWillPop: _warnUserAboutInvalidData,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 24.0),
                  TextFormField(
                    validator: _validateName,
                    onSaved: (value) => person.name = value,
                    decoration: InputDecoration(
                      filled: true,
                      icon: Icon(Icons.person),
                      hintText: 'What do people call you?',
                      labelText: 'Name *',
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    validator: _validatePhoneNumber,
                    onSaved: (value) => person.phoneNumber = value,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      _phoneNumberFormatter,
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      icon: Icon(Icons.phone),
                      hintText: 'Where can we reach you?',
                      labelText: 'Phone Number *',
                      prefixText: '+1',
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    onSaved: (value) => person.email = value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      icon: Icon(Icons.email),
                      hintText: 'Your email address',
                      labelText: 'E-mail',
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Tell us about yourself',
                      helperText: 'Keep it short, this is just a demo.',
                      labelText: 'Life story',
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Salary',
                      prefixText: '\$',
                      suffixText: 'USD',
                      suffixStyle: TextStyle(color: Colors.green),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  PasswordField(
                    fieldKey: _passwordFieldKey,
                    labelText: 'Password *',
                    helperText: 'No more than 8 characters.',
                    onFieldSubmitted: (value) => setState(() {
                          person.password = value;
                        }),
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    enabled:
                        person.password != null && person.password.isNotEmpty,
                    maxLength: 8,
                    obscureText: true,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Re-type password',
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Center(
                    child: RaisedButton(
                      child: Text('SUBMIT'),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    '* indicates required field',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      );

  void _handleSubmitted() {
    final form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
      showSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      showSnackBar('${person.name}\'s phone number is ${person.phoneNumber}');
    }
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate()) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('This form has errors'),
                content: Text('Really leave this form?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('YES'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  FlatButton(
                    child: Text('NO'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
        ) ??
        false;
  }

  String _validateName(String value) {
    _formWasEdited = true;
    return RegExp(r'^[A-Za-z ]+$').hasMatch(value)
        ? null
        : 'Please enter only alphabetical characters.';
  }

  String _validatePhoneNumber(String value) {
    _formWasEdited = true;
    return RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$').hasMatch(value)
        ? null
        : '(###) ###-#### - Enter a US phone number.';
  }

  String _validatePassword(String value) {
    _formWasEdited = true;
    final passwordField = _passwordFieldKey.currentState;
    if (passwordField.value == null || passwordField.value.isEmpty)
      return 'Please enter a password.';
    return passwordField.value == value ? null : 'The passwords don\'t match';
  }

  void showSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }
}

class Person {
  var name = '';
  var phoneNumber = '';
  var email = '';
  var password = '';
}
