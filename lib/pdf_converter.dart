import 'dart:io';
import 'dart:typed_data';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  List<File> images = [];

  final ImagePicker picker = ImagePicker();
  Future getImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        images.add(File(pickedImage.path));
      } else {
        print('No Image Selected ');
      }
    });
  }

  void resetImage() {
    setState(() {});
    images.clear();
  }

// Uint8list : represents a list of unsigned 8-bit integers.
//It's commonly used to handle binary data,
//such as the contents of image files,
  Future<void> convertToPDF() async {
    final pdf = pw.Document();
    // iterate throguh every images and read them as bytes since images is a list
    for (final images in images) {
      final Uint8List imageBytes = await images.readAsBytes();
      final pw.MemoryImage imageFile = pw.MemoryImage(imageBytes);

      //add image
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(imageFile),
        );
      }));
    }
    final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOCUMENTS);
    final file = File('$pathToSave/NewFile.pdf');
    await file.writeAsBytes(await pdf.save());
    print('Path is ${file.path} ');
    final snackBar = SnackBar(
      content: Text('File location: ${file.path}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pdf Converter'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              resetImage();
            },
            icon: const Icon(Icons.restart_alt)),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                convertToPDF();
              });
            },
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          images.isEmpty
              ? const Center(child: Text('No Image Selected '))
              : Expanded(
                  child: ListView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.file(images[index]);
                      }),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
