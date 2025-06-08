import 'package:flutter/material.dart';
import '../models/customer.dart';
import 'package:uuid/uuid.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({Key? key, this.customer}) : super(key: key);

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _phone;

  @override
  void initState() {
    super.initState();
    _name = widget.customer?.name ?? '';
    _email = widget.customer?.email ?? '';
    _phone = widget.customer?.phone ?? '';
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final id = widget.customer?.id ?? const Uuid().v4();
      final customer = Customer(id: id, name: _name, email: _email, phone: _phone);
      Navigator.pop(context, customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Agregar Cliente' : 'Editar Cliente'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese un email' : null,
                    onSaved: (value) => _email = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _phone,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese un teléfono' : null,
                    onSaved: (value) => _phone = value!,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    onPressed: _save,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
