import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/address.dart';
import '../../domain/models/user_profile.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) => _ProfileContent(profile: profile),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text('Ошибка загрузки профиля: $error'),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileContent({
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(profileControllerProvider);
    final isLoading = actionState.isLoading;

    return ListView(
      children: [
        Text(
          'Профиль',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Личные данные',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _ProfileField(label: 'ФИО', value: profile.fullName),
                _ProfileField(label: 'Email', value: profile.email),
                _ProfileField(label: 'Телефон', value: profile.phoneNumber),
                _ProfileField(label: 'Роль', value: profile.role),
                _ProfileField(
                  label: 'Дата регистрации',
                  value: profile.registrationDate ?? '—',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _showEditProfileDialog(context, ref, profile),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать профиль'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Адреса',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () => _showAddressDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Добавить адрес'),
          ),
        ),
        const SizedBox(height: 16),
        if (profile.addresses.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('У вас пока нет сохранённых адресов'),
            ),
          )
        else
          ...profile.addresses.map(
            (address) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${address.country}, ${address.city}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Улица: ${address.street}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Дом: ${address.house}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Квартира: ${address.apartment?.isNotEmpty == true ? address.apartment : '—'}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Индекс: ${address.postalCode}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => _showAddressDialog(
                                      context,
                                      ref,
                                      address: address,
                                    ),
                            child: const Text('Изменить'),
                          ),
                          OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    try {
                                      await ref
                                          .read(profileControllerProvider.notifier)
                                          .deleteAddress(address.id!);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Адрес удалён'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    }
                                  },
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final emailController = TextEditingController(text: profile.email);
    final lastNameController = TextEditingController(text: profile.lastName);
    final firstNameController = TextEditingController(text: profile.firstName);
    final patronymicController = TextEditingController(text: profile.patronymic);
    final phoneController = TextEditingController(text: profile.phoneNumber);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Редактирование профиля'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Фамилия'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'Имя'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: patronymicController,
                    decoration: const InputDecoration(labelText: 'Отчество'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Телефон'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updated = profile.copyWith(
                    email: emailController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    firstName: firstNameController.text.trim(),
                    patronymic: patronymicController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                  );

                  await ref
                      .read(profileControllerProvider.notifier)
                      .updateProfile(updated);

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Профиль обновлён')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddressDialog(
    BuildContext context,
    WidgetRef ref, {
    Address? address,
  }) async {
    final countryController = TextEditingController(text: address?.country ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final streetController = TextEditingController(text: address?.street ?? '');
    final houseController = TextEditingController(text: address?.house ?? '');
    final apartmentController =
        TextEditingController(text: address?.apartment ?? '');
    final postalCodeController =
        TextEditingController(text: address?.postalCode ?? '');

    final isEdit = address != null;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Изменить адрес' : 'Добавить адрес'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: countryController,
                    decoration: const InputDecoration(labelText: 'Страна'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Город'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: streetController,
                    decoration: const InputDecoration(labelText: 'Улица'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: houseController,
                    decoration: const InputDecoration(labelText: 'Дом'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: apartmentController,
                    decoration: const InputDecoration(labelText: 'Квартира'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: postalCodeController,
                    decoration: const InputDecoration(labelText: 'Индекс'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final model = Address(
                    id: address?.id,
                    country: countryController.text.trim(),
                    city: cityController.text.trim(),
                    street: streetController.text.trim(),
                    house: houseController.text.trim(),
                    apartment: apartmentController.text.trim(),
                    postalCode: postalCodeController.text.trim(),
                  );

                  if (isEdit) {
                    await ref
                        .read(profileControllerProvider.notifier)
                        .updateAddress(model);
                  } else {
                    await ref
                        .read(profileControllerProvider.notifier)
                        .createAddress(model);
                  }

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Адрес обновлён' : 'Адрес добавлен',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}