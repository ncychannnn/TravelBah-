import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../services/cloudinary_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
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
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Upload Photo
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: (selectedImage == null && webImage == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 55,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Upload Photo",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Tap to choose an image",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
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

          const SizedBox(height: 30),

          const Text(
            "Title",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Enter title",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Location",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: locationController,
            decoration: InputDecoration(
              hintText: "Enter location",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Category",
            style: TextStyle(
              fontWeight: FontWeight.bold,
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
                decoration: InputDecoration(
                  hintText: "Choose or type a category",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text(
            "Caption",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: captionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Share your travel experience...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 35),

          SizedBox(
            width: double.infinity,
            height: 55,
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
                backgroundColor: const Color(0xff5A8DEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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