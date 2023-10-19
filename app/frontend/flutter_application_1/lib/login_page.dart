import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';
import 'main_page.dart';

// 로그인 페이지
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('로그인'),
          ],
        ),
      ),
      body: Center(
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final String loginRequestUrl = '$apiUrl/$apilogin';

  Future<bool> _isCreateUserSuccess(entered_id, entered_pw) async {
    final Map<String, String> data = {
      'method': 'create_user',
      'entered_id': entered_id,
      'entered_pw': entered_pw,
    };

    final response = await http.post(
      Uri.parse(loginRequestUrl),
      headers: {
        'x-api-key': apiKey!,
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isIDValid(String entered_id) {
    return entered_id.isNotEmpty && entered_id.length >= 5;
  }

  bool _isPasswordValid(String entered_pw) {
    return entered_pw.isNotEmpty && entered_pw.length >= 5;
  }

  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '아이디를 입력하세요',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력하세요',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    String entered_id = _emailController.text;
                    String entered_pw = _passwordController.text;
                    if (_isIDValid(entered_id) &&
                        _isPasswordValid(entered_pw)) {
                      _isCreateUserSuccess(entered_id, entered_pw).then(
                        (isSuccess) async {
                          if (isSuccess) {
                            Navigator.pop(context);
                          } else {
                            Future.delayed(
                              Duration.zero,
                              () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('오류'),
                                      content: Text('이미 존재하는 아이디 입니다.'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('확인'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('오류'),
                            content: Text('아이디와 비밀번호는 최소 5자리 입니다.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<bool> _login() async {
    String entered_id = _emailController.text;
    String entered_pw = _passwordController.text;

    final Map<String, String> data = {
      'method': 'read_user',
      'entered_id': entered_id,
      'entered_pw': entered_pw,
    };

    final response = await http.post(
      Uri.parse(loginRequestUrl),
      headers: {
        'x-api-key': apiKey!,
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.all_inclusive,
                color: Colors.lightBlue,
                size: 80,
              ),
              SizedBox(width: 8),
              Text(
                'Re View',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 80.0),
          SizedBox(
            height: 50,
            width: 250,
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ID',
              ),
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(
            height: 50,
            width: 250,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 250),
              ElevatedButton(
                  onPressed: () {
                    _showSignUpDialog(context);
                  },
                  child: Text('Sign Up'))
            ],
          ),
          SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: () {
              _login().then((isLoggedIn) {
                if (isLoggedIn) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MainPage(userid: _emailController.text),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Login Failed'),
                        content: Text('아이디 비밀번호가 틀렸습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              });
            },
            child: SizedBox(
              width: 150,
              height: 40,
              child: Center(
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
