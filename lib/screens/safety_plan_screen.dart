import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/safety_plan.dart';
import '../repositories/user_repository.dart';
import '../state/user_state.dart';

class SafetyPlanScreen extends ConsumerStatefulWidget {
  const SafetyPlanScreen({super.key});

  @override
  ConsumerState<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends ConsumerState<SafetyPlanScreen> {
  bool _isLoading = true;
  SafetyPlan _plan = SafetyPlan();

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      final existingPlan = await UserRepository.getSafetyPlan(userId);
      if (existingPlan != null) {
        setState(() {
          _plan = existingPlan;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePlan() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      await UserRepository.saveSafetyPlan(userId, _plan);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safety Plan saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addWarningSign(String sign) {
    setState(() {
      _plan = _plan.copyWith(warningSigns: [..._plan.warningSigns, sign]);
    });
  }

  void _removeWarningSign(int index) {
    setState(() {
      final updated = List<String>.from(_plan.warningSigns);
      updated.removeAt(index);
      _plan = _plan.copyWith(warningSigns: updated);
    });
  }

  void _addCopingStrategy(String strategy) {
    setState(() {
      _plan = _plan.copyWith(copingStrategies: [..._plan.copingStrategies, strategy]);
    });
  }

  void _removeCopingStrategy(int index) {
    setState(() {
      final updated = List<String>.from(_plan.copingStrategies);
      updated.removeAt(index);
      _plan = _plan.copyWith(copingStrategies: updated);
    });
  }

  void _addSafeContact(String name, String number) {
    setState(() {
      _plan = _plan.copyWith(safeContacts: [
        ..._plan.safeContacts,
        Contact(name: name, number: number)
      ]);
    });
  }

  void _removeSafeContact(int index) {
    setState(() {
      final updated = List<Contact>.from(_plan.safeContacts);
      updated.removeAt(index);
      _plan = _plan.copyWith(safeContacts: updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Safety Plan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePlan,
            tooltip: 'Save Plan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StringListSection(
              title: 'Warning Signs',
              subtitle: 'Thoughts, feelings, or behaviors that indicate a crisis is developing.',
              items: _plan.warningSigns,
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              onAdd: _addWarningSign,
              onRemove: _removeWarningSign,
              hintText: 'e.g., Feeling trapped, racing thoughts',
            ),
            const SizedBox(height: 24),
            _StringListSection(
              title: 'Coping Strategies',
              subtitle: 'Things I can do on my own to take my mind off my problems.',
              items: _plan.copingStrategies,
              icon: Icons.self_improvement,
              color: Colors.green,
              onAdd: _addCopingStrategy,
              onRemove: _removeCopingStrategy,
              hintText: 'e.g., Listen to music, take a walk',
            ),
            const SizedBox(height: 24),
            _ContactListSection(
              title: 'Safe Contacts',
              subtitle: 'People I can call for distraction or help.',
              contacts: _plan.safeContacts,
              icon: Icons.phone_rounded,
              color: Colors.blue,
              onAdd: _addSafeContact,
              onRemove: _removeSafeContact,
            ),
          ],
        ),
      ),
    );
  }
}

class _StringListSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> items;
  final IconData icon;
  final Color color;
  final Function(String) onAdd;
  final Function(int) onRemove;
  final String hintText;

  const _StringListSection({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.icon,
    required this.color,
    required this.onAdd,
    required this.onRemove,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Chip(
                  label: Text(items[index]),
                  onDeleted: () => onRemove(index),
                  deleteIcon: const Icon(Icons.close, size: 16),
                );
              },
            ),
            if (items.isNotEmpty) const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ContactListSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Contact> contacts;
  final IconData icon;
  final Color color;
  final Function(String, String) onAdd;
  final Function(int) onRemove;

  const _ContactListSection({
    required this.title,
    required this.subtitle,
    required this.contacts,
    required this.icon,
    required this.color,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      contact.name.characters.first.toUpperCase(),
                      style: TextStyle(color: color),
                    ),
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.number),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onRemove(index),
                  ),
                );
              },
            ),
            if (contacts.isNotEmpty) const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                onAdd(nameController.text, numberController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
