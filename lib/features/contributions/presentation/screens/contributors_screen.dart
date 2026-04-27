import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/core/widgets/common_widgets.dart';
import 'package:give_track/features/contributions/domain/entities/contributor.dart';
import 'package:give_track/features/contributions/presentation/providers/contribution_provider.dart';

class ContributorsScreen extends ConsumerStatefulWidget {
  const ContributorsScreen({super.key});

  @override
  ConsumerState<ContributorsScreen> createState() => _ContributorsScreenState();
}

class _ContributorsScreenState extends ConsumerState<ContributorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contributorsAsync = ref.watch(contributorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () {
              // TODO: Import from CSV/Excel
              _showImportDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contributors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: contributorsAsync.when(
              data: (contributors) {
                final filtered =
                    _searchQuery.isEmpty
                        ? contributors
                        : contributors
                            .where(
                              (c) =>
                                  c.name.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  (c.email?.toLowerCase().contains(
                                        _searchQuery.toLowerCase(),
                                      ) ??
                                      false),
                            )
                            .toList();
                return _ContributorsList(contributors: filtered);
              },
              loading: () => const LoadingWidget(),
              error:
                  (error, stack) => AppErrorWidget(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(contributorsProvider),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddContributorDialog(context);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add contributor'),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import contributors'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Import contributors from a file:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('Excel (.xlsx)'),
                  subtitle: const Text('Import from Excel spreadsheet'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement Excel import
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('CSV (.csv)'),
                  subtitle: const Text('Import from CSV file'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement CSV import
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showAddContributorDialog(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add new contributor',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormBuilder(
                key: formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'name',
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'age',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'email',
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: FormBuilderValidators.email(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'phone',
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      final values = formKey.currentState!.value;
                      final contributor = Contributor(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: values['name'] as String,
                        age:
                            values['age'] != null
                                ? int.tryParse(values['age'].toString())
                                : null,
                        email: values['email'] as String?,
                        phone: values['phone'] as String?,
                        createdAt: DateTime.now(),
                      );
                      ref
                          .read(contributorNotifierProvider.notifier)
                          .createContributor(contributor);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add contributor'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _ContributorsList extends StatelessWidget {
  final List<Contributor> contributors;

  const _ContributorsList({required this.contributors});

  @override
  Widget build(BuildContext context) {
    if (contributors.isEmpty) {
      return const EmptyStateWidget(
        message:
            'No contributors found. Add your first contributor to get started.',
        icon: Icons.people_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: contributors.length,
      itemBuilder: (context, index) {
        final contributor = contributors[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ContributorCard(contributor: contributor),
        );
      },
    );
  }
}

class _ContributorCard extends StatelessWidget {
  final Contributor contributor;

  const _ContributorCard({required this.contributor});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              // TODO: Edit
            },
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.onSecondary,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) {
              // TODO: Delete
            },
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.colors.primary.withValues(alpha: 0.1),
              child:
                  contributor.photoUrl != null
                      ? ClipOval(child: Image.network(contributor.photoUrl!))
                      : Text(
                        contributor.name.isNotEmpty
                            ? contributor.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contributor.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (contributor.age != null) ...[
                        Icon(
                          Icons.cake,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${contributor.age} years',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(
                        Icons.volunteer_activism,
                        size: 14,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${contributor.totalContributions} contributions',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (contributor.email != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          contributor.email!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: context.colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
