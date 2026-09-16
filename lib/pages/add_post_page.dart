import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../services/cloudinary_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_back_button.dart';

class AddPostPage extends StatefulWidget {
  final PostModel? editingPost;

  const AddPostPage({
    super.key,
    this.editingPost,
  });

  @override
  State<AddPostPage> createState() =>
      _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {

  File? selectedImage;
  Uint8List? webImage;

  final ImagePicker picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final categoryController = TextEditingController();
  final captionController = TextEditingController();

  bool isLoading = false;

  static const List<String> categories = [
    "Nature",
    "Islands",
    "Wildlife",
    "Adventure",
    "Food",
    "Culture",
    "City",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.editingPost != null) {

      titleController.text =
          widget.editingPost!.title;

      locationController.text =
          widget.editingPost!.location;

      categoryController.text =
          widget.editingPost!.category;

      captionController.text =
          widget.editingPost!.caption;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    categoryController.dispose();
    captionController.dispose();
    super.dispose();
  }

      Future<void> pickImage() async {
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          if (kIsWeb) {
            webImage = await image.readAsBytes();
          } else {
            selectedImage = File(image.path);
          }

          setState(() {});
        }
      }

          Future<void> uploadPost() async {
            // Validate required fields
            if (titleController.text.trim().isEmpty ||
                locationController.text.trim().isEmpty ||
                categoryController.text.trim().isEmpty ||
                captionController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please fill in all fields."),
                ),
              );
              return;
            }

            // Check image
            if ((!kIsWeb && selectedImage == null) ||
                (kIsWeb && webImage == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select an image."),
                ),
              );
              return;
            }

            setState(() {
              isLoading = true;
            });

            try {
              String? imageUrl;

              // Upload image to Cloudinary
              if (kIsWeb) {
                imageUrl =
                    await CloudinaryService().uploadImageFromBytes(webImage!);
              } else {
                imageUrl =
                    await CloudinaryService().uploadImage(selectedImage!);
              }

              if (imageUrl == null) {
                throw Exception("Image upload failed.");
              }

              // Current user
              final user = FirebaseAuth.instance.currentUser!;

              // Read user profile
              final userDoc = await FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .get();

                  final data = userDoc.data() ?? {};

                  final username = data["name"] ?? "Traveler";
                  final profileImage = data["profileImage"] ?? "";
              // Create document ID
              final postId =
                  FirebaseFirestore.instance.collection("posts").doc().id;

              // Create model
              final post = PostModel(
                id: postId,
                uid: user.uid,
                username: username,
                profileImage: profileImage,
                title: titleController.text.trim(),
                location: locationController.text.trim(),
                category: categoryController.text.trim(),
                caption: captionController.text.trim(),
                imageUrl: imageUrl,
                likesCount: 0,
                commentsCount: 0,
                createdAt: DateTime.now(),
              );

              // Save to Firestore
              await FirestoreService().createPost(post);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Post uploaded successfully!"),
                ),
              );

              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                ),
              );
            } finally {
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            }
          }

          Future<void> updatePost() async {
  if (!formKey.currentState!.validate()) return;

  setState(() {
    isLoading = true;
  });

  try {
    String imageUrl = widget.editingPost!.imageUrl;

    // Upload a new image only if user selected one
    if ((selectedImage != null) || (webImage != null)) {
      if (kIsWeb) {
        imageUrl = await CloudinaryService()
                .uploadImageFromBytes(webImage!) ??
            imageUrl;
      } else {
        imageUrl = await CloudinaryService()
                .uploadImage(selectedImage!) ??
            imageUrl;
      }
    }

    final updatedPost = PostModel(
      id: widget.editingPost!.id,
      uid: widget.editingPost!.uid,
      username: widget.editingPost!.username,
      profileImage: widget.editingPost!.profileImage,
      title: titleController.text.trim(),
      location: locationController.text.trim(),
      category: categoryController.text.trim(),
      caption: captionController.text.trim(),
      imageUrl: imageUrl,
      likesCount: widget.editingPost!.likesCount,
      commentsCount: widget.editingPost!.commentsCount,
      createdAt: widget.editingPost!.createdAt,
    );

    await FirestoreService().updatePost(updatedPost);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Post updated successfully!",
        ),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(
          widget.editingPost == null
              ? "Share Your Journey"
              : "Edit Journey",
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Upload Photo Card
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: (selectedImage == null && webImage == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Upload Cover Photo",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tap to select an image from gallery",
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb
                                ? Image.memory(
                                    webImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    selectedImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Title",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: "Enter post title",
                    hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
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

                const SizedBox(height: 20),

                const Text(
                  "Location",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: locationController,
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: "e.g., Mount Kinabalu, Sabah",
                    hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
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

                const SizedBox(height: 20),

                const Text(
                  "Category",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue value) {
                    if (value.text.isEmpty) {
                      return categories;
                    }

                    return categories.where(
                      (category) => category
                          .toLowerCase()
                          .contains(value.text.toLowerCase()),
                    );
                  },
                  onSelected: (value) {
                    categoryController.text = value;
                  },
                  fieldViewBuilder: (
                    context,
                    controller,
                    focusNode,
                    onEditingComplete,
                  ) {
                    controller.text = categoryController.text;

                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );

                    controller.addListener(() {
                      categoryController.text = controller.text;
                    });

                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: "Choose or type a category",
                        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
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
                    );
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  "Caption",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: captionController,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: "Share your travel experience...",
                    hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
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
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 54,
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
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F5A8DEE),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading
                        ? null
                        : () {
                            if (widget.editingPost == null) {
                              uploadPost();
                            } else {
                              updatePost();
                            }
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.editingPost == null
                                  ? "POST"
                                  : "SAVE CHANGES",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

              ],
            ),
          ),
        ),
      ),
    );
  }
}