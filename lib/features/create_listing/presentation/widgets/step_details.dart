import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/category_model.dart';
import 'dynamic_attribute_field.dart';

class StepDetails extends StatelessWidget {
  const StepDetails({
    super.key,
    required this.category,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.condition,
    required this.isFree,
    required this.isNegotiable,
    required this.acceptsExchange,
    required this.attributeValues,
    required this.onConditionChanged,
    required this.onIsFreeChanged,
    required this.onIsNegotiableChanged,
    required this.onAcceptsExchangeChanged,
    required this.onAttributeChanged,
  });

  final CategoryModel? category;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String condition;
  final bool isFree;
  final bool isNegotiable;
  final bool acceptsExchange;
  final Map<String, dynamic> attributeValues;
  final ValueChanged<String> onConditionChanged;
  final ValueChanged<bool> onIsFreeChanged;
  final ValueChanged<bool> onIsNegotiableChanged;
  final ValueChanged<bool> onAcceptsExchangeChanged;
  final void Function(String key, dynamic value) onAttributeChanged;

  static const _conditions = [
    ('new', 'Neuf'),
    ('like_new', 'Comme neuf'),
    ('good', 'Bon état'),
    ('fair', 'État correct'),
    ('for_parts', 'Pour pièces'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Décrivez votre article', style: textTheme.headlineLarge),
          const SizedBox(height: 20),

          TextField(
            controller: titleController,
            maxLength: 120,
            decoration: const InputDecoration(labelText: 'Titre de l\'annonce', hintText: 'Ex: iPhone 13 Pro en excellent état'),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: descriptionController,
            maxLines: 5,
            maxLength: 5000,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Détaillez l\'état, les caractéristiques, la raison de la vente...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          Text('État de l\'article', style: textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _conditions.map((c) {
              final isSelected = condition == c.$1;
              return ChoiceChip(
                label: Text(c.$2),
                selected: isSelected,
                onSelected: (_) => onConditionChanged(c.$1),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceMuted,
                labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: isFree,
            onChanged: onIsFreeChanged,
            activeThumbColor: AppColors.primary,
            title: const Text('Je donne cet article gratuitement'),
          ),

          if (!isFree) ...[
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix (FCFA)', hintText: 'Ex: 250000'),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: isNegotiable,
              onChanged: onIsNegotiableChanged,
              activeThumbColor: AppColors.primary,
              title: const Text('Prix négociable'),
            ),
          ],

          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: acceptsExchange,
            onChanged: onAcceptsExchangeChanged,
            activeThumbColor: AppColors.primary,
            title: const Text('Ouvert au troc/échange'),
          ),

          if (category != null && category!.attributesSchema.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Caractéristiques de "${category!.name}"', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            ...category!.attributesSchema.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DynamicAttributeField(
                    field: field,
                    value: attributeValues[field.key],
                    onChanged: (value) => onAttributeChanged(field.key, value),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
