import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/customer_log.dart';
import 'package:uuid/uuid.dart';

class CustomerLogScreen extends StatefulWidget {
  final Customer customer;
  const CustomerLogScreen({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerLogScreen> createState() => _CustomerLogScreenState();
}

class _CustomerLogScreenState extends State<CustomerLogScreen> {
  final _formKey = GlobalKey<FormState>();
  LogType? _selectedType;
  LogRating? _selectedRating;
  String _message = '';

  void _addLog() {
    if (_formKey.currentState!.validate() && _selectedType != null && _selectedRating != null) {
      _formKey.currentState!.save();
      setState(() {
        widget.customer.logs.add(CustomerLog(
          id: const Uuid().v4(),
          type: _selectedType!,
          message: _message,
          date: DateTime.now(),
          rating: _selectedRating!,
        ));
      });
      _message = '';
      _selectedType = null;
      _selectedRating = null;
      _formKey.currentState!.reset();
    }
  }

  Color _typeColor(LogType type) {
    switch (type) {
      case LogType.telefono:
        return Colors.blue.shade100;
      case LogType.email:
        return Colors.green.shade100;
      case LogType.whatsapp:
        return Colors.teal.shade100;
      case LogType.redSocial:
        return Colors.purple.shade100;
    }
  }

  IconData _typeIcon(LogType type) {
    switch (type) {
      case LogType.telefono:
        return Icons.phone;
      case LogType.email:
        return Icons.email;
      case LogType.whatsapp:
        return Icons.message; // No hay icono whatsapp por defecto
      case LogType.redSocial:
        return Icons.public;
    }
  }

  String _ratingText(LogRating rating) {
    switch (rating) {
      case LogRating.bueno:
        return '[BUENO] ';
      case LogRating.regular:
        return '[REGULAR] ';
      case LogRating.malo:
        return '[MALO] ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = widget.customer.logs.where((log) => !log.isDone).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final historial = widget.customer.logs.where((log) => log.isDone).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de ${widget.customer.name}'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<LogType>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'Tipo de contacto'),
                        items: LogType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedType = value),
                        validator: (value) => value == null ? 'Seleccione un tipo' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<LogRating>(
                        value: _selectedRating,
                        decoration: const InputDecoration(labelText: 'Calificación'),
                        items: LogRating.values.map((rating) {
                          return DropdownMenuItem(
                            value: rating,
                            child: Text(rating.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedRating = value),
                        validator: (value) => value == null ? 'Seleccione una calificación' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Mensaje/Detalle'),
                        onSaved: (value) => _message = value ?? '',
                        validator: (value) => value == null || value.isEmpty ? 'Ingrese un mensaje' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        onPressed: () {
                          _addLog();
                          Navigator.pop(context);
                        },
                        child: const Text('Agregar registro'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (pendientes.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Pendientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF778DA9))),
                  ),
                  ...pendientes.map((log) => Card(
                        child: CheckboxListTile(
                          value: log.isDone,
                          onChanged: (val) {
                            setState(() {
                              log.isDone = val ?? false;
                            });
                          },
                          title: Row(
                            children: [
                              Text(_ratingText(log.rating), style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: log.rating == LogRating.bueno
                                    ? Colors.greenAccent
                                    : log.rating == LogRating.regular
                                        ? Colors.amberAccent
                                        : Colors.redAccent,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: Text(log.message, style: const TextStyle(color: Colors.white))),
                            ],
                          ),
                          subtitle: Text('${log.type.toString().split('.').last} - ${log.date.toLocal()}', style: const TextStyle(color: Color(0xFF415A77))),
                          secondary: Icon(_typeIcon(log.type), color: _typeColor(log.type)),
                          checkColor: Colors.white,
                          activeColor: Color(0xFF415A77),
                        ),
                      )),
                ],
                if (historial.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Historial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF778DA9))),
                  ),
                  ...historial.map((log) => Card(
                        child: ListTile(
                          leading: Icon(_typeIcon(log.type), color: _typeColor(log.type)),
                          title: Row(
                            children: [
                              Text(_ratingText(log.rating), style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: log.rating == LogRating.bueno
                                    ? Colors.greenAccent
                                    : log.rating == LogRating.regular
                                        ? Colors.amberAccent
                                        : Colors.redAccent,
                                decoration: TextDecoration.lineThrough,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: Text(log.message, style: const TextStyle(color: Colors.white, decoration: TextDecoration.lineThrough))),
                            ],
                          ),
                          subtitle: Text('${log.type.toString().split('.').last} - ${log.date.toLocal()}', style: const TextStyle(color: Color(0xFF415A77))),
                          trailing: IconButton(
                            icon: const Icon(Icons.undo, color: Colors.amber),
                            tooltip: 'Regresar a pendiente',
                            onPressed: () {
                              setState(() {
                                log.isDone = false;
                              });
                            },
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
