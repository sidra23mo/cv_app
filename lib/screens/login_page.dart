import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/theme_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final l10n = AppLocalizations.of(context);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('please_fill_fields'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      if (_isSignUp) {
        await authService.signUpWithEmail(_emailController.text, _passwordController.text);
      } else {
        await authService.signInWithEmail(_emailController.text, _passwordController.text);
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ThemeHelper.getCardColor(context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.translate('app_name'),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isSignUp ? l10n.translate('create_account') : l10n.translate('sign_in_continue'),
                style: TextStyle(
                  fontSize: 18,
                  color: ThemeHelper.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.translate('email'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.translate('password'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelper.getButtonColor(context),
                  foregroundColor: ThemeHelper.getButtonTextColor(context),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isSignUp ? l10n.translate('sign_up') : l10n.translate('sign_in')),
              ),
              if (!_isSignUp) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.translate('please_enter_email'))),
                      );
                      return;
                    }
                    try {
                      await AuthService().resetPassword(_emailController.text);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.translate('password_reset_sent'))),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  child: Text(
                    l10n.translate('forgot_password'),
                    style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? l10n.translate('have_account') : l10n.translate('no_account'),
                  style: TextStyle(color: ThemeHelper.getButtonColor(context)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: ThemeHelper.getSecondaryTextColor(context))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l10n.translate('or'), style: TextStyle(color: ThemeHelper.getSecondaryTextColor(context))),
                  ),
                  Expanded(child: Divider(color: ThemeHelper.getSecondaryTextColor(context))),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final authService = AuthService();
                  final result = await authService.signInWithGoogle();
                  if (result != null && context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
                icon: const Icon(Icons.login),
                label: Text(l10n.translate('sign_in_google')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
