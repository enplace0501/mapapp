import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';

class CustomButtonResolver extends ButtonResolver {
  const CustomButtonResolver();

  @override
  String signIn(BuildContext context) {
    return 'ログイン';
  }

  @override
  String signUp(BuildContext context) {
    return 'アカウント登録';
  }

  @override
  String forgotPassword(BuildContext context) {
    return 'パスワードを忘れた場合';
  }

  @override
  String confirm(BuildContext context) {
    return '登録';
  }

  @override
  String sendCode(BuildContext context) {
    return '再送信';
  }

  @override
  String lostCode(BuildContext context) {
    return '検証コードが届かない場合';
  }

  @override
  String signInWith(BuildContext context, AuthProvider provider) {
    switch (provider) {
      case AuthProvider.apple:
        return 'Appleでログイン';
      case AuthProvider.amazon:
        return 'Amazonでログイン';
      case AuthProvider.facebook:
        return 'Facebookでログイン';
      case AuthProvider.google:
        return 'Googleでログイン';
      default:
        return 'ログイン';
    }
  }

  @override
  String backTo(BuildContext context, AuthenticatorStep previousStep) {
    switch (previousStep) {
      case AuthenticatorStep.signIn:
        return "ログイン画面へ戻る";
      default:
        return "戻る";
    }
  }
}

class CustomInputResolver extends InputResolver {
  const CustomInputResolver();

  @override
  String title(BuildContext context, InputField field) {
    switch (field) {
      case InputField.username:
        return 'ユーザー名';
      case InputField.email:
        return 'メールアドレス';
      case InputField.password:
        return 'パスワード※大小文字含む8文字以上';
      case InputField.passwordConfirmation:
        return 'パスワード(確認)※大小文字含む8文字以上';
      case InputField.verificationCode:
        return '検証コード';
      default:
        return super.title(context, field);
    }
  }

  @override
  String hint(BuildContext context, InputField field) {
    final fieldName = title(context, field);
    return '$fieldNameを入力してください';
  }

  @override
  String confirmHint(BuildContext context, InputField field) {
    final fieldName = title(context, field);
    final replaceFieldName = fieldName.replaceFirst('(確認)', '');
    return '$replaceFieldNameを再度入力してください';
  }

  // メールフォーマットチェック
  @override
  String format(BuildContext context, InputField field) {
    return 'メールアドレスの形式で入力してください';
  }

  // 空欄チェック
  @override
  String empty(BuildContext context, InputField field) {
    final fieldName = title(context, field);
    return '$fieldNameを入力してください';
  }

  // パスワードのバリデーション
  @override
  String passwordRequires(
    BuildContext context,
    PasswordProtectionSettings requirements,
  ) {
    var minLength = requirements.passwordPolicyMinLength;
    var characterReqs = requirements.passwordPolicyCharacters;

    if (minLength == null && (characterReqs.isEmpty)) {
      return '';
    }
    var sb = StringBuffer(
      'パスワードポリシーを満たしていません\n',
    );

    if (minLength != null) {
      // var atLeast = AuthenticatorLocalizations.inputsOf(context)
      //     .passwordRequirementsAtLeast(minLength, '');
      sb.writeln('* $minLength 以上の文字数が必要です');
    }
    // ignore: unused_local_variable
    for (var characterReq in characterReqs) {
      sb.writeln('* $characterReqs を満たしていません');
    }
    return sb.toString();
  }
}

class CustomMessagesResolver extends MessageResolver {
  const CustomMessagesResolver();
  @override
  String codeSent(BuildContext context, String destination) {
    // ↓✨✨スナックバーの文言を変更
    return "登録用コードを次のメールアドレスに送信しました。$destination";
  }
}

class CustomTitleResolver extends TitleResolver {
  const CustomTitleResolver();

  String signIn(BuildContext context) {
    return 'ログイン';
  }

  String signUp(BuildContext context) {
    return 'アカウント登録';
  }

  @override
  String confirmSignUp(BuildContext context) {
    return '確認';
  }
}

const stringResolver = AuthStringResolver(
  buttons: CustomButtonResolver(),
  inputs: CustomInputResolver(),
  messages: CustomMessagesResolver(),
  titles: CustomTitleResolver(),
);
