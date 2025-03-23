import 'package:crime/account/components/color.dart';
import 'package:crime/utils/theme.dart';
import 'package:flutter/material.dart';

AppBar customAppBar(
    {String? title,
    IconButton? iconButton,
    Color? textColor,
    PreferredSizeWidget? bottomBar}) {
  return AppBar(
    leading: iconButton,
    title: Text(
      title!,
      style: AppTheme.titleLarge,
    ),
    backgroundColor: AppTheme.surfaceColor,
    iconTheme: IconThemeData(
      color: AppTheme.primaryColor,
    ),
    centerTitle: true,
    elevation: 2,
    bottom: bottomBar,
  );
}

AppBar customAppBarAction(
    {String? title,
    IconButton? iconButton,
    Color? textColor,
    PreferredSizeWidget? bottomBar,
    Widget? actions}) {
  return AppBar(
      leading: iconButton,
      title: Text(
        title!,
        style: AppTheme.titleLarge,
      ),
      backgroundColor: AppTheme.surfaceColor,
      iconTheme: IconThemeData(
        color: AppTheme.primaryColor,
      ),
      centerTitle: true,
      elevation: 2,
      bottom: bottomBar,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: actions ?? const SizedBox.shrink(),
        )
      ]);
}

Widget getTextField(
    {String? text,
    String? valError,
    bool? readonly,
    Function(String)? onChanged,
    bool? obscureText,
    String? Function(String?)? validator,
    bool isEdit = false,
    TextInputType? keyboardType,
    int? minLines,
    int? maxLines,
    InputDecoration? decoration}) {
  return TextFormField(
    style: AppTheme.bodyLarge,
    decoration: decoration ??
        AppTheme.inputDecoration.copyWith(
          hintText: text,
          errorText: valError,
        ),
    readOnly: readonly ?? false,
    onChanged: onChanged,
    obscureText: obscureText ?? false,
    validator: validator,
    enabled: !isEdit,
    keyboardType: keyboardType,
    minLines: minLines,
    maxLines: maxLines,
  );
}

Widget getCustomButton(
    {String? text,
    Color? background,
    double? fontSize,
    Icon? icon,
    Function()? onPressed,
    double? padding}) {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: ElevatedButton(
      onPressed: onPressed,
      style: AppTheme.primaryButtonStyle.copyWith(
        backgroundColor:
            MaterialStateProperty.all(background ?? AppTheme.primaryColor),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: padding ?? 24,
            vertical: 15,
          ),
        ),
        textStyle: MaterialStateProperty.all(
          AppTheme.bodyLarge.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 10),
          ],
          Text(text!),
        ],
      ),
    ),
  );
}
