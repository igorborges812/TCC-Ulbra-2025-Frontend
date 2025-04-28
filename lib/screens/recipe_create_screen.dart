import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecipeCreateScreen extends StatefulWidget {
  @override
  _RecipeCreateScreenState createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends State<RecipeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = 'http://10.0.2.2:8000/api/recipes';

  String title = '';
  int? selectedCategoryId;
  List<Map<String, String>> ingredients = [];
  List<String> steps = [];
  File? imageFile;
  List<Map<String, dynamic>> categories = [];

  final ImagePicker _picker = ImagePicker();
  final Color appColor = const Color(0xFFFE724C);

  @override
  void initState() {
    super.initState();
    fetchCategories();
    addIngredient();
    addStep();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token recuperado: $token'); // Ajuda a debuggar
    return token;
  }

  Future<void> fetchCategories() async {
    final token = await getToken();

    if (token == null) {
      print('Token não encontrado. Usuário não autenticado.');
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/category/'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print('Resposta categorias: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      setState(() {
        categories = List<Map<String, dynamic>>.from(json.decode(decodedBody));
      });
    } else {
      print('Erro ao carregar categorias: ${response.body}');
    }
  }

  void addIngredient() {
    setState(() {
      ingredients.add({'name': '', 'quantity': '', 'unit': ''});
    });
  }

  void addStep() {
    setState(() {
      steps.add('');
    });
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedCategoryId != null &&
        ingredients.isNotEmpty &&
        steps.isNotEmpty) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final token = await getToken();
      if (token == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token não encontrado. Faça login novamente.')),
        );
        return;
      }

      var uri = Uri.parse('$baseUrl/create/');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      request.fields['title'] = title;
      request.fields['category'] = selectedCategoryId.toString();
      request.fields['ingredients'] = jsonEncode(ingredients);
      request.fields['text_area'] = jsonEncode(steps);

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile!.path));
      }

      final streamedResponse = await request.send();
      Navigator.of(context).pop();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita criada com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print('Erro ao criar receita: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao criar receita.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Criar Receita'),
        backgroundColor: appColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                onSaved: (value) => title = value!,
              ),
              const SizedBox(height: 16),

              const Text('Imagem'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageFile != null
                      ? Image.file(imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover)
                      : Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.add_a_photo)),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Categoria'),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                items: categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat['id'],
                    child: Text(cat['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Selecione a categoria',
                ),
                validator: (value) => value == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              const Text('Ingredientes', style: TextStyle(fontWeight: FontWeight.bold)),
              ...ingredients.asMap().entries.map((entry) {
                int index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Nome'),
                        onChanged: (val) => ingredients[index]['name'] = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Qtd'),
                        onChanged: (val) => ingredients[index]['quantity'] = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Unidade'),
                        onChanged: (val) => ingredients[index]['unit'] = val,
                      ),
                    ),
                  ],
                );
              }),
              TextButton(
                onPressed: addIngredient,
                child: const Text('+ Adicionar ingrediente', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 16),

              const Text('Modo de preparo', style: TextStyle(fontWeight: FontWeight.bold)),
              ...steps.asMap().entries.map((entry) {
                int index = entry.key;
                return TextFormField(
                  decoration: InputDecoration(labelText: 'Passo ${index + 1}'),
                  onChanged: (val) => steps[index] = val,
                );
              }),
              TextButton(
                onPressed: addStep,
                child: const Text('+ Adicionar passo', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Criar Receita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
