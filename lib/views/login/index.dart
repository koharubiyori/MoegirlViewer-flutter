import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moegirl_plus/language/index.dart';
import 'package:moegirl_plus/providers/account.dart';
import 'package:moegirl_plus/utils/ui/dialog/loading.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/views/login/components/styled_text_field.dart';
import 'package:one_context/one_context.dart';
import 'package:url_launcher/url_launcher.dart';

const moegirlCreateAccountPageUrl = 'https://mzh.moegirl.org.cn/index.php?title=Special:创建账户';

class LoginPageRouteArgs {
  
  LoginPageRouteArgs();
}

class LoginPage extends StatefulWidget {
  final LoginPageRouteArgs routeArgs;
  LoginPage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String userName = '';
  String password = '';
  FocusNode userNameInputFucusNode;
  FocusNode passwordInputFocusNode;

  void submit() {
    userNameInputFucusNode.unfocus();
    passwordInputFocusNode.unfocus();
    if (userName.trim() == '') return toast(l.loginPage_userNameEmptyHint, position: ToastPosition.center);
    if (password.trim() == '') return toast(l.loginPage_passwordEmptyHint, position: ToastPosition.center);

    showLoading(text: l.loginPage_logging);
    accountProvider.login(userName, password)
      .whenComplete(OneContext().pop)
      .then((loginResult) {
        if (loginResult.successed) {
          toast(l.loginPage_loggedIn, position: ToastPosition.center);
          OneContext().pop();
        } else {
          toast(loginResult.message);
        }
      })
      .catchError((err) {
        print(err);
        toast(l.netErr);
      });
  }

  @override
  Widget build(BuildContext context) {
    AppBar(brightness: Brightness.dark);
    
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/moe_2014_haru.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
          )
        ),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/moemoji.png', width: 70, height: 70),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(l.loginPage_slogan,
                  style: TextStyle(
                    color: Colors.green[100],
                    fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LoginPageStyledTextField(
                  labelText: l.loginPage_userName,
                  emitFocusNode: (focusNode) => userNameInputFucusNode = focusNode,
                  onChanged: (text) => setState(() => userName = text),
                  onSubmitted: () => passwordInputFocusNode.requestFocus(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LoginPageStyledTextField(
                  labelText: l.loginPage_password,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  emitFocusNode: (focusNode) => passwordInputFocusNode = focusNode,
                  onChanged: (text) => setState(() => password = text),
                  onSubmitted: submit
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: 300,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      elevation: MaterialStateProperty.all(0)
                    ),
                    child: Text(l.loginPage_login, 
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: CupertinoButton(
                  onPressed: () => launch(moegirlCreateAccountPageUrl),
                  child: Text(l.loginPage_registerHint,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      decoration: TextDecoration.underline
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      )
    );
  }
}