import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pour choisir une image (photo profil)
  Future<XFile?> pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery, // ou ImageSource.camera
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80, // compresser pour ne pas dépasser 1MB
    );
    if (pickedFile != null) {
      return XFile(pickedFile.path);
    }
    return null;
  }

  /// Pour choisir n'importe quel fichier (carte scolaire, CIN, attestation)
  Future<File?> pickFile({required FileType type, int? maxSizeInBytes}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      // Vérification de la taille
      if (maxSizeInBytes != null && file.lengthSync() > maxSizeInBytes) {
        return null;
      }
      return file;
    }
    return null;
  }
}
