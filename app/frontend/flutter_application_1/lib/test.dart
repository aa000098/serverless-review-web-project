import 'package:flutter/material.dart';

void main() {
  runApp(ReviewApp());
}

class ReviewApp extends StatelessWidget {
  const ReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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

class User {
  final String email;
  final String password;

  User(this.email, this.password);
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() {
    String enteredEmail = _emailController.text;
    String enteredPassword = _passwordController.text;

    List<User> mockUsers = [
      User("id", "pw"),
      User("user", "password"),
    ];

    bool loginSuccess = false;
    User? loggedInUser;

    for (User user in mockUsers) {
      if (user.email == enteredEmail && user.password == enteredPassword) {
        loginSuccess = true;
        loggedInUser = user;
        break;
      }
    }

    if (loginSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(user: loggedInUser!),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid email or password.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 250,
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(
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
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _login,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final User user; // 로그인에 성공한 사용자 정보를 받아옵니다.

  MainPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.email}!'), // 사용자의 ID를 환영 메시지에 표시합니다.
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                // 로그아웃 버튼을 눌렀을 때 로그인 페이지로 돌아갑니다.
                Navigator.pop(context);
              },
              child: Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
