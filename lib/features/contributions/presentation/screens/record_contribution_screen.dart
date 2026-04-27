import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/core/widgets/common_widgets.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/presentation/providers/contribution_provider.dart';
import 'package:give_track/features/projects/presentation/providers/project_provider.dart';
import 'package:go_router/go_router.dart';

class RecordContributionScreen extends ConsumerStatefulWidget {
  const RecordContributionScreen({super.key});

  @override
  ConsumerState<RecordContributionScreen> createState() =>
      _RecordContributionScreenState();
}

class _RecordContributionScreenState
    extends ConsumerState<RecordContributionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final contributorsAsync = ref.watch(contributorsProvider);
    final contributionState = ref.watch(contributionNotifierProvider);

    ref.listen(contributionNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Contribution recorded successfully!',
                style: TextStyle(color: context.colors.onPrimary),
              ),
              backgroundColor: context.colors.primary,
            ),
          );
          context.pop();
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: context.colors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Contribution'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New Contribution',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Record a new contribution from a contributor',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Project Selection
              projectsAsync.when(
                data:
                    (projects) => FormBuilderDropdown<String>(
                      name: 'projectId',
                      decoration: const InputDecoration(
                        labelText: 'Project *',
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                      items:
                          projects
                              .where((p) => p.isActive)
                              .map(
                                (project) => DropdownMenuItem(
                                  value: project.id,
                                  child: Text(project.title),
                                ),
                              )
                              .toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      },
                    ),
                loading: () => const LoadingWidget(),
                error: (_, _) => const Text('Failed to load projects'),
              ),
              const SizedBox(height: 16),

              // Contributor selection
              contributorsAsync.when(
                data:
                    (contributors) => FormBuilderDropdown<String>(
                      name: 'contributorId',
                      decoration: const InputDecoration(
                        labelText: 'Contributor *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items:
                          contributors
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                      validator: FormBuilderValidators.required(),
                    ),
                loading: () => const LoadingWidget(),
                error: (_, _) => const Text('Failed to load contributors'),
              ),
              const SizedBox(height: 16),

              // Contribution Type
              FormBuilderDropdown<String>(
                name: 'type',
                initialValue: 'volunteering',
                decoration: const InputDecoration(
                  labelText: 'Contribution Type *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'volunteering',
                    child: Text('Volunteering'),
                  ),
                  DropdownMenuItem(
                    value: 'fundraising',
                    child: Text('Fundraising'),
                  ),
                  DropdownMenuItem(value: 'donation', child: Text('Donation')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),

              // Description
              FormBuilderTextField(
                name: 'description',
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe what was contributed',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(5),
                ]),
              ),
              const SizedBox(height: 16),

              // Value and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FormBuilderTextField(
                      name: 'value',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Value',
                        hintText: 'e.g., 5',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: FormBuilderDropdown<String>(
                      name: 'unit',
                      initialValue: 'hours',
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'hours', child: Text('Hours')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'items', child: Text('Items')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Timestamp
              FormBuilderDateTimePicker(
                name: 'timestamp',
                inputType: InputType.both,
                initialValue: DateTime.now(),
                decoration: const InputDecoration(
                  labelText: 'Date & Time *',
                  prefixIcon: Icon(Icons.access_time),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),

              // Attachments
              FormBuilderTextField(
                name: 'attachments',
                decoration: const InputDecoration(
                  labelText: 'Attachments (Optional)',
                  hintText: 'Photo/receipt description',
                  prefixIcon: Icon(Icons.attach_file),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      contributionState.isLoading
                          ? null
                          : () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final values = _formKey.currentState!.value;
                              final projects = projectsAsync.value ?? [];
                              final contributors =
                                  contributorsAsync.value ?? [];

                              final project = projects.firstWhere(
                                (p) => p.id == values['projectId'] as String,
                              );
                              final contributor = contributors.firstWhere(
                                (c) =>
                                    c.id == values['contributorId'] as String,
                              );

                              final contribution = Contribution(
                                id:
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                contributorId:
                                    values['contributorId'] as String,
                                contributorName: contributor.name,
                                projectId: values['projectId'] as String,
                                projectName: project.title,
                                description: values['description'] as String,
                                type: values['type'] as String,
                                value:
                                    values['value'] != null
                                        ? double.tryParse(
                                          values['value'].toString(),
                                        )
                                        : null,
                                unit: values['unit'] as String?,
                                timestamp: values['timestamp'] as DateTime,
                                recordedBy: '1',
                                recordedByName: 'Jean Dupont',
                                createdAt: DateTime.now(),
                              );

                              ref
                                  .read(contributionNotifierProvider.notifier)
                                  .recordContribution(contribution);
                            }
                          },
                  child:
                      contributionState.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Record Contribution'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
