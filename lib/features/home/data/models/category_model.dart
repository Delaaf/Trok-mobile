class CategoryAttributeField {
  const CategoryAttributeField({required this.key, required this.label, required this.type, this.options, this.required = false});

  final String key;
  final String label;
  final String type; // text | number | select
  final List<String>? options;
  final bool required;

  factory CategoryAttributeField.fromJson(Map<String, dynamic> json) {
    return CategoryAttributeField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: json['type'] as String? ?? 'text',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
      required: json['required'] as bool? ?? false,
    );
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.attributesSchema = const [],
    this.children = const [],
  });

  final int id;
  final String name;
  final String slug;
  final String? icon;
  final List<CategoryAttributeField> attributesSchema;
  final List<CategoryModel> children;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      attributesSchema: (json['attributes_schema'] as List? ?? [])
          .map((e) => CategoryAttributeField.fromJson(e as Map<String, dynamic>))
          .toList(),
      children: (json['children'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
