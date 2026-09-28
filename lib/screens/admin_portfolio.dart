import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_client.dart';
import 'package:katala/theme/app_theme.dart';

class AdminPortfolio extends StatefulWidget {
  const AdminPortfolio({super.key});

  @override
  State<AdminPortfolio> createState() => _AdminPortfolioState();
}

class _AdminPortfolioState extends State<AdminPortfolio> {
  List<Map<String, dynamic>> _allProjects = [];
  List<Map<String, dynamic>> _filteredProjects = [];
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _projectStatuses = [
    'Planning',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    Object? projectError;
    Object? requestError;
    try {
      try {
        final response = await ApiClient.get('/admin/projects');
        if (!mounted) return;
        setState(() {
          _allProjects = List<Map<String, dynamic>>.from(response);
        });
        _filterProjects(_searchController.text);
      } catch (error) {
        projectError = error;
      }
      try {
        final requests = await ApiClient.get('/admin/requests');
        if (!mounted) return;
        setState(() {
          _requests = List<Map<String, dynamic>>.from(requests);
        });
      } catch (error) {
        requestError = error;
      }
      if (mounted && (projectError != null || requestError != null)) {
        final error = projectError ?? requestError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to refresh portfolio: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _hasError = projectError != null && _allProjects.isEmpty;
          _isLoading = false;
        });
      }
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
    final descriptionController = TextEditingController(
      text: isEditing ? project['description']?.toString() ?? '' : '',
    );
    final dateController = TextEditingController(
      text: isEditing
          ? project['target_completion_date']?.toString().substring(0, 10) ?? ''
          : '',
    );
    final requestOptions = _requests
        .where((request) => int.tryParse(request['id'].toString()) != null)
        .toList();
    final initialRequestId = isEditing
        ? int.tryParse(project['service_request_id'].toString())
        : null;
    final selectedRequestId = ValueNotifier<int?>(
      requestOptions.any(
            (request) =>
                request['id'].toString() == initialRequestId.toString(),
          )
          ? initialRequestId
          : null,
    );
    final selectedStatus = ValueNotifier<String>(
      isEditing && _projectStatuses.contains(project['status'])
          ? project['status']
          : 'Planning',
    );
    final selectedImage = ValueNotifier<Uint8List?>(null);
    final selectedImageName = ValueNotifier<String?>(null);
    final isSelectingImage = ValueNotifier<bool>(false);
    final isSaving = ValueNotifier<bool>(false);
    final imagePicker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog<void>(
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
                ValueListenableBuilder<int?>(
                  valueListenable: selectedRequestId,
                  builder: (context, requestId, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: requestId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Service request',
                          border: OutlineInputBorder(),
                        ),
                        hint: Text(
                          requestOptions.isEmpty
                              ? 'No service requests available'
                              : 'Select a service request',
                        ),
                        items: requestOptions.map((request) {
                          final id = int.parse(request['id'].toString());
                          final requestNumber =
                              request['request_number']?.toString() ??
                              'Request $id';
                          final projectName =
                              request['project_name']?.toString() ??
                              request['customer_name']?.toString() ??
                              'Service inquiry';
                          final serviceName =
                              request['service']?.toString() ?? '';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(
                              '$requestNumber — $projectName'
                              '${serviceName.isEmpty ? '' : ' • $serviceName'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: requestOptions.isEmpty
                            ? null
                            : (value) {
                                selectedRequestId.value = value;
                                final request = requestOptions.firstWhere(
                                  (item) =>
                                      item['id'].toString() == value.toString(),
                                );
                                nameController.text =
                                    request['project_name']?.toString() ??
                                    nameController.text;
                                locationController.text =
                                    request['location']?.toString() ??
                                    locationController.text;
                              },
                      ),
                      if (requestOptions.isEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Submit a customer service inquiry first, then refresh this screen.',
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (isEditing) ...[
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sector / Category (from service request)',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(project['category']?.toString() ?? '—'),
                  ),
                  const SizedBox(height: 16),
                ],
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
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Project description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Target completion date (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<Uint8List?>(
                  valueListenable: selectedImage,
                  builder: (context, imageBytes, _) {
                    final existingImageUrl =
                        project?['image_url']?.toString() ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageBytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              imageBytes,
                              height: 160,
                              width: double.infinity,
                              cacheWidth: 960,
                              cacheHeight: 720,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _imagePlaceholder(),
                            ),
                          )
                        else if (existingImageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              existingImageUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _imagePlaceholder(),
                            ),
                          )
                        else
                          _imagePlaceholder(),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<bool>(
                          valueListenable: isSelectingImage,
                          builder: (context, isSelecting, _) => OutlinedButton.icon(
                            onPressed: isSelecting
                                ? null
                                : () async {
                                    isSelectingImage.value = true;
                                    try {
                                      final pickedImage = await imagePicker
                                          .pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 1920,
                                            maxHeight: 1440,
                                            imageQuality: 85,
                                          );
                                      if (pickedImage == null) return;
                                      if (!context.mounted) return;

                                      final fileLength = await pickedImage
                                          .length();
                                      if (fileLength > 10 * 1024 * 1024) {
                                        if (context.mounted) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Image is larger than 10 MB. Choose a smaller image.',
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                      final bytes = await pickedImage
                                          .readAsBytes();
                                      if (context.mounted && mounted) {
                                        selectedImage.value = bytes;
                                        selectedImageName.value =
                                            pickedImage.name;
                                      }
                                    } catch (error) {
                                      if (context.mounted && mounted) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Unable to select an image: $error',
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        isSelectingImage.value = false;
                                      }
                                    }
                                  },
                            icon: isSelecting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_outlined),
                            label: ValueListenableBuilder<String?>(
                              valueListenable: selectedImageName,
                              builder: (context, imageName, _) => Text(
                                isSelecting
                                    ? 'Preparing image...'
                                    : imageName == null
                                    ? 'Choose project image'
                                    : 'Change image: $imageName',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'JPG, PNG, or WebP. Images are stored in Supabase Storage.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: selectedStatus,
                  builder: (context, status, _) =>
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(
                          labelText: 'Project status',
                          border: OutlineInputBorder(),
                        ),
                        items: _projectStatuses
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedStatus.value = value;
                        },
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
            ValueListenableBuilder<bool>(
              valueListenable: isSaving,
              builder: (context, saving, _) => ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty ||
                            selectedRequestId.value == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Select a service request and enter a project name.',
                              ),
                            ),
                          );
                          return;
                        }
                        DateTime? targetDate;
                        if (dateController.text.trim().isNotEmpty) {
                          targetDate = DateTime.tryParse(
                            dateController.text.trim(),
                          );
                          if (targetDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter target date in YYYY-MM-DD format.',
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        isSaving.value = true;
                        try {
                          final data = {
                            'service_request_id': selectedRequestId.value,
                            'project_name': nameController.text.trim(),
                            'description': descriptionController.text.trim(),
                            'location': locationController.text.trim(),
                            'target_completion_date': targetDate
                                ?.toIso8601String()
                                .substring(0, 10),
                            'status': selectedStatus.value,
                          };
                          dynamic savedProject;
                          if (isEditing) {
                            await ApiClient.put(
                              '/admin/projects/${project['id']}',
                              data,
                            );
                          } else {
                            savedProject = await ApiClient.post(
                              '/admin/projects',
                              data,
                            );
                          }

                          final imageBytes = selectedImage.value;
                          if (imageBytes != null) {
                            final projectId = isEditing
                                ? project['id'].toString()
                                : savedProject?['id']?.toString();
                            if (projectId == null || projectId.isEmpty) {
                              throw Exception(
                                'Project was saved, but its ID was not returned; the image could not be uploaded.',
                              );
                            }
                            try {
                              await ApiClient.uploadImage(
                                '/admin/projects/$projectId/image',
                                imageBytes,
                                selectedImageName.value ?? 'project-image.jpg',
                              );
                            } catch (imageError) {
                              if (mounted) {
                                navigator.pop();
                                await _fetchProjects();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Project saved, but the image was not uploaded: $imageError',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                          }

                          if (mounted) {
                            navigator.pop();
                            await _fetchProjects();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Project Updated!'
                                      : 'Project Added!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Unable to save project: $e'),
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            isSaving.value = false;
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                ),
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update' : 'Save',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      selectedImage.dispose();
      selectedImageName.dispose();
      isSelectingImage.dispose();
      isSaving.dispose();
      selectedStatus.dispose();
      selectedRequestId.dispose();
      nameController.dispose();
      locationController.dispose();
      descriptionController.dispose();
      dateController.dispose();
    });
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    );
  }

  void _deleteProject(String id) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete project?'),
          content: const Text(
            'Projects with linked billing, inventory, payments, warranty, or maintenance records cannot be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ApiClient.delete('/admin/projects/$id');
      await _fetchProjects();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Project deleted.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to delete project: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  backgroundColor: AppColors.brand,
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
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
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
                    child: CircularProgressIndicator(color: AppColors.brand),
                  )
                : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Unable to load projects.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchProjects,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
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
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 520;
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
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.image, color: Colors.grey),
                          );
                          final title = Text(
                            project['project_name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: isCompact ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                          );
                          final subtitle = Text(
                            '${project['category']} • ${project['location']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                          final actions = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit project',
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _showProjectDialog(project: project),
                              ),
                              IconButton(
                                tooltip: 'Delete project',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _deleteProject(project['id']),
                              ),
                            ],
                          );

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isCompact
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            thumbnail,
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  title,
                                                  const SizedBox(height: 4),
                                                  subtitle,
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: actions,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListTile(
                                    leading: thumbnail,
                                    title: title,
                                    subtitle: subtitle,
                                    trailing: actions,
                                  ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
