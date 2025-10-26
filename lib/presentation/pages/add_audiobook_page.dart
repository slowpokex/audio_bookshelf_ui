import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../blocs/audiobook/audiobook_bloc.dart';
import '../../application/use_cases/audiobook_use_cases.dart';
import '../../core/services/file_import_service.dart';
import '../../core/services/folder_scan_service.dart';

/// Page for adding a new audiobook to the collection
class AddAudiobookPage extends StatefulWidget {
  const AddAudiobookPage({super.key});

  @override
  State<AddAudiobookPage> createState() => _AddAudiobookPageState();
}

class _AddAudiobookPageState extends State<AddAudiobookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _narratorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publisherController = TextEditingController();
  final _languageController = TextEditingController();
  final _seriesController = TextEditingController();
  final _seriesOrderController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedFolderPath;
  String? _coverImagePath;
  List<AudioFileInfo> _detectedAudioFiles = [];
  bool _isScanningFolder = false;
  bool _isImporting = false;
  bool _isPickingFolder = false;
  bool _isPickingFile = false;
  String? _importError;
  double _importProgress = 0.0;

  final List<String> _supportedAudioFormats = [
    'mp3', 'm4a', 'm4b', 'aac', 'flac', 'ogg', 'wav'
  ];

  final List<String> _supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'webp'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _narratorController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _languageController.dispose();
    _seriesController.dispose();
    _seriesOrderController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Audiobook'),
        leading: IconButton(
          onPressed: _isImporting ? null : _handleCancel,
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _isImporting ? null : _saveAudiobook,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<AudiobookBloc, AudiobookState>(
        listener: (context, state) {
          if (state is AudiobookSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/');
          } else if (state is AudiobookErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Import Section
                _buildFileImportSection(),
                const SizedBox(height: 24),
                
                // Basic Information Section
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                
                // Additional Information Section
                _buildAdditionalInfoSection(),
                const SizedBox(height: 24),
                
                // Series Information Section
                _buildSeriesInfoSection(),
                const SizedBox(height: 24),
                
                // Tags Section
                _buildTagsSection(),
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isImporting ? null : _handleCancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isImporting ? null : _saveAudiobook,
                        child: const Text('Add Audiobook'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio Files Folder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            if (_selectedFolderPath == null) ...[
              ElevatedButton.icon(
                onPressed: (_isImporting || _isPickingFolder) ? null : _pickFolder,
                icon: _isPickingFolder 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.folder_open),
                label: Text(_isPickingFolder ? 'Selecting...' : 'Select Folder'),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a folder containing audio files. Supported formats: ${_supportedAudioFormats.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            path.basename(_selectedFolderPath!),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: _isImporting ? null : () {
                            setState(() {
                              _selectedFolderPath = null;
                              _detectedAudioFiles.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Found ${_detectedAudioFiles.length} audio file(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            
            if (_detectedAudioFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Detected Audio Files',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...(_detectedAudioFiles.map((file) => _buildAudioFileCard(file))),
            ],
            
            if (_isScanningFolder) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _importProgress),
              const SizedBox(height: 8),
              Text(
                'Scanning folder for audio files...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            
            if (_isImporting) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _importProgress),
              const SizedBox(height: 8),
              Text(
                'Importing audio files...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            
            if (_importError != null) ...[
              const SizedBox(height: 8),
              Text(
                _importError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter audiobook title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                hintText: 'Enter author name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Author is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _narratorController,
              decoration: const InputDecoration(
                labelText: 'Narrator',
                hintText: 'Enter narrator name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter audiobook description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                      hintText: 'e.g., Fiction, Non-fiction',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'e.g., 2023',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final year = int.tryParse(value);
                        if (year == null || year < 1800 || year > DateTime.now().year + 1) {
                          return 'Enter a valid year';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _isbnController,
                    decoration: const InputDecoration(
                      labelText: 'ISBN',
                      hintText: 'Enter ISBN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _publisherController,
                    decoration: const InputDecoration(
                      labelText: 'Publisher',
                      hintText: 'Enter publisher name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _languageController,
              decoration: const InputDecoration(
                labelText: 'Language',
                hintText: 'e.g., English, Russian',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cover Image Section
            Text(
              'Cover Image',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            if (_coverImagePath == null) ...[
              ElevatedButton.icon(
                onPressed: (_isImporting || _isPickingFile) ? null : _pickCoverImage,
                icon: _isPickingFile 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.image),
                label: Text(_isPickingFile ? 'Selecting...' : 'Select Cover Image'),
              ),
              const SizedBox(height: 8),
              Text(
                'Supported formats: ${_supportedImageFormats.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(_coverImagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        path.basename(_coverImagePath!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: _isImporting ? null : () {
                        setState(() {
                          _coverImagePath = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Series Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _seriesController,
              decoration: const InputDecoration(
                labelText: 'Series',
                hintText: 'Enter series name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _seriesOrderController,
              decoration: const InputDecoration(
                labelText: 'Series Order',
                hintText: 'e.g., 1, 2, 3',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final order = int.tryParse(value);
                  if (order == null || order < 1) {
                    return 'Enter a valid series order';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Enter tags separated by commas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Example: fiction, mystery, thriller, romance',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioFileCard(AudioFileInfo fileInfo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: fileInfo.isSelected,
                  onChanged: (value) {
                    setState(() {
                      final index = _detectedAudioFiles.indexOf(fileInfo);
                      _detectedAudioFiles[index] = fileInfo.copyWith(isSelected: value);
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileInfo.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (fileInfo.author != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Author: ${fileInfo.author}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (fileInfo.album != null) ...[
                        Text(
                          'Album: ${fileInfo.album}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editAudioFileMetadata(fileInfo),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit metadata',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${fileInfo.fileFormat.toUpperCase()} • ${fileInfo.formattedFileSize} • ${fileInfo.formattedDuration}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFolder() async {
    // Prevent multiple simultaneous folder picker calls
    if (_isPickingFolder) {
      return;
    }

    setState(() {
      _isPickingFolder = true;
      _importError = null;
    });

    try {
      // Check if permissions are already granted
      final hasPermission = await FileImportService.hasStoragePermissions();
      if (!hasPermission) {
        // Request permissions
        final granted = await FileImportService.requestPermissions();
        if (!granted) {
          _showError(FileImportService.getPermissionErrorMessage());
          return;
        }
      }

      final result = await FilePicker.platform.getDirectoryPath();
      
      if (result != null) {
        setState(() {
          _selectedFolderPath = result;
          _importError = null;
        });
        
        // Scan folder for audio files
        await _scanFolderForAudioFiles(result);
      }
    } catch (e) {
      _showError('Failed to pick folder: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFolder = false;
        });
      }
    }
  }

  Future<void> _scanFolderForAudioFiles(String folderPath) async {
    setState(() {
      _isScanningFolder = true;
      _importProgress = 0.0;
    });

    try {
      // Check if folder has audio files
      final hasAudioFiles = await FolderScanService.hasAudioFiles(folderPath);
      if (!hasAudioFiles) {
        _showError('No audio files found in the selected folder');
        return;
      }

      setState(() {
        _importProgress = 0.5;
      });

      // Scan for audio files
      final audioFiles = await FolderScanService.scanFolderForAudioFiles(folderPath);
      
      setState(() {
        _detectedAudioFiles = audioFiles;
        _isScanningFolder = false;
        _importProgress = 1.0;
      });

      // Auto-populate form fields with common metadata if all files have the same author
      _autoPopulateFormFields();
    } catch (e) {
      setState(() {
        _isScanningFolder = false;
      });
      _showError('Failed to scan folder: $e');
    }
  }

  void _autoPopulateFormFields() {
    if (_detectedAudioFiles.isEmpty) return;

    // Find common author
    final authors = _detectedAudioFiles
        .where((file) => file.author != null && file.author!.isNotEmpty)
        .map((file) => file.author!)
        .toSet();
    
    if (authors.length == 1) {
      _authorController.text = authors.first;
    }

    // Find common album
    final albums = _detectedAudioFiles
        .where((file) => file.album != null && file.album!.isNotEmpty)
        .map((file) => file.album!)
        .toSet();
    
    if (albums.length == 1) {
      _seriesController.text = albums.first;
    }

    // Find common year
    final years = _detectedAudioFiles
        .where((file) => file.year != null)
        .map((file) => file.year!)
        .toSet();
    
    if (years.length == 1) {
      _yearController.text = years.first.toString();
    }

    // Find common genre
    final genres = _detectedAudioFiles
        .where((file) => file.genre != null && file.genre!.isNotEmpty)
        .map((file) => file.genre!)
        .toSet();
    
    if (genres.length == 1) {
      _genreController.text = genres.first;
    }
  }

  Future<void> _editAudioFileMetadata(AudioFileInfo fileInfo) async {
    final result = await showDialog<AudioFileInfo>(
      context: context,
      builder: (context) => _AudioFileMetadataDialog(fileInfo: fileInfo),
    );

    if (result != null) {
      setState(() {
        final index = _detectedAudioFiles.indexOf(fileInfo);
        _detectedAudioFiles[index] = result;
      });
      
      // Save metadata to local storage
      try {
        await FolderScanService.saveMetadata(fileInfo.filePath, result);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save metadata: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _importError = message;
    });
  }

  Future<void> _handleCancel() async {
    // Check if there are any unsaved changes
    final hasChanges = _hasUnsavedChanges();
    
    if (!hasChanges) {
      // No changes, just go back
      if (mounted) {
        context.go('/');
      }
      return;
    }

    // Show confirmation dialog
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Don't discard
              },
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Discard changes
              },
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    if (shouldDiscard == true && mounted) {
      context.go('/');
    }
  }

  bool _hasUnsavedChanges() {
    return _titleController.text.isNotEmpty ||
           _authorController.text.isNotEmpty ||
           _narratorController.text.isNotEmpty ||
           _descriptionController.text.isNotEmpty ||
           _genreController.text.isNotEmpty ||
           _yearController.text.isNotEmpty ||
           _isbnController.text.isNotEmpty ||
           _publisherController.text.isNotEmpty ||
           _languageController.text.isNotEmpty ||
           _seriesController.text.isNotEmpty ||
           _seriesOrderController.text.isNotEmpty ||
           _tagsController.text.isNotEmpty ||
           _selectedFolderPath != null ||
           _coverImagePath != null;
  }

  Future<void> _pickCoverImage() async {
    // Prevent multiple simultaneous file picker calls
    if (_isPickingFile) {
      return;
    }

    setState(() {
      _isPickingFile = true;
      _importError = null;
    });

    try {
      // Check if permissions are already granted
      final hasPermission = await FileImportService.hasStoragePermissions();
      if (!hasPermission) {
        // Request permissions
        final granted = await FileImportService.requestPermissions();
        if (!granted) {
          _showError(FileImportService.getPermissionErrorMessage());
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedImageFormats,
        allowMultiple: false,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('File picker timeout - please try again');
        },
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Validate image file
          final validation = await FileImportService.validateImageFile(file.path!);
          if (!validation.isValid) {
            _showError(validation.error!);
            return;
          }
          
          setState(() {
            _coverImagePath = file.path;
          });
        }
      }
    } catch (e) {
      _showError('Failed to pick cover image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }


  Future<void> _saveAudiobook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedFiles = _detectedAudioFiles.where((file) => file.isSelected).toList();
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one audio file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isImporting = true;
      _importProgress = 0.0;
    });

    try {
      // Copy files to app directory
      final audiobooksDir = await FileImportService.getAudiobooksDirectory();
      final coversDir = await FileImportService.getCoversDirectory();
      
      setState(() {
        _importProgress = 0.1;
      });

      // Copy all selected audio files
      final List<String> audioDestinationPaths = [];
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];
        final destinationPath = await FileImportService.copyFileToAppDirectory(
          file.filePath,
          audiobooksDir,
        );
        audioDestinationPaths.add(destinationPath);
        
        setState(() {
          _importProgress = 0.1 + (0.6 * (i + 1) / selectedFiles.length);
        });
      }

      setState(() {
        _importProgress = 0.7;
      });

      // Copy cover image if selected
      String? coverDestinationPath;
      if (_coverImagePath != null) {
        coverDestinationPath = await FileImportService.copyFileToAppDirectory(
          _coverImagePath!,
          coversDir,
        );
      }

      setState(() {
        _importProgress = 0.9;
      });

      // Create audiobook entries for each selected file
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];
        final audioDestinationPath = audioDestinationPaths[i];
        
        // Calculate total duration for the collection (for future use)
        // final totalDuration = selectedFiles.fold<Duration>(
        //   Duration.zero,
        //   (sum, f) => sum + f.duration,
        // );

        final params = CreateAudiobookParams(
          title: file.title,
          author: file.author ?? _authorController.text.trim(),
          narrator: _narratorController.text.trim().isEmpty ? null : _narratorController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          genre: file.genre ?? (_genreController.text.trim().isEmpty ? null : _genreController.text.trim()),
          year: file.year ?? (_yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim())),
          isbn: _isbnController.text.trim().isEmpty ? null : _isbnController.text.trim(),
          publisher: _publisherController.text.trim().isEmpty ? null : _publisherController.text.trim(),
          language: _languageController.text.trim().isEmpty ? null : _languageController.text.trim(),
          duration: file.duration,
          coverImagePath: coverDestinationPath,
          audioFilePath: audioDestinationPath,
          tags: _tagsController.text.trim().isEmpty 
              ? [] 
              : _tagsController.text.trim().split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
          series: file.album ?? (_seriesController.text.trim().isEmpty ? null : _seriesController.text.trim()),
          seriesOrder: file.trackNumber ?? (_seriesOrderController.text.trim().isEmpty 
              ? null 
              : int.tryParse(_seriesOrderController.text.trim())),
          isLocal: true,
          localPath: audioDestinationPath,
        );

        context.read<AudiobookBloc>().add(CreateAudiobookEvent(params: params));
      }

      setState(() {
        _importProgress = 1.0;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported ${selectedFiles.length} audiobook(s)'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to home
      context.go('/');
    } catch (e) {
      setState(() {
        _isImporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create audiobook: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}

/// Dialog for editing audio file metadata
class _AudioFileMetadataDialog extends StatefulWidget {
  final AudioFileInfo fileInfo;

  const _AudioFileMetadataDialog({required this.fileInfo});

  @override
  State<_AudioFileMetadataDialog> createState() => _AudioFileMetadataDialogState();
}

class _AudioFileMetadataDialogState extends State<_AudioFileMetadataDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _albumController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;
  late final TextEditingController _trackNumberController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.fileInfo.title);
    _authorController = TextEditingController(text: widget.fileInfo.author ?? '');
    _albumController = TextEditingController(text: widget.fileInfo.album ?? '');
    _yearController = TextEditingController(text: widget.fileInfo.year?.toString() ?? '');
    _genreController = TextEditingController(text: widget.fileInfo.genre ?? '');
    _trackNumberController = TextEditingController(text: widget.fileInfo.trackNumber?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _trackNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Metadata - ${widget.fileInfo.fileName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _albumController,
              decoration: const InputDecoration(
                labelText: 'Album',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final year = int.tryParse(value);
                        if (year == null || year < 1800 || year > DateTime.now().year + 1) {
                          return 'Enter a valid year';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _trackNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Track Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final track = int.tryParse(value);
                        if (track == null || track < 1) {
                          return 'Enter a valid track number';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Genre',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMetadata,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveMetadata() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedFileInfo = widget.fileInfo.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
      album: _albumController.text.trim().isEmpty ? null : _albumController.text.trim(),
      year: _yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim()),
      genre: _genreController.text.trim().isEmpty ? null : _genreController.text.trim(),
      trackNumber: _trackNumberController.text.trim().isEmpty ? null : int.tryParse(_trackNumberController.text.trim()),
    );

    Navigator.of(context).pop(updatedFileInfo);
  }

}
