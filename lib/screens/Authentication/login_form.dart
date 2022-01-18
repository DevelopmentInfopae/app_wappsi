import 'package:flutter/material.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/Authentication/components/login_mobile_view.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
    
        body:LoginMobileView(size: _size),
        
      ) 
      
    );
  }
}


