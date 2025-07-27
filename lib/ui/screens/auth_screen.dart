// // lib/screens/auth_screen.dart
// import 'package:ai_chat_trivia/core/providers/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
//   final _usernameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   bool _isLogin = true;
//   bool _isLoading = false;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade400,
//               Colors.purple.shade400,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildAuthCard(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAuthCard() {
//     return Card(
//       elevation: 12,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(32.0),
//         constraints: const BoxConstraints(maxWidth: 400),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               const SizedBox(height: 32),
//               _buildToggleButtons(),
//               const SizedBox(height: 24),
//               _buildUsernameField(),
//               const SizedBox(height: 24),
//               _buildSubmitButton(),
//               const SizedBox(height: 16),
//               _buildFooterText(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [Colors.blue.shade400, Colors.purple.shade400],
//             ),
//           ),
//           child: const Icon(
//             Icons.chat_bubble_outline,
//             size: 48,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'AI Chat Trivia',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade800,
//               ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           _isLogin
//               ? 'Welcome back! Sign in to continue'
//               : 'Join the fun! Create your account',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey.shade600,
//               ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildToggleButtons() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTap: () => _toggleMode(true),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: _isLogin ? Colors.white : Colors.transparent,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: _isLogin
//                       ? [
//                           BoxShadow(
//                             color: Colors.grey.shade300,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           )
//                         ]
//                       : null,
//                 ),
//                 child: Text(
//                   'Sign In',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color:
//                         _isLogin ? Colors.blue.shade600 : Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () => _toggleMode(false),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: !_isLogin ? Colors.white : Colors.transparent,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: !_isLogin
//                       ? [
//                           BoxShadow(
//                             color: Colors.grey.shade300,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           )
//                         ]
//                       : null,
//                 ),
//                 child: Text(
//                   'Sign Up',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color:
//                         !_isLogin ? Colors.blue.shade600 : Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUsernameField() {
//     return TextFormField(
//       controller: _usernameController,
//       decoration: InputDecoration(
//         labelText: 'Username',
//         prefixIcon: Icon(Icons.person_outline, color: Colors.blue.shade400),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         helperText: '3-16 chars, letters & numbers only, no spaces',
//       ),
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return 'Please enter a username';
//         }
//         if (value.trim().length < 3 || value.trim().length > 16) {
//           return 'Username must be 3-16 characters';
//         }
//         if (!RegExp(r'^[a-zA-Z0-9]+[a-zA-Z0-9]+$').hasMatch(value.trim())) {
//           return 'Only letters and numbers allowed, no spaces';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _handleSubmit,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue.shade600,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 4,
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Text(
//                 _isLogin ? 'Sign In' : 'Create Account',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildFooterText() {
//     return Text(
//       _isLogin
//           ? 'New to AI Chat Trivia? Tap Sign Up above!'
//           : 'Already have an account? Tap Sign In above!',
//       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: Colors.grey.shade600,
//           ),
//       textAlign: TextAlign.center,
//     );
//   }

//   void _toggleMode(bool isLogin) {
//     if (_isLogin != isLogin) {
//       setState(() {
//         _isLogin = isLogin;
//         _usernameController.clear();
//       });
//     }
//   }

//   Future<void> _handleSubmit() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     final username = _usernameController.text.trim();
//     final userProvider = Provider.of<UserProvider>(context, listen: false);

//     bool success;
//     String message;

//     if (_isLogin) {
//       success = await userProvider.loginUser(username);
//       message = success
//           ? 'Welcome back, $username!'
//           : 'User not found. Please check your username or sign up.';
//     } else {
//       success = await userProvider.registerUser(username);
//       message = success
//           ? 'Account created! Welcome, $username!'
//           : 'Username already taken. Please choose another.';
//     }

//     setState(() {
//       _isLoading = false;
//     });

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: success ? Colors.green : Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       );

//       // The AppWrapper will automatically navigate to HomeScreen
//       // when userProvider.isLoggedIn becomes true
//       // No manual navigation needed!
//     }
//   }
// }

// // lib/ui/screens/auth_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/providers/user_provider.dart';
// import '../../core/theme/app_theme.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
//   final _usernameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   bool _isLogin = true;
//   bool _showRegisteredUsers = false;

//   late AnimationController _animationController;
//   late AnimationController _cardController;
//   late AnimationController _backgroundController;

//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _cardScaleAnimation;
//   late Animation<double> _backgroundAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _startAnimations();
//     _loadRegisteredUsers();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _cardController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _backgroundController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
//     ));

//     _cardScaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _cardController,
//       curve: Curves.elasticOut,
//     ));

//     _backgroundAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _backgroundController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _startAnimations() async {
//     _backgroundController.forward();
//     await Future.delayed(const Duration(milliseconds: 300));
//     _cardController.forward();
//     await Future.delayed(const Duration(milliseconds: 200));
//     _animationController.forward();
//   }

//   void _loadRegisteredUsers() async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final users = await userProvider.getRegisteredUsernames();
//     if (mounted && users.isNotEmpty) {
//       setState(() {
//         _showRegisteredUsers = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _animationController.dispose();
//     _cardController.dispose();
//     _backgroundController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: Listenable.merge([
//           _animationController,
//           _cardController,
//           _backgroundController,
//         ]),
//         builder: (context, child) {
//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppTheme.primaryColor.withOpacity(_backgroundAnimation.value),
//                   AppTheme.secondaryColor
//                       .withOpacity(_backgroundAnimation.value * 0.8),
//                   AppTheme.accentColor
//                       .withOpacity(_backgroundAnimation.value * 0.6),
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(24.0),
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: SlideTransition(
//                       position: _slideAnimation,
//                       child: ScaleTransition(
//                         scale: _cardScaleAnimation,
//                         child: _buildAuthCard(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAuthCard() {
//     return Container(
//       constraints: const BoxConstraints(maxWidth: 400),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         color: Colors.white.withOpacity(0.95),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 30,
//             offset: const Offset(0, 15),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: Container(
//           padding: const EdgeInsets.all(32.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 32),
//                 _buildToggleButtons(),
//                 const SizedBox(height: 24),
//                 if (_showRegisteredUsers && _isLogin) ...[
//                   _buildRegisteredUsers(),
//                   const SizedBox(height: 16),
//                   _buildDivider(),
//                   const SizedBox(height: 16),
//                 ],
//                 _buildUsernameField(),
//                 const SizedBox(height: 24),
//                 _buildSubmitButton(),
//                 const SizedBox(height: 16),
//                 _buildFooterText(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: AppTheme.primaryGradient,
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.primaryColor.withOpacity(0.3),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.smart_toy,
//             size: 40,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 20),
//         ShaderMask(
//           shaderCallback: (bounds) =>
//               AppTheme.primaryGradient.createShader(bounds),
//           child: const Text(
//             '🎮 AI Chat Trivia',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           _isLogin
//               ? 'Welcome back! Sign in to continue your journey'
//               : 'Join the AI-powered conversation revolution',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//             height: 1.4,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildToggleButtons() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       padding: const EdgeInsets.all(4),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildToggleButton('Sign In', true, _isLogin),
//           ),
//           Expanded(
//             child: _buildToggleButton('Sign Up', false, !_isLogin),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleButton(String text, bool isLogin, bool isSelected) {
//     return GestureDetector(
//       onTap: () => _toggleMode(isLogin),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: Colors.grey.shade300,
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   )
//                 ]
//               : null,
//         ),
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRegisteredUsers() {
//     return Consumer<UserProvider>(
//       builder: (context, userProvider, _) {
//         return FutureBuilder<List<String>>(
//           future: userProvider.getRegisteredUsernames(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const SizedBox.shrink();
//             }

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Quick Sign In',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: snapshot.data!.take(6).map((username) {
//                     return _buildUserChip(username);
//                   }).toList(),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildUserChip(String username) {
//     return GestureDetector(
//       onTap: () {
//         _usernameController.text = username;
//         _handleSubmit();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: AppTheme.primaryColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: AppTheme.primaryColor.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircleAvatar(
//               radius: 10,
//               backgroundColor: AppTheme.primaryColor,
//               child: Text(
//                 username[0].toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               username,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: AppTheme.primaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Row(
//       children: [
//         Expanded(child: Divider(color: Colors.grey.shade300)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'or',
//             style: TextStyle(
//               color: Colors.grey.shade500,
//               fontSize: 12,
//             ),
//           ),
//         ),
//         Expanded(child: Divider(color: Colors.grey.shade300)),
//       ],
//     );
//   }

//   Widget _buildUsernameField() {
//     return Consumer<UserProvider>(
//       builder: (context, userProvider, _) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               controller: _usernameController,
//               decoration: InputDecoration(
//                 labelText: 'Username',
//                 hintText: 'Enter your username',
//                 prefixIcon: Container(
//                   margin: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.person_outline,
//                     color: AppTheme.primaryColor,
//                     size: 20,
//                   ),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide:
//                       BorderSide(color: AppTheme.primaryColor, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(color: AppTheme.errorColor),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey.shade50,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 16,
//                 ),
//               ),
//               validator: UserProvider.validateUsername,
//               textInputAction: TextInputAction.done,
//               onFieldSubmitted: (_) => _handleSubmit(),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '3-20 characters, letters, numbers, and underscores only',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             if (userProvider.hasError) ...[
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.errorColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: AppTheme.errorColor.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       color: AppTheme.errorColor,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         userProvider.lastError!,
//                         style: const TextStyle(
//                           color: AppTheme.errorColor,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildSubmitButton() {
//     return Consumer<UserProvider>(
//       builder: (context, userProvider, _) {
//         final isLoading =
//             userProvider.isRegistering || userProvider.isLoggingIn;

//         return SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton(
//             onPressed: isLoading ? null : _handleSubmit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primaryColor,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               elevation: 8,
//               shadowColor: AppTheme.primaryColor.withOpacity(0.3),
//             ),
//             child: isLoading
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         _isLogin ? 'Signing In...' : 'Creating Account...',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   )
//                 : Text(
//                     _isLogin ? 'Sign In' : 'Create Account',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFooterText() {
//     return Column(
//       children: [
//         Text(
//           _isLogin
//               ? 'New to AI Chat Trivia? Tap Sign Up above!'
//               : 'Already have an account? Tap Sign In above!',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 12),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildFeatureBadge('🤖', 'AI Powered'),
//             const SizedBox(width: 12),
//             _buildFeatureBadge('⚡', 'Real-time'),
//             const SizedBox(width: 12),
//             _buildFeatureBadge('🎯', 'Trivia Fun'),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureBadge(String emoji, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(emoji, style: const TextStyle(fontSize: 10)),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _toggleMode(bool isLogin) {
//     if (_isLogin != isLogin) {
//       setState(() {
//         _isLogin = isLogin;
//         _usernameController.clear();
//       });

//       // Clear any previous errors
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       userProvider.clearError();
//     }
//   }

//   Future<void> _handleSubmit() async {
//     if (!_formKey.currentState!.validate()) return;

//     final username = _usernameController.text.trim();
//     final userProvider = Provider.of<UserProvider>(context, listen: false);

//     // Clear previous errors
//     userProvider.clearError();

//     bool success;
//     if (_isLogin) {
//       success = await userProvider.loginUser(username);
//     } else {
//       success = await userProvider.registerUser(username);
//     }

//     if (mounted && success) {
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.check_circle, color: Colors.white),
//               const SizedBox(width: 8),
//               Text(
//                 _isLogin
//                     ? 'Welcome back, $username! 🎉'
//                     : 'Account created! Welcome, $username! 🚀',
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.successColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           duration: const Duration(seconds: 2),
//         ),
//       );

// ignore_for_file: deprecated_member_use

//       // The AppWrapper will automatically navigate to HomeScreen
//       // when userProvider.isLoggedIn becomes true
//     }
//   }
// }
// lib/ui/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  bool _isLogin = true;

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadRegisteredUsers();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _cardAnimationController.forward();
  }

  void _loadRegisteredUsers() async {
    // This will help populate suggestions for login
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.getRegisteredUsernames();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.secondaryColor.withOpacity(0.6),
              AppTheme.accentColor.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildAuthCard(),
                      const SizedBox(height: 20),
                      _buildToggleButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'AI Trivia Chat',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Challenge AI bots and friends in trivia',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(),
                const SizedBox(height: 30),
                _buildUsernameField(),
                const SizedBox(height: 24),
                if (!_isLogin) _buildUsernameSuggestions(),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          _isLogin ? 'Welcome Back' : 'Create Account',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Sign in to continue your trivia journey'
              : 'Join the AI trivia community',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return TextFormField(
          controller: _usernameController,
          enabled: !userProvider.isLoading,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Enter your username',
            prefixIcon: const Icon(Icons.person_outline),
            suffixIcon: _usernameController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _usernameController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textInputAction: TextInputAction.done,
          onChanged: (value) => setState(() {}),
          onFieldSubmitted: (_) => _handleSubmit(),
          validator: UserProvider.validateUsername,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        );
      },
    );
  }

  Widget _buildUsernameSuggestions() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return FutureBuilder<List<String>>(
          future: userProvider.getRegisteredUsernames(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registered users:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: snapshot.data!.take(5).map((username) {
                    return ActionChip(
                      label: Text(username),
                      onPressed: () {
                        _usernameController.text = username;
                        _isLogin = true;
                        setState(() {});
                      },
                      backgroundColor:
                          AppTheme.primaryLightColor.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isLoading = userProvider.isLoading;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLogin ? Icons.login : Icons.person_add,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLogin ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isLogin ? "Don't have an account? " : "Already have an account? ",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isLogin = !_isLogin;
              });
              // Add a subtle animation when toggling
              _cardAnimationController.reset();
              _cardAnimationController.forward();
            },
            child: Text(
              _isLogin ? 'Sign Up' : 'Sign In',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (!userProvider.hasError) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.errorColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userProvider.lastError!,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: AppTheme.errorColor,
                onPressed: userProvider.clearError,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = _usernameController.text.trim();

    bool success;
    if (_isLogin) {
      success = await userProvider.loginUser(username);
    } else {
      success = await userProvider.registerUser(username);
    }

    if (success) {
      if (mounted) {
        // Success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _isLogin
                      ? 'Welcome back, $username!'
                      : 'Account created successfully!',
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      // Error is handled by the provider and shown in _buildErrorMessage
      // Add haptic feedback for error
      HapticFeedback.lightImpact();
    }
  }
}

// Additional helper widgets for enhanced UX
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
