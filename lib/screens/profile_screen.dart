import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final orderCount = context.watch<OrderProvider>().orders.length;
    final theme = context.watch<ThemeProvider>();
    final scheme = Theme.of(context).colorScheme;

    final name = (profile?.fullName?.isNotEmpty ?? false)
        ? profile!.fullName!
        : auth.displayName;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // ---------- Header ----------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.accent,
                    foregroundImage:
                        auth.avatarUrl != null ? NetworkImage(auth.avatarUrl!) : null,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w800)),
                        Text(auth.user?.email ?? '',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text('$orderCount orders',
                            style: TextStyle(
                                fontSize: 13, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---------- Account ----------
          _Group(children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit profile'),
              subtitle: const Text('Name, phone, delivery address'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('My orders'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
            ),
          ]),
          const SizedBox(height: 16),

          // ---------- Appearance ----------
          _Group(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dark_mode_outlined),
                      SizedBox(width: 16),
                      Text('Theme', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light')),
                        ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.phone_android),
                            label: Text('System')),
                        ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark')),
                      ],
                      selected: {theme.mode},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => theme.setMode(s.first),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),

          _Group(children: [
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Log out', style: TextStyle(color: AppColors.error)),
              onTap: () => auth.signOut(),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// Edit full name, phone and default delivery address.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    final auth = context.read<AuthProvider>();
    _name = TextEditingController(text: profile?.fullName ?? auth.displayName);
    _phone = TextEditingController(text: profile?.phone ?? '');
    _address = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<ProfileProvider>().save(
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Profile saved' : 'Could not save profile')),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<ProfileProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '+9627XXXXXXXX',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Default delivery address',
                hintText: 'Amman, Khalda, Street 10, Building 5',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your address is filled in automatically at checkout.',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(
                    height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ),
      ),
    );
  }
}
