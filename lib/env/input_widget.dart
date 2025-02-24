import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roky_holding/env/text_input_object.dart';


Widget BuildPwdTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    bool visible,
    int maxLength,
    ) {
  return _BuildPwdTextField(
    controller: controller,
    label: label,
    hint: hint,
    icon: icon,
    visible: visible,
    maxLength: maxLength,
  );
}

class _BuildPwdTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool visible;
  final int maxLength;

  const _BuildPwdTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.visible,
    required this.maxLength,
  }) : super(key: key);

  @override
  _BuildPwdTextFieldState createState() => _BuildPwdTextFieldState();
}

class _BuildPwdTextFieldState extends State<_BuildPwdTextField> {
  bool _obscureText = true; // Password visibility toggle

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Visibility(
        visible: widget.visible,
        child: TextFormField(
          maxLength: widget.maxLength,
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${widget.label}';
            }
            return null;
          },
        ),
      ),
    );
  }
}



Widget BuildTextField(TextEditingController controller, String label,String hint, IconData icon, bool visible, int MaxLenth) {
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

Widget BuildTextFieldReadOnly(TextEditingController controller, String label, String hint, IconData icon, bool visible, int MaxLenth) {
  return SizedBox(
      child: Visibility(
          visible: visible,
          child: TextFormField(
            readOnly: true,
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






Widget BuildNumberField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    bool vis,
    int maxLength,
    Function(String)? onChanged, // Add callback function
    ) {
  return SizedBox(
    child: Visibility(
      visible: vis,
      child: TextFormField(
        maxLength: maxLength,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allow decimals
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        onChanged: onChanged, // Trigger callback when value changes
      ),
    ),
  );
}

Widget BuildReadOnlyTotalCostField(TextEditingController controller,
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
    return SizedBox(
        child:
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(widget.icon),
          ),
          value: widget.suggestions.contains(selectedValue) ? selectedValue : null, // Ensure value exists
          items: widget.suggestions.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value;
              widget.controller.text = value ?? '';
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          validator: (value) =>
          value == null || value.isEmpty ? 'Please select a value' : null,
        )
      ,

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

Widget BuildDetailRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top
      children: [
        SizedBox(
          width: 120, // Fixed width for labels for better alignment
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded( // Use Expanded to take up remaining space
          child: Text(
            value != null ? value.toString() : 'Not available',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}