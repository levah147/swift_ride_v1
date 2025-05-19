import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onCountryCodeChanged;
  
  const PhoneInputField({
    super.key,
    required this.controller,
    this.onCountryCodeChanged,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final List<Map<String, dynamic>> _countryCodes = [
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
    {'name': 'Ghana', 'code': '+233', 'flag': '🇬🇭'},
    {'name': 'Kenya', 'code': '+254', 'flag': '🇰🇪'},
    {'name': 'South Africa', 'code': '+27', 'flag': '🇿🇦'},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
  ];
  
  String _selectedCountryCode = '+234'; // Default to Nigeria
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '8012345678',
        prefixIcon: _buildCountryCodeDropdown(),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (value.length < 9) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }
  
  Widget _buildCountryCodeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCountryCode = newValue;
              });
              if (widget.onCountryCodeChanged != null) {
                widget.onCountryCodeChanged!(newValue);
              }
            }
          },
          items: _countryCodes.map<DropdownMenuItem<String>>((Map<String, dynamic> country) {
            return DropdownMenuItem<String>(
              value: country['code'],
              child: Text('${country['flag']} ${country['code']}'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
