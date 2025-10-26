import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/theme_service.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_bloc_provider.dart';

/// Settings screen with integrated theme selection and other app preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // If no previous screen, go to home
              context.go('/');
            }
          },
          tooltip: 'Back',
        ),
      ),
      body: ThemeBlocConsumer(
        listener: (context, state) {
          if (state is ThemeErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ThemeBloc>().add(const ThemeInitializeEvent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ThemeLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is ThemeErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ThemeBloc>().add(const ThemeInitializeEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is ThemeLoadedState) {
            return _buildSettingsContent(context, state);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
  
  Widget _buildSettingsContent(BuildContext context, ThemeLoadedState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appearance Section
          _buildAppearanceSection(context, state),
          
          const SizedBox(height: 32),
          
          // Audio Settings Section
          _buildAudioSection(context),
          
          const SizedBox(height: 32),
          
          // Library Settings Section
          _buildLibrarySection(context),
          
          const SizedBox(height: 32),
          
          // About Section
          _buildAboutSection(context),
          
          const SizedBox(height: 32),
          
          // Back to Main Screen Button
          _buildBackToMainButton(context),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildAppearanceSection(BuildContext context, ThemeLoadedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              // Theme Mode Selection
              ListTile(
                leading: Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  state.currentMode == ThemeMode.light
                      ? 'Light theme'
                      : state.currentMode == ThemeMode.dark
                          ? 'Dark theme'
                          : 'System default',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showThemeSelectionDialog(context, state);
                },
              ),
              
              const Divider(height: 1),
              
              // Quick Theme Toggle
              ListTile(
                leading: Icon(
                  state.currentMode == ThemeMode.dark 
                      ? Icons.light_mode 
                      : state.currentMode == ThemeMode.light 
                          ? Icons.dark_mode 
                          : Icons.brightness_auto,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  state.currentMode == ThemeMode.dark 
                      ? 'Switch to Light'
                      : state.currentMode == ThemeMode.light 
                          ? 'Switch to Dark'
                          : 'Quick Toggle',
                ),
                subtitle: const Text('Quickly switch between light and dark themes'),
                onTap: () {
                  context.read<ThemeBloc>().add(const ThemeToggleEvent());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAudioSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.volume_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Default Volume'),
                subtitle: const Text('Set the default volume for audio playback'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement volume settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Volume settings coming soon')),
                  );
                },
              ),
              
              const Divider(height: 1),
              
              ListTile(
                leading: Icon(
                  Icons.speed,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Playback Speed'),
                subtitle: const Text('Set the default playback speed'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement speed settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Speed settings coming soon')),
                  );
                },
              ),
              
              const Divider(height: 1),
              
              SwitchListTile(
                secondary: Icon(
                  Icons.skip_next,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Auto-skip Silence'),
                subtitle: const Text('Automatically skip silent parts'),
                value: false, // TODO: Implement this setting
                onChanged: (value) {
                  // TODO: Implement auto-skip setting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Auto-skip settings coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLibrarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Library',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Download Location'),
                subtitle: const Text('Choose where to store downloaded audiobooks'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement download location settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download settings coming soon')),
                  );
                },
              ),
              
              const Divider(height: 1),
              
              SwitchListTile(
                secondary: Icon(
                  Icons.cloud_download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Auto-download'),
                subtitle: const Text('Automatically download new audiobooks'),
                value: false, // TODO: Implement this setting
                onChanged: (value) {
                  // TODO: Implement auto-download setting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Auto-download settings coming soon')),
                  );
                },
              ),
              
              const Divider(height: 1),
              
              SwitchListTile(
                secondary: Icon(
                  Icons.sync,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Sync Progress'),
                subtitle: const Text('Sync reading progress across devices'),
                value: true, // TODO: Implement this setting
                onChanged: (value) {
                  // TODO: Implement sync setting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync settings coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
                onTap: () {
                  // TODO: Show version info dialog
                },
              ),
              
              const Divider(height: 1),
              
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help and contact support'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement help section
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help section coming soon')),
                  );
                },
              ),
              
              const Divider(height: 1),
              
              ListTile(
                leading: Icon(
                  Icons.privacy_tip_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Privacy Policy'),
                subtitle: const Text('Read our privacy policy'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy policy coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showThemeSelectionDialog(BuildContext context, ThemeLoadedState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeService.instance.getAvailableThemeModes().map((option) {
            return RadioListTile<ThemeMode>(
              title: Text(option.name),
              subtitle: Text(option.description),
              value: option.mode,
              groupValue: state.currentMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(ThemeSetModeEvent(value));
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackToMainButton(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.home,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Back to Main Screen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Return to the audiobook library',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate back to home screen
                    context.go('/');
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go to Library'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
