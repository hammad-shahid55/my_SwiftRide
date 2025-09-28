import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final supabase = Supabase.instance.client;
  String? _profileImageUrl;

  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _emailController.text = user.email ?? '';

    try {
      final response =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (response != null) {
        _nameController.text = response['name'] ?? '';
        _phoneController.text = response['phone'] ?? '';
        _addressController.text = response['address'] ?? '';
        _profileImageUrl = response['profile_pic'];
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _uploading = true;
    });

    try {
      final fileBytes = await picked.readAsBytes();
      final fileExt = picked.path.split('.').last;
      final filePath = 'avatars/${user.id}.$fileExt';

      await supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicURL = supabase.storage.from('avatars').getPublicUrl(filePath);

      setState(() {
        _profileImageUrl = publicURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_formKey.currentState!.validate()) {
      try {
        final currentData =
            await supabase
                .from('profiles')
                .select()
                .eq('id', user.id)
                .maybeSingle();

        if (currentData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile not found!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final Map<String, dynamic> updates = {};

        if (_nameController.text.trim() != (currentData['name'] ?? '')) {
          updates['name'] = _nameController.text.trim();
        }
        if (_phoneController.text.trim() != (currentData['phone'] ?? '')) {
          updates['phone'] = _phoneController.text.trim();
        }
        if (_addressController.text.trim() != (currentData['address'] ?? '')) {
          updates['address'] = _addressController.text.trim();
        }
        if (_profileImageUrl != (currentData['profile_pic'] ?? '')) {
          updates['profile_pic'] = _profileImageUrl;
        }

        if (updates.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes to update.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        updates['updated_at'] = DateTime.now().toIso8601String();

        await supabase.from('profiles').update(updates).eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Update error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _uploading ? null : _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                      child:
                          _profileImageUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                          onPressed: _uploading ? null : _pickAndUploadImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter name';
                  }
                  final nameReg = RegExp(r'^[a-zA-Z ]+$');
                  if (!nameReg.hasMatch(value)) {
                    return 'Only alphabets allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.edit),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter phone number';
                  }
                  final phoneReg = RegExp(r'^03[0-9]{9}$');
                  if (!phoneReg.hasMatch(value)) {
                    return 'Invalid format: 03XXXXXXXXX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.edit),
                ),
                maxLines: 2,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3DF4),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.deepPurpleAccent,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.purpleAccent.withOpacity(
                          0.5,
                        ); // highlight
                      }
                      return null;
                    }),
                  ),
                  child:
                      _uploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Update Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
