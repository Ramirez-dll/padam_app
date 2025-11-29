import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padam_app/blocs/medicamento_bloc/medicamento_bloc.dart';
import 'package:padam_app/models/medicamento.dart';

// Pagina para editar medicamentos existentes en el sistema
// 
// Funcionalidad:
// - Permite modificar todos los campos de un medicamento existente
// - Mantiene la estructura similar a AgregarMedicamentoPage
// - Maneja correctamente la actualizacion de fotos
// - Proporciona validaciones consistentes
class EditarMedicamentoPage extends StatefulWidget {
  final Medicamento medicamento;

  const EditarMedicamentoPage({super.key, required this.medicamento});

  @override
  State<EditarMedicamentoPage> createState() => _EditarMedicamentoPageState();
}

class _EditarMedicamentoPageState extends State<EditarMedicamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  
  late TimeOfDay _horarioSeleccionado;
  late List<String> _diasSeleccionados;
  late List<String> _categoriasSeleccionadas;
  final List<String> _diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  
  String? _rutaFoto;
  
  // Lista de categorias predefinidas (misma que en AgregarMedicamentoPage)
  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Presión', 'icono': Icons.monitor_heart, 'color': Colors.red},
    {'nombre': 'Estómago', 'icono': Icons.sick, 'color': Colors.green},
    {'nombre': 'Renal', 'icono': Icons.water_drop, 'color': Colors.blue},
    {'nombre': 'Huesos', 'icono': Icons.accessible, 'color': Colors.orange},
    {'nombre': 'Músculos', 'icono': Icons.fitness_center, 'color': Colors.purple},
    {'nombre': 'Cerebro', 'icono': Icons.psychology, 'color': Colors.indigo},
    {'nombre': 'Suplementos', 'icono': Icons.flatware, 'color': Colors.teal},
    {'nombre': 'Otros', 'icono': Icons.medical_services, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar todos los campos con los valores actuales del medicamento
    _nombreController.text = widget.medicamento.nombreMed;
    _horarioSeleccionado = widget.medicamento.horarioMed;
    _diasSeleccionados = widget.medicamento.diasSemana.split(',');
    _categoriasSeleccionadas = widget.medicamento.categoriaMed?.split(', ') ?? [];
    _rutaFoto = widget.medicamento.imagenUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Medicamento',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Boton de guardar en la app bar para acceso rapido
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCambios,
          ),
        ],
      ),
      body: BlocListener<MedicamentoBloc, MedicamentoState>(
        listener: (context, state) {
          // Manejar respuesta del BLoC despues de actualizar
          if (state is MedicamentoCargado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Medicamento actualizado correctamente',
                  style: TextStyle(fontSize: 18),
                ),
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is MedicamentoError) {
            // Mostrar error si la actualizacion falla
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.mensaje,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seccion de Foto con opcion de cambiar
                _buildSeccionFoto(),
                const SizedBox(height: 30),

                // Campo Nombre con validacion
                _buildCampoNombre(),
                const SizedBox(height: 25),

                // Selector de Categorias
                _buildSelectorCategorias(),
                const SizedBox(height: 25),

                // Selector de Horario
                _buildSelectorHorario(),
                const SizedBox(height: 25),

                // Selector de Dias
                _buildSelectorDias(),
                const SizedBox(height: 40),

                // Boton Guardar Cambios
                _buildBotonGuardarCambios(),
                
                // Boton Cancelar
                _buildBotonCancelar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construye la seccion de foto con opciones para cambiar o eliminar
  Widget _buildSeccionFoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto del Medicamento',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Puedes cambiar la foto actual',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        
        // Mostrar foto actual si existe
        if (_rutaFoto != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                // Mostrar imagen actual
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_rutaFoto!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Boton para eliminar foto
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            print('Eliminando foto - Valor actual de _rutaFoto: $_rutaFoto');
                            _rutaFoto = null;
                            print('Foto eliminada - Nuevo valor de _rutaFoto: $_rutaFoto');
                          });
                        },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Boton para cambiar foto
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cambiar Foto', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ] else ...[
          // Mostrar opcion para agregar foto si no hay
          GestureDetector(
            onTap: _tomarFoto,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tocar para agregar foto',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Construye el campo de nombre con validacion
  Widget _buildCampoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del Medicamento',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Ej: Paracetamol, Metformina...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medication, size: 30),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          ),
          style: const TextStyle(fontSize: 20),
          // Validacion: requiere nombre o foto
          validator: (value) {
            if (value == null || value.isEmpty) {
              if (_rutaFoto == null) {
                return 'Ingresa un nombre o agrega una foto';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  // Construye el selector de categorias (igual que en agregar)
  Widget _buildSelectorCategorias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Para qué es este medicamento?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Puedes elegir varias opciones',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categorias.map((categoria) {
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    categoria['icono'],
                    size: 20,
                    color: _categoriasSeleccionadas.contains(categoria['nombre']) 
                        ? Colors.white 
                        : categoria['color'],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    categoria['nombre'],
                    style: TextStyle(
                      fontSize: 18,
                      color: _categoriasSeleccionadas.contains(categoria['nombre']) 
                          ? Colors.white 
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
              selected: _categoriasSeleccionadas.contains(categoria['nombre']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _categoriasSeleccionadas.add(categoria['nombre']);
                  } else {
                    _categoriasSeleccionadas.remove(categoria['nombre']);
                  }
                });
              },
              selectedColor: categoria['color'],
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Construye el selector de horario
  Widget _buildSelectorHorario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horario de Toma',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 30, color: Colors.blue),
              const SizedBox(width: 15),
              Text(
                '${_horarioSeleccionado.hour}:${_horarioSeleccionado.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _seleccionarHorario(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Cambiar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Construye el selector de dias de la semana
  Widget _buildSelectorDias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Días de la semana',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Selecciona los días que debes tomar este medicamento',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _diasSemana.map((dia) {
            return FilterChip(
              label: Text(
                _obtenerNombreDia(dia),
                style: const TextStyle(fontSize: 18),
              ),
              selected: _diasSeleccionados.contains(dia),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _diasSeleccionados.add(dia);
                  } else {
                    _diasSeleccionados.remove(dia);
                  }
                });
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Construye el boton principal de guardar cambios
  Widget _buildBotonGuardarCambios() {
    return BlocBuilder<MedicamentoBloc, MedicamentoState>(
      builder: (context, state) {
        if (state is MedicamentoLoading) {
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Guardando cambios...',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _guardarCambios,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            child: const Text('Guardar Cambios'),
          ),
        );
      },
    );
  }

  // Construye el boton de cancelar
  Widget _buildBotonCancelar() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: const Text('Cancelar'),
      ),
    );
  }

  // Abre el selector de horario nativo
  Future<void> _seleccionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horarioSeleccionado,
    );
    
    if (picked != null) {
      setState(() {
        _horarioSeleccionado = picked;
      });
    }
  }

  // Maneja la seleccion de nueva foto
  void _tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cambiar Foto',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 30),
              title: const Text('Tomar Foto', style: TextStyle(fontSize: 20)),
              onTap: () async {
                Navigator.pop(context);
                final XFile? foto = await picker.pickImage(source: ImageSource.camera);
                if (foto != null) {
                  setState(() {
                    _rutaFoto = foto.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 30),
              title: const Text('Elegir de Galería', style: TextStyle(fontSize: 20)),
              onTap: () async {
                Navigator.pop(context);
                final XFile? foto = await picker.pickImage(source: ImageSource.gallery);
                if (foto != null) {
                  setState(() {
                    _rutaFoto = foto.path;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Convierte abreviaturas de dias a nombres completos
  String _obtenerNombreDia(String abreviatura) {
    switch (abreviatura) {
      case 'L': return 'Lunes';
      case 'M': return 'Martes';
      case 'X': return 'Miércoles';
      case 'J': return 'Jueves';
      case 'V': return 'Viernes';
      case 'S': return 'Sábado';
      case 'D': return 'Domingo';
      default: return abreviatura;
    }
  }

  // Valida y guarda los cambios del medicamento
  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      // Validacion: al menos un dia seleccionado
      if (_diasSeleccionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selecciona al menos un día',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
        return;
      }

      // Validacion: nombre o foto requeridos
      if (_nombreController.text.trim().isEmpty && _rutaFoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ingresa un nombre o agrega una foto',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
        return;
      }

      // Determinar nombre final (usar existente si no hay cambios)
      final nombreFinal = _nombreController.text.trim().isEmpty 
          ? (_rutaFoto != null ? 'Medicamento con foto' : widget.medicamento.nombreMed)
          : _nombreController.text.trim();

      // SOLUCION CLAVE: Crear nuevo objeto Medicamento para forzar la actualizacion de imagenUrl
      // No usar copyWith porque podria no actualizar correctamente el campo imagenUrl a null
      final medicamentoActualizado = Medicamento(
        idMedicamento: widget.medicamento.idMedicamento,
        idUsuario: widget.medicamento.idUsuario,
        nombreMed: nombreFinal,
        categoriaMed: _categoriasSeleccionadas.isNotEmpty 
            ? _categoriasSeleccionadas.join(', ') 
            : null,
        horarioMed: _horarioSeleccionado,
        diasSemana: _diasSeleccionados.join(','),
        imagenUrl: _rutaFoto, // Este valor sera null si se elimino la foto
        activo: widget.medicamento.activo,
      );

      print('Guardando medicamento con foto: ${medicamentoActualizado.imagenUrl}');
      print('Es null?: ${medicamentoActualizado.imagenUrl == null}');

      // Disparar evento de actualizacion
      context.read<MedicamentoBloc>().add(ActualizarMedicamento(medicamentoActualizado));
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }
}