import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminPortfolio extends StatefulWidget {
  const AdminPortfolio({super.key});

  @override
  State<AdminPortfolio> createState() => _AdminPortfolioState();
}

class _AdminPortfolioState extends State<AdminPortfolio> {
  static const double maxContentWidth = 1280;
  static const double twoColumnBreakpoint = 900;
  static const double inlineActionBreakpoint = 420;

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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
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
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sector / Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _portfolioCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Container(
                margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // BINALOT SA WRAP PARA HINDI MA-CUT ANG BUTTON SA MOBILE
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 620,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Project Portfolio',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Manage case studies and completed projects.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showProjectDialog(),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Add Project',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brand,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isDesktop ? 24 : 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _filterProjects,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Search Project Name, Category, or Location...',
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, content) {
                          if (_isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brand,
                              ),
                            );
                          }
                          if (_filteredProjects.isEmpty) {
                            return const Center(
                              child: Text(
                                'No projects match your search.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return _buildProjectList(content.maxWidth);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectList(double availableWidth) {
    final columns = availableWidth >= twoColumnBreakpoint ? 2 : 1;
    final gap = columns > 1 ? 16.0 : 10.0;
    final itemWidth = (availableWidth - gap * (columns - 1)) / columns;
    final rowCount = (_filteredProjects.length + columns - 1) ~/ columns;

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: columns == 1 ? _filteredProjects.length : rowCount,
      separatorBuilder: (context, index) => SizedBox(height: gap),
      itemBuilder: (context, index) {
        if (columns == 1) {
          return _buildProjectCard(_filteredProjects[index], itemWidth);
        }

        final first = _filteredProjects[index * columns];
        final hasSecond = (index * columns + 1) < _filteredProjects.length;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: itemWidth,
                child: _buildProjectCard(first, itemWidth),
              ),
              SizedBox(width: gap),
              if (hasSecond)
                SizedBox(
                  width: itemWidth,
                  child: _buildProjectCard(
                    _filteredProjects[index * columns + 1],
                    itemWidth,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(
    Map<String, dynamic> project,
    double availableWidth,
  ) {
    final thumbnail = Container(
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
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.image, color: Colors.grey),
              ),
            )
          : const Icon(Icons.image, color: Colors.grey),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          project['project_name'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          '${project['category']} • ${project['location']}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.edit_outlined,
          color: Colors.blue,
          tooltip: 'Edit project',
          onPressed: () => _showProjectDialog(project: project),
        ),
        _actionButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          tooltip: 'Delete project',
          onPressed: () => _deleteProject(project['id']),
        ),
      ],
    );

    final inlineActions = availableWidth >= inlineActionBreakpoint;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: inlineActions
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                thumbnail,
                const SizedBox(width: 14),
                Expanded(child: details),
                const SizedBox(width: 8),
                actions,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    thumbnail,
                    const SizedBox(width: 14),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      onPressed: onPressed,
    );
  }
}
