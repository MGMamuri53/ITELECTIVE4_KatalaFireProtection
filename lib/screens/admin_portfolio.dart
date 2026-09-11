import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AdminPortfolio extends StatefulWidget {
  const AdminPortfolio({super.key});

  @override
  State<AdminPortfolio> createState() => _AdminPortfolioState();
}

class _AdminPortfolioState extends State<AdminPortfolio> {
  List<Map<String, dynamic>> _allProjects = [];
  List<Map<String, dynamic>> _filteredProjects = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _portfolioCategories = [
    'Commercial',
    'Industrial',
    'Residential',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/admin/projects');
      setState(() {
        _allProjects = List<Map<String, dynamic>>.from(response);
        _filteredProjects = _allProjects;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProjects = _allProjects;
      } else {
        _filteredProjects = _allProjects.where((project) {
          final name = (project['project_name'] ?? '').toString().toLowerCase();
          final location = (project['location'] ?? '').toString().toLowerCase();
          final category = (project['category'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) ||
              location.contains(searchLower) ||
              category.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showProjectDialog({Map<String, dynamic>? project}) {
    final isEditing = project != null;
    final nameController = TextEditingController(
      text: isEditing ? project['project_name'] : '',
    );
    final locationController = TextEditingController(
      text: isEditing ? project['location'] : '',
    );
    final dateController = TextEditingController(
      text: isEditing ? project['completion_date'] : '',
    );
    final imageController = TextEditingController(
      text: isEditing ? project['image_url'] : '',
    );

    String selectedCategory =
        (isEditing && _portfolioCategories.contains(project['category']))
        ? project['category']
        : _portfolioCategories.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            isEditing ? 'Edit Project' : 'Add New Project',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name (e.g. SM Mall of Asia)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Sector / Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _portfolioCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (e.g. Pasay City)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Completion Date (e.g. Q3 2023)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                try {
                  throw Exception(
                    'Portfolio editing needs Laravel project create/update endpoints.',
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _fetchProjects();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing ? 'Project Updated!' : 'Project Added!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
              ),
              child: Text(
                isEditing ? 'Update' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProject(String id) async {
    try {
      throw Exception(
        'Portfolio deletion needs a Laravel project delete endpoint.',
      );
      _fetchProjects();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BINALOT SA WRAP PARA HINDI MA-CUT ANG BUTTON SA MOBILE
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Project Portfolio',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage case studies and completed projects.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showProjectDialog(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Add Project',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProjects,
                    decoration: const InputDecoration(
                      hintText: 'Search Project Name, Category, or Location...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
                  )
                : _filteredProjects.isEmpty
                ? const Center(
                    child: Text(
                      'No projects match your search.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child:
                                project['image_url'] != null &&
                                    project['image_url'].toString().isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      project['image_url'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.image, color: Colors.grey),
                          ),
                          title: Text(
                            project['project_name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${project['category']} • ${project['location']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _showProjectDialog(project: project),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _deleteProject(project['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
