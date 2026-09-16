import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../services/cloudinary_service.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../widgets/activity_card.dart';
import '../widgets/profile_option_card.dart';
import 'change_password_page.dart';
import '../widgets/custom_back_button.dart';


class ProfilePage extends StatefulWidget {
  final bool showBackButton;

  const ProfilePage({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService firestore = FirestoreService();

  final String uid =
      FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController _usernameController =
    TextEditingController();

  File? _selectedProfileImage;
  Uint8List? _webProfileImage;

  final ImagePicker _picker = ImagePicker();

  @override
void dispose() {
  _usernameController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,

        leading: widget.showBackButton
            ? const CustomBackButton()
            : null,

        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: StreamBuilder(
        stream: firestore.getCurrentUser(uid),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user =
              snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),

            child: Column(
              children: [

                _buildHeader(user),

                _buildTravelActivity(),

                _buildAccountSection(user),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    Map<String, dynamic> user,
  ) {
    final profileImage =
        user["profileImage"] ?? "";

    return Column(
      children: [

    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: const Color(0xffE7F1FF),
        backgroundImage: profileImage.isNotEmpty
            ? NetworkImage(profileImage)
            : null,
        child: profileImage.isEmpty
            ? const Icon(
                Icons.person,
                size: 55,
                color: AppColors.primary,
              )
            : null,
      ),
    ),

        const SizedBox(height: 16),

        Text(
          user["name"] ?? "",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          user["email"] ?? "",
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTravelActivity() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: const [

          Icon(
            Icons.travel_explore_rounded,
            color: AppColors.primary,
            size: 20,
          ),

          SizedBox(width: 8),

          Text(
            "Travel Activity",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      Row(
        children: [

          Expanded(
            child: StreamBuilder(
              stream: firestore.getMyPosts(uid),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;

                return ActivityCard(
                  icon: Icons.article_outlined,
                  title: "Posts",
                  value: count.toString(),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: StreamBuilder(
              stream: firestore.getTotalLikes(uid),
              builder: (context, snapshot) {
                return ActivityCard(
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.red.shade400,
                  title: "Likes",
                  value: "${snapshot.data ?? 0}",
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: StreamBuilder(
              stream: firestore.getWishlistCount(uid),
              builder: (context, snapshot) {
                return ActivityCard(
                  icon: Icons.bookmark_rounded,
                  iconColor: Colors.amber.shade600,
                  title: "Saved",
                  value: "${snapshot.data ?? 0}",
                );
              },
            ),
          ),
        ],
      ),

      const SizedBox(height: 32),
    ],
  );
}

Widget _buildAccountSection(
  Map<String, dynamic> user,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Row(
        children: const [

          Icon(
            Icons.settings_rounded,
            color: AppColors.primary,
            size: 20,
          ),

          SizedBox(width: 8),

          Text(
            "Account",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      ProfileOptionCard(
        icon: Icons.person_outline_rounded,
        title: "Edit Profile",
        subtitle: "Update username & picture",
        iconColor: Colors.blue.shade600,
        onTap: () {
          _showEditProfileBottomSheet(user);
        },
      ),

      const SizedBox(height: 12),

      ProfileOptionCard(
        icon: Icons.lock_outline_rounded,
        title: "Change Password",
        subtitle: "Update your password",
        iconColor: Colors.orange.shade600,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChangePasswordPage(),
            ),
          );
        },
      ),

      const SizedBox(height: 12),

      ProfileOptionCard(
        icon: Icons.logout_rounded,
        title: "Logout",
        subtitle: "Sign out from TravelBah!",
        iconColor: Colors.red.shade600,
        onTap: _showLogoutDialog,
      ),

      const SizedBox(height: 40),
    ],
  );
}

void _showEditProfileBottomSheet(
  Map<String, dynamic> user,
) {
  _usernameController.text = user["name"] ?? "";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Profile Picture",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      await _pickProfileImage();
                      setModalState(() {});
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color(0xffE7F1FF),
                            backgroundImage: kIsWeb
                                ? (_webProfileImage != null
                                    ? MemoryImage(_webProfileImage!)
                                    : ((user["profileImage"] ?? "").isNotEmpty
                                        ? NetworkImage(user["profileImage"])
                                        : null))
                                : (_selectedProfileImage != null
                                    ? FileImage(_selectedProfileImage!)
                                    : ((user["profileImage"] ?? "").isNotEmpty
                                        ? NetworkImage(user["profileImage"])
                                        : null)),
                            child: _selectedProfileImage == null &&
                                    _webProfileImage == null &&
                                    (user["profileImage"] ?? "").isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        ),

                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: _usernameController,
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 16),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dense: true,
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    "Remove Profile Picture",
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showRemovePictureDialog();
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textGrey,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF739EF1),
                              AppColors.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final username =
                                _usernameController.text.trim();

                            if (username.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Username cannot be empty",
                                  ),
                                ),
                              );
                              return;
                            }

                            await firestore.updateUsername(
                              uid,
                              username,
                            );

                            String? imageUrl;

                            if (kIsWeb) {
                              if (_webProfileImage != null) {
                                imageUrl = await CloudinaryService()
                                    .uploadImageFromBytes(_webProfileImage!);
                              }
                            } else {
                              if (_selectedProfileImage != null) {
                                imageUrl = await CloudinaryService()
                                    .uploadImage(_selectedProfileImage!);
                              }
                            }

                            if (imageUrl != null) {
                              await firestore.updateProfilePicture(
                                uid,
                                imageUrl,
                              );
                            }

                            if (!mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                    "Profile updated successfully",
                                  ),
                                ),
                              );

                            setState(() {
                              _selectedProfileImage = null;
                              _webProfileImage = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout from TravelBah?",
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textGrey,
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              // Close the dialog first
              Navigator.of(context).pop();

              // Give it a moment to close
              await Future.delayed(
                const Duration(milliseconds: 150),
              );

              // Sign out
              await FirebaseAuth.instance.signOut();
            },
            child: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

void _showRemovePictureDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        title: const Row(
          children: [

            Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),

            SizedBox(width: 10),

            Text(
              "Remove Picture",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        content: const Text(
          "Are you sure you want to remove your profile picture?",
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textGrey,
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {

              await firestore.removeProfilePicture(
                uid,
              );

              if (!mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "Profile picture removed successfully",
                  ),
                ),
              );
            },
            child: const Text(
              "Remove",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _pickProfileImage() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (image != null) {
    if (kIsWeb) {
      _webProfileImage = await image.readAsBytes();
    } else {
      _selectedProfileImage = File(image.path);
    }

    setState(() {});
  }
}
}