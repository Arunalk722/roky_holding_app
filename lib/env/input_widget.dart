import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roky_holding/env/text_input_object.dart';

Widget buildTextField(TextEditingController controller, String label,
    String hint, IconData icon, bool visible, int MaxLenth) {
  return SizedBox(
      child: Visibility(
          visible: visible,
          child: TextFormField(
            maxLength: MaxLenth,
            controller: controller,
            decoration: InputTextDecoration.inputDecoration(
              lable_Text: label,
              hint_Text: hint,
              icons: icon,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          )));
}

Widget buildNumberField(TextEditingController controller, String label,
    String hint, IconData icon, bool vis, int MaxLenth) {
  return SizedBox(
    child: Visibility(
      visible: vis,
      child: TextFormField(
        maxLength: MaxLenth,
        controller: controller,
        decoration: InputTextDecoration.inputDecoration(
          lable_Text: label,
          hint_Text: hint,
          icons: icon,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    ),
  );
}

Widget buildReadOnlyTotalCostField(TextEditingController controller,
    String label, String hint, IconData icon, int MaxLenth) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        maxLength: MaxLenth,
        decoration: InputTextDecoration.inputDecoration(
          lable_Text: label,
          hint_Text: hint,
          icons: icon,
        ),
        readOnly: true,
        controller: TextEditingController(text: controller.text),
      ),
    ),
  );
}

class AutoSuggestionField extends StatefulWidget {
  final List<String> suggestions;
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged; // Optional callback

  const AutoSuggestionField({
    super.key,
    required this.suggestions,
    required this.controller,
    required this.label,
    this.onChanged,
  });

  @override
  _AutoSuggestionFieldState createState() => _AutoSuggestionFieldState();
}

class _AutoSuggestionFieldState extends State<AutoSuggestionField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController(text: widget.controller.text);
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue val) {
            if (val.text.isEmpty) {
              return const Iterable<
                  String>.empty(); // Return an empty iterable when text is empty
            }
            return widget.suggestions.where((option) =>
                option.toLowerCase().contains(val.text.toLowerCase()));
          },
          onSelected: (String value) {
            setState(() {
              _internalController.text = value;
              widget.controller.text = value; // Sync with external controller
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value); // Notify parent widget if needed
            }
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: _internalController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.controller.text =
                    value; // Keep external controller updated
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select a value'
                  : null,
            );
          },
        ),
      ),
    );
  }
}

/*
AutoSuggestionField(
  label: 'Enter Location',
  suggestions: _locationSuggestions,
  controller: _locationController,
  onChanged: (value) {
    PD.pd(text: "Typed Location: $value"); // Debug log
  },
),

*/

class CustomDropdown extends StatefulWidget {
  final String label;
  final List<String> suggestions;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<String?>? onChanged; // Added callback for value change

  const CustomDropdown({
    super.key,
    required this.label,
    required this.suggestions,
    required this.icon,
    required this.controller,
    this.onChanged, // Allow an optional callback
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(widget.icon),
          ),
          value: selectedValue,
          items: widget.suggestions.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value;
              widget.controller.text =
                  value ?? ''; // Sync selection with controller
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value); // Call the callback when value changes
            }
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select a value' : null,
        ),
      ),
    );
  }
}

/*
 CustomDropdown(
 label: 'Select Cost Type',
  suggestions: _dropdownCostType,
   icon: Icons.category_sharp,
   controller: _dropdown1Controller,
   onChanged: (value) {
  _selectedValueCostType=value;
 },
),
*/
