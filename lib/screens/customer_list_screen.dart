import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/customer.dart';
import '../models/customer_log.dart';
import 'customer_form_screen.dart';
import 'customer_log_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Customer> customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('customers');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        customers = jsonList.map((e) => Customer.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(customers.map((c) => c.toJson()).toList());
    await prefs.setString('customers', data);
  }

  void _addCustomer(Customer customer) {
    setState(() {
      customers.add(customer);
    });
    _saveCustomers();
  }

  void _editCustomer(Customer customer) {
    setState(() {
      int index = customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        customers[index] = customer;
      }
    });
    _saveCustomers();
  }

  void _deleteCustomer(String id) {
    setState(() {
      customers.removeWhere((c) => c.id == id);
    });
    _saveCustomers();
  }

  // CSV Export/Import
  Future<String> _getDownloadPath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getDownloadsDirectory();
    }
    return directory!.path;
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ['ID', 'Nombre', 'Email', 'Teléfono', 'Logs'],
      ...customers.map((c) => [
        c.id, c.name, c.email, c.phone,
        jsonEncode(c.logs.map((l) => l.toJson()).toList()).replaceAll('"', "'"),
      ])
    ];
    String csv = const ListToCsvConverter().convert(rows);
    final path = await _getDownloadPath();
    final now = DateTime.now();
    final fileName = 'clientes_crm_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.csv';
    final file = File('$path/$fileName');
    await file.writeAsString(csv);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportado como $fileName en carpeta Downloads')));
    }
  }

  Future<void> _importCSV() async {
    final path = await _getDownloadPath();
    final dir = Directory(path);
    final files = await dir.list().where((f) => f.path.endsWith('.csv')).toList();
    if (files.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay archivos CSV para importar.')));
      }
      return;
    }
    String? selectedPath;
    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Selecciona archivo para importar'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView(
              children: files.map((f) {
                final name = f.path.split(Platform.pathSeparator).last;
                return ListTile(
                  title: Text(name),
                  onTap: () {
                    selectedPath = f.path;
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
    if (selectedPath == null) return;
    final file = File(selectedPath!);
    if (await file.exists()) {
      final csvStr = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvStr, eol: '\n');
      if (rows.length > 1) {
        // Buscar columnas por nombre para soportar cualquier CSV compatible
        final header = rows[0]
            .map((h) => h.toString().toLowerCase().replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'\n|\r'), ''))
            .toList();
        // Permitir importar CSVs con cualquier encabezado compatible
        int idIdx = header.indexWhere((h) => h.contains('id'));
        int nameIdx = header.indexWhere((h) => h.contains('nombre') || h.contains('name'));
        int emailIdx = header.indexWhere((h) => h.contains('email'));
        int phoneIdx = header.indexWhere((h) => h.contains('tel') || h.contains('phone'));
        int logsIdx = header.indexWhere((h) => h.contains('logs'));
        setState(() {
          customers = rows.skip(1).map((row) {
            if (row.length < header.length) {
              row = List.from(row)..addAll(List.filled(header.length - row.length, ''));
            }
            String id = idIdx >= 0 && row.length > idIdx ? row[idIdx].toString() : '';
            String name = nameIdx >= 0 && row.length > nameIdx ? row[nameIdx].toString() : '';
            String email = emailIdx >= 0 && row.length > emailIdx ? row[emailIdx].toString() : '';
            String phone = phoneIdx >= 0 && row.length > phoneIdx ? row[phoneIdx].toString() : '';
            List logsList = [];
            if (logsIdx >= 0 && row.length > logsIdx) {
              var logsRaw = row[logsIdx];
              if (logsRaw is String) {
                final trimmed = logsRaw.trim();
                if (trimmed == '[]' || trimmed == '"[]"' || trimmed == '' || trimmed == '""') {
                  logsList = [];
                } else {
                  String jsonStr = trimmed;
                  if (jsonStr.startsWith('"') && jsonStr.endsWith('"')) {
                    jsonStr = jsonStr.substring(1, jsonStr.length - 1);
                  }
                  jsonStr = jsonStr.replaceAll("'", '"');
                  if (!jsonStr.trim().startsWith('[')) {
                    jsonStr = '[$jsonStr]';
                  }
                  try {
                    final decoded = jsonDecode(jsonStr);
                    if (decoded is List) {
                      logsList = decoded.map((l) {
                        if (l is Map<String, dynamic>) {
                          return l;
                        } else if (l is Map) {
                          return Map<String, dynamic>.from(l);
                        }
                        return null;
                      }).whereType<Map<String, dynamic>>().toList();
                    } else if (decoded is Map) {
                      logsList = [Map<String, dynamic>.from(decoded)];
                    }
                  } catch (e) {
                    logsList = [];
                  }
                }
              } else if (logsRaw is List) {
                logsList = logsRaw;
              } else {
                logsList = [];
              }
            }
            List<CustomerLog> parsedLogs = [];
            try {
              parsedLogs = logsList
                .where((l) => l is Map || l is Map<String, dynamic>)
                .map((l) => CustomerLog.fromJson(Map<String, dynamic>.from(l)))
                .toList();
            } catch (e) {
              parsedLogs = [];
            }
            return Customer(
              id: id,
              name: name,
              email: email,
              phone: phone,
              logs: parsedLogs,
            );
          }).where((c) => c.id.isNotEmpty && c.name.isNotEmpty).toList();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Importado desde ${file.path.split(Platform.pathSeparator).last}')));
        }
        _saveCustomers();
      }
    }
  }

  void _openForm({Customer? customer}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(customer: customer),
      ),
    );
    if (result is Customer) {
      if (customer == null) {
        _addCustomer(result);
      } else {
        _editCustomer(result);
      }
    }
    // Guardar después de regresar de la pantalla de logs
    _saveCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple CRM'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Exportar CSV',
            onPressed: _exportCSV,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Importar CSV',
            onPressed: _importCSV,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Acerca de',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Simple CRM',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.business, color: Theme.of(context).colorScheme.primary),
                children: [
                  const SizedBox(height: 12),
                  const Text('Desarrollado por Javert Galicia (@javert-galicia)\n\nSimple CRM es una app de gestión de clientes e interacciones, multiplataforma, moderna y profesional.'),
                  const SizedBox(height: 8),
                  const Text('Repositorio: https://github.com/javert-galicia/simple_crm', style: TextStyle(fontSize: 13)),
                ],
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            child: ListTile(
              title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.email, style: const TextStyle(color: Color(0xFF778DA9))),
                  Text(customer.phone, style: const TextStyle(color: Color(0xFF415A77))),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF415A77),
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerLogScreen(customer: customer),
                  ),
                );
                _saveCustomers();
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF778DA9)),
                    onPressed: () => _openForm(customer: customer),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFF415A77)),
                    onPressed: () => _deleteCustomer(customer.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
