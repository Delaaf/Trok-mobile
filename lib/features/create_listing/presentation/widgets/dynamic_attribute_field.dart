import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/category_model.dart';

class DynamicAttributeField extends StatelessWidget {
  const DynamicAttributeField({super.key, required this.field, required this.value, required this.onChanged});

  final CategoryAttributeField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = field.required ? '${field.label} *' : field.label;

    if (field.type == 'select' && field.options != null) {
      return DropdownButtonFormField<String>(
        initialValue: value as String?,
        decoration: InputDecoration(labelText: label),
        items: field.options!.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: onChanged,
      );
    }

    return TextFormField(
      initialValue: value?.toString(),
      keyboardType: field.type == 'number' ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      onChanged: (text) => onChanged(field.type == 'number' ? num.tryParse(text) : text),
    );
  }
}
