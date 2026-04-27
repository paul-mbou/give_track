import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';
import 'package:give_track/features/projects/presentation/providers/project_provider.dart';
import 'package:go_router/go_router.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectNotifierProvider);

    ref.listen(projectNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Project created successfully!',
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
        title: const Text('Create Project'),
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
                'Project Information',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in the details to create a new project',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              FormBuilderTextField(
                name: 'title',
                decoration: const InputDecoration(
                  labelText: 'Project Title *',
                  hintText: 'e.g., Community Garden Initiative',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(3),
                  FormBuilderValidators.maxLength(100),
                ]),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'description',
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the project purpose and goals',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(10),
                ]),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'motif',
                decoration: const InputDecoration(
                  labelText: 'Motif / Purpose *',
                  hintText: 'e.g., Environmental sustainability',
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(3),
                ]),
              ),
              const SizedBox(height: 16),

              FormBuilderDateTimePicker(
                name: 'startDate',
                inputType: InputType.date,
                initialValue: DateTime.now(),
                decoration: const InputDecoration(
                  labelText: 'Start Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),

              FormBuilderDateTimePicker(
                name: 'deadline',
                inputType: InputType.date,
                decoration: const InputDecoration(
                  labelText: 'Deadline (Optional)',
                  prefixIcon: Icon(Icons.event),
                ),
              ),
              const SizedBox(height: 16),

              FormBuilderDropdown<String>(
                name: 'status',
                initialValue: 'active',
                decoration: const InputDecoration(
                  labelText: 'Initial Status',
                  prefixIcon: Icon(Icons.toggle_on_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'paused', child: Text('Paused')),
                ],
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'customFields',
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Custom Fields (Optional)',
                  hintText: 'e.g., Target hours: 100, Location: Downtown',
                  prefixIcon: Icon(Icons.extension_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      projectState.isLoading
                          ? null
                          : () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final values = _formKey.currentState!.value;
                              final project = Project(
                                id:
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                title: values['title'] as String,
                                description: values['description'] as String,
                                motif: values['motif'] as String,
                                startDate: values['startDate'] as DateTime,
                                deadline: values['deadline'] as DateTime?,
                                status:
                                    (values['status'] as String?) ?? 'active',
                                createdBy: '1',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              ref
                                  .read(projectNotifierProvider.notifier)
                                  .createProject(project);
                            }
                          },
                  child:
                      projectState.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Create Project'),
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
