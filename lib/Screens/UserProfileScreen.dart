import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/HomeScreen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _profileImageUrl;

  final supabase = Supabase.instance.client;

  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('No user.');
      return;
    }

    _emailController.text = user.email ?? '';

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'name': '',
          'phone': '',
          'address': '',
          'profile_pic': null,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        final name = response['name'] ?? '';
        final phone = response['phone'] ?? '';
        final address = response['address'] ?? '';
        _profileImageUrl = response['profile_pic'];

        if (name.isNotEmpty && phone.isNotEmpty && address.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }

        _nameController.text = name;
        _phoneController.text = phone;
        _addressController.text = address;
      }

      setState(() {});
    } catch (e) {
      debugPrint('Load profile error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('No user.');
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked == null) return;

      setState(() {
        _uploading = true;
      });

      final fileBytes = await picked.readAsBytes();
      final fileExt = picked.path.split('.').last;
      final filePath = 'avatars/${user.id}.$fileExt';

      await supabase.storage.from('avatars').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicURL =
          supabase.storage.from('avatars').getPublicUrl(filePath);

      setState(() {
        _profileImageUrl = publicURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded!')),
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('No user.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      final updates = {
        'id': user.id,
        'email': user.email,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'profile_pic': _profileImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        await supabase.from('profiles').upsert(updates);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        debugPrint('Save error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _uploading ? null : _pickAndUploadImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
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
                ),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3DF4),
                  ),
                  child: _uploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Profile',
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
