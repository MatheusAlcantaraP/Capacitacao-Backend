import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle = '';
  var _enteredDescription = '';

  File? _selectedImage;
  LatLng? _selectedLocation;
  var _isGettingLocation = false;
  var _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickedFile == null) return;
    setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _getCurrentLocation() async {
    final location = Location();

    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    setState(() => _isGettingLocation = true);
    final locationData = await location.getLocation();
    setState(() {
      _selectedLocation = LatLng(locationData.latitude!, locationData.longitude!);
      _isGettingLocation = false;
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tire uma foto do problema.')));
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture a localização.')));
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('report_images').child(fileName);
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('reports').add({
        'title': _enteredTitle,
        'description': _enteredDescription,
        'imageUrl': imageUrl,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'userId': user.uid,
        'userEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar reporte: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRIAR REPORT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título do problema'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe um título.' : null,
                onSaved: (value) => _enteredTitle = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) =>
                    (value == null || value.trim().length < 10) ? 'Descreva com pelo menos 10 caracteres.' : null,
                onSaved: (value) => _enteredDescription = value!,
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, color:Color.fromARGB(255, 71, 143, 211)),
                    label: const Text('TIRAR FOTO'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: 250),
                    )
                  : const Text('NENHUMA FOTO FOI TIRADA'),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location, color:Color.fromARGB(255, 71, 143, 211)),
                    label: const Text('CAPTURAR LOCALIZAÇÃO'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: _isGettingLocation
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedLocation != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(target: _selectedLocation!, zoom: 16),
                              markers: {Marker(markerId: const MarkerId('reportLocation'), position: _selectedLocation!)},
                              zoomControlsEnabled: false,
                              liteModeEnabled: true,
                            ),
                          )
                        : const Text('LOCALIZAÇÃO NÃO CAPTURADA'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        child: const Icon(Icons.check),
      ),
    );
  }
}