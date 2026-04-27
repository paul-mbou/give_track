import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/core/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';

class InviteLeadersScreen extends ConsumerStatefulWidget {
  const InviteLeadersScreen({super.key});

  @override
  ConsumerState<InviteLeadersScreen> createState() =>
      _InviteLeadersScreenState();
}

class _InviteLeadersScreenState extends ConsumerState<InviteLeadersScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<_Invitee> _invitees = [];

  void _addInvitee() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      setState(() {
        _invitees.add(
          _Invitee(
            email: values['email'] as String,
            role: (values['role'] as String?) ?? 'leader',
            projectIds: List<String>.from(
              (values['projects'] as Iterable?) ?? const <String>[],
            ),
          ),
        );
      });
      _formKey.currentState?.reset();
    }
  }

  void _removeInvitee(int index) {
    setState(() {
      _invitees.removeAt(index);
    });
  }

  Future<void> _sendInvites() async {
    if (_invitees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least one invitee',
            style: TextStyle(color: context.colors.onTertiary),
          ),
          backgroundColor: context.colors.tertiary,
        ),
      );
      return;
    }

    // TODO: Send invites via backend
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Sending Invites...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Sending ${_invitees.length} invitation(s)...'),
              ],
            ),
          ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_invitees.length} invitation(s) sent successfully!',
            style: TextStyle(color: context.colors.onPrimary),
          ),
          backgroundColor: context.colors.primary,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Leaders'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Invite Team Members',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add leaders to your projects by email. They will receive an invitation to join.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add Invitee Form
                  AppCard(
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormBuilderTextField(
                            name: 'email',
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address *',
                              hintText: 'leader@example.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email(),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderDropdown<String>(
                            name: 'role',
                            initialValue: 'leader',
                            decoration: const InputDecoration(
                              labelText: 'Role *',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'leader',
                                child: Text('Leader (Full Access)'),
                              ),
                              DropdownMenuItem(
                                value: 'sub_leader',
                                child: Text('Sub-Leader (Limited Edit)'),
                              ),
                              DropdownMenuItem(
                                value: 'viewer',
                                child: Text('Viewer (Read Only)'),
                              ),
                            ],
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderFilterChips<String>(
                            name: 'projects',
                            decoration: const InputDecoration(
                              labelText: 'Assign to Projects',
                              border: InputBorder.none,
                            ),
                            options: const [
                              FormBuilderChipOption(
                                value: '1',
                                child: Text('Community Garden'),
                              ),
                              FormBuilderChipOption(
                                value: '2',
                                child: Text('Youth Coding'),
                              ),
                              FormBuilderChipOption(
                                value: '3',
                                child: Text('Food Drive 2026'),
                              ),
                            ],
                            selectedColor: context.colors.primary.withValues(
                              alpha: 0.2,
                            ),
                            checkmarkColor: context.colors.primary,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: _addInvitee,
                              icon: const Icon(Icons.add),
                              label: const Text('Add to List'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Invitee List
                  if (_invitees.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pending Invitations',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(_invitees.clear);
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._invitees.asMap().entries.map((entry) {
                      final index = entry.key;
                      final invitee = entry.value;
                      return _InviteeCard(
                        invitee: invitee,
                        onRemove: () => _removeInvitee(index),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              boxShadow: [
                BoxShadow(
                  color: context.colors.outline.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _sendInvites,
                  child: Text(
                    'Send ${_invitees.isEmpty ? '' : _invitees.length} Invitation${_invitees.length != 1 ? 's' : ''}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Invitee {
  final String email;
  final String role;
  final List<String> projectIds;

  _Invitee({required this.email, required this.role, required this.projectIds});

  String get roleDisplay {
    switch (role) {
      case 'leader':
        return 'Leader';
      case 'sub_leader':
        return 'Sub-Leader';
      case 'viewer':
        return 'Viewer';
      default:
        return role;
    }
  }
}

class _InviteeCard extends StatelessWidget {
  final _Invitee invitee;
  final VoidCallback onRemove;

  const _InviteeCard({required this.invitee, required this.onRemove});

  Color _getRoleColor(BuildContext context) {
    switch (invitee.role) {
      case 'leader':
        return context.colors.primary;
      case 'sub_leader':
        return context.giveTrack.chartOrange;
      case 'viewer':
        return context.giveTrack.chartNeutral;
      default:
        return context.giveTrack.chartNeutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          child: Text(
            invitee.email[0].toUpperCase(),
            style: TextStyle(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          invitee.email,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                invitee.roleDisplay,
                style: TextStyle(
                  color: _getRoleColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (invitee.projectIds.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '${invitee.projectIds.length} project(s)',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, color: context.colors.error, size: 20),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
