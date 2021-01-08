import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moegirl_plus/mobx/index.dart';
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
    if (userName.trim() == '') return toast('用户名不能为空', position: ToastPosition.center);
    if (password.trim() == '') return toast('密码不能为空', position: ToastPosition.center);

    showLoading(text: '登录中...');
    accountStore.login(userName, password)
      .whenComplete(OneContext().pop)
      .then((loginResult) {
        if (loginResult.successed) {
          toast('登录成功', position: ToastPosition.center);
          OneContext().pop();
        } else {
          toast(loginResult.message);
        }
      })
      .catchError((err) {
        print(err);
        toast('网络错误');
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
                child: Text('萌娘百科，万物皆可萌的百科全书！',
                  style: TextStyle(
                    color: Colors.green[100],
                    fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LoginPageStyledTextField(
                  labelText: '用户名',
                  emitFocusNode: (focusNode) => userNameInputFucusNode = focusNode,
                  onChanged: (text) => setState(() => userName = text),
                  onSubmitted: () => passwordInputFocusNode.requestFocus(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LoginPageStyledTextField(
                  labelText: '密码',
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
                    child: Text('登录', 
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
                  child: Text('还没有萌百帐号？点击前往官网注册',
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