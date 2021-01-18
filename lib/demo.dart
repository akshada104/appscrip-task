import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<GoogleLogin> {
  bool _isLoggedIn = false;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  _login() async {
    try {
      await _googleSignIn.signIn();
      setState(() {
        _isLoggedIn = true;
      });
    } catch (err) {
      print(err);
    }
  }

  _logout() {
    _googleSignIn.signOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: _isLoggedIn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(_googleSignIn.currentUser.displayName),
                      OutlineButton(
                        child: Text("Logout"),
                        onPressed: () {
                          _logout();
                        },
                      )
                    ],
                  )
                : Center(
                    child: OutlineButton(
                      child: Text("Login with Google"),
                      onPressed: () {
                        _login();
                      },
                    ),
                  )),
      ),
    );
  }
}
