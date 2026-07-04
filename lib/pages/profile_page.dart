import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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

  bool _isSaving = false;

  @override
void dispose() {
  _usernameController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        centerTitle: true,

        leading: widget.showBackButton
            ? const CustomBackButton()
            : null,

        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
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
              vertical: 20,
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xffE7F1FF),
        backgroundImage: profileImage.isNotEmpty
            ? NetworkImage(profileImage)
            : null,
        child: profileImage.isEmpty
            ? const Icon(
                Icons.person,
                size: 65,
                color: Color(0xff5A8DEE),
              )
            : null,
      ),
    ),

        const SizedBox(height: 20),

        Text(
          user["name"] ?? "",
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          user["email"] ?? "",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 35),
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
            Icons.travel_explore,
            color: Color(0xff5A8DEE),
            size: 22,
          ),

          SizedBox(width: 8),

          Text(
            "Travel Activity",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),

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
                  icon: Icons.favorite,
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
                  icon: Icons.bookmark,
                  title: "Saved",
                  value: "${snapshot.data ?? 0}",
                );
              },
            ),
          ),
        ],
      ),

      const SizedBox(height: 35),
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
            Icons.settings,
            color: Color(0xff5A8DEE),
            size: 22,
          ),

          SizedBox(width: 8),

          Text(
            "Account",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),

      ProfileOptionCard(
        icon: Icons.person_outline,
        title: "Edit Profile",
        subtitle: "Update username & picture",
        iconColor: Colors.blue,
        onTap: () {
          _showEditProfileBottomSheet(user);
        },
      ),

      const SizedBox(height: 15),

      ProfileOptionCard(
        icon: Icons.lock_outline,
        title: "Change Password",
        subtitle: "Update your password",
        iconColor: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChangePasswordPage(),
            ),
          );
        },
      ),

      const SizedBox(height: 15),

      ProfileOptionCard(
        icon: Icons.logout,
        title: "Logout",
        subtitle: "Sign out from TravelBah!",
        iconColor: Colors.red,
        onTap: _showLogoutDialog,
      ),

      const SizedBox(height: 50),
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
      top: Radius.circular(25),
    ),
  ),
  builder: (context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Profile Picture",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                       onTap: () async {
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

                          setModalState(() {});
                        }
                      },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
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
                                        color: Color(0xff5A8DEE),
                                      )
                                    : null,
                              ),
                            ),

                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xff5A8DEE),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

            const SizedBox(height: 25),

            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: const Text(
                "Remove Profile Picture",
              ),
              onTap: () {
                Navigator.pop(context);

                _showRemovePictureDialog();
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
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
                            "Profile updated successfully 🎉",
                          ),
                        ),
                      );

                      setState(() {
                        _selectedProfileImage = null;
                      });
                    },
                    child: const Text(
                      "Save Changes",
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
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          "Logout",
        ),
        content: const Text(
          "Are you sure you want to logout?",
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text(
              "Cancel",
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
          borderRadius:
              BorderRadius.circular(18),
        ),

        title: const Row(
          children: [

            Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),

            SizedBox(width: 10),

            Text(
              "Remove Picture",
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
            child: const Text(
              "Cancel",
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
                    "Profile picture removed successfully 🗑️",
                  ),
                ),
              );
            },
            child: const Text(
              "Remove",
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