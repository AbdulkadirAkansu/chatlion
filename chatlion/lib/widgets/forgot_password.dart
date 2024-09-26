import 'package:flutter/material.dart';
import 'package:chatlion/theme/theme.dart'; // Tema dosyası eklendi

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 11.0,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildGif(),
              const SizedBox(height: 16.0),
              _buildDialogTitle(context),
              const SizedBox(height: 16.0),
              _buildDescriptionText(),
              const SizedBox(height: 24.0),
              _buildEmailField(),
              const SizedBox(height: 35.0),
              _buildSubmitButton(context),
              const SizedBox(height: 12.0),
              _buildCancelButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGif() {
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: Image.asset('assets/forgotpass.gif'),
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return Text(
      'Forgot Password',
      style: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: lightTheme().primaryColor,
      ),
    );
  }

  Widget _buildDescriptionText() {
    return const Text(
      'Enter your email address to reset your password.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18.0,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter Your Email Address',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: const Icon(Icons.email),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Implement password reset functionality here
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: lightTheme().primaryColor,
        minimumSize: const Size(double.infinity, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text(
        'Cancel',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
