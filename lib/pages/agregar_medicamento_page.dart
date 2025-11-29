import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padam_app/blocs/medicamento_bloc/medicamento_bloc.dart';
import 'package:padam_app/models/medicamento.dart';
import 'package:image_picker/image_picker.dart';

// Pagina para agregar nuevos medicamentos al sistema
// 
// Caracteristicas principales:
// - Formulario completo para capturar datos del medicamento
// - Soporte para tomar fotos del medicamento
// - Selectores intuitivos para horarios y dias
// - Categorizacion visual con iconos
// - Validaciones adaptadas para adultos mayores
class AgregarMedicamentoPage extends StatefulWidget {
  final int idUsuario;

  const AgregarMedicamentoPage({super.key, required this.idUsuario});

  @override
  State<AgregarMedicamentoPage> createState() => _AgregarMedicamentoPageState();
}

class _AgregarMedicamentoPageState extends State<AgregarMedicamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  
  TimeOfDay _horarioSeleccionado = TimeOfDay.now();
  final List<String> _diasSeleccionados = [];
  final List<String> _categoriasSeleccionadas = [];
  final List<String> _diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  
  // Variable para almacenar la ruta de la foto tomada/seleccionada
  String? _rutaFoto;
  
  // Lista de categorias predefinidas con iconos y colores
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

  // Construye la seccion de foto del medicamento
  // Muestra preview si hay foto o boton para agregar si no hay
  Widget _buildSeccionFoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto del Medicamento (Opcional)',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Toma una foto si no puedes escribir el nombre',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        
        // Mostrar preview si ya se selecciono una foto
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
                // Imagen del medicamento
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_rutaFoto!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Boton para eliminar la foto
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _rutaFoto = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Foto seleccionada ✓',
              style: TextStyle(fontSize: 16, color: Colors.green[600], fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 15),
        ] else ...[
          // Boton para agregar foto si no hay una seleccionada
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
                    'Tocar para tomar foto',
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

  // Maneja la seleccion de foto desde camara o galeria
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
              'Agregar Foto',
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
                  print('Foto tomada: ${foto.path}');
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
                  print('Foto seleccionada: ${foto.path}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Valida y guarda el medicamento en el sistema
  // Incluye la ruta de la foto si fue proporcionada
  void _guardarMedicamento() {
    // Validacion: al menos un dia debe estar seleccionado
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

    // Validacion: debe haber nombre o foto
    if (_nombreController.text.trim().isEmpty && _rutaFoto == null) {
      _mostrarAdvertenciaNombreOpcional();
      return;
    }

    // Crear objeto Medicamento con los datos capturados
    final medicamento = Medicamento(
      idUsuario: widget.idUsuario,
      nombreMed: _nombreController.text.trim().isEmpty ? 'Medicamento con foto' : _nombreController.text.trim(),
      categoriaMed: _categoriasSeleccionadas.isNotEmpty 
          ? _categoriasSeleccionadas.join(', ') 
          : null,
      horarioMed: _horarioSeleccionado,
      diasSemana: _diasSeleccionados.join(','),
      imagenUrl: _rutaFoto, // Incluir ruta de la foto si existe
    );

    // Disparar evento para agregar el medicamento
    context.read<MedicamentoBloc>().add(AgregarMedicamento(medicamento));

    // Cerrar pantalla despues de un breve delay
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Medicamento',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<MedicamentoBloc, MedicamentoState>(
        listener: (context, state) {
          // Manejar respuesta del BLoC despues de agregar medicamento
          if (state is MedicamentoAgregado) {
            print('Medicamento agregado, cerrando pantalla...');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Medicamento agregado correctamente',
                  style: TextStyle(fontSize: 18),
                ),
                duration: const Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ),
            );
            
            // Cerrar pantalla despues de mostrar confirmacion
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
            
          } else if (state is MedicamentoError) {
            // Mostrar error si ocurre algun problema
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
                // Seccion de Foto (funcionalidad completa)
                _buildSeccionFoto(),
                const SizedBox(height: 30),

                // Campo Nombre (opcional si hay foto)
                _buildCampoNombre(),
                const SizedBox(height: 25),

                // Selector de Categorias con iconos
                _buildSelectorCategorias(),
                const SizedBox(height: 25),

                // Selector de Horario
                _buildSelectorHorario(),
                const SizedBox(height: 25),

                // Selector de Dias de la semana
                _buildSelectorDias(),
                const SizedBox(height: 40),

                // Boton Guardar
                _buildBotonGuardar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construye el campo de nombre del medicamento
  Widget _buildCampoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del Medicamento (Opcional)',
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
        ),
      ],
    );
  }

  // Construye el selector de categorias con chips visuales
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

  // Construye el selector de horario con boton para cambiar
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

  // Construye el boton de guardar con estado de carga
  Widget _buildBotonGuardar() {
    return BlocBuilder<MedicamentoBloc, MedicamentoState>(
      builder: (context, state) {
        if (state is MedicamentoLoading) {
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Guardando...',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Prevenir multiples clics durante el guardado
              if (state is! MedicamentoLoading) {
                _guardarMedicamento();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            child: const Text('Guardar Medicamento'),
          ),
        );
      },
    );
  }

  // Abre el selector de horario nativo
  Future<void> _seleccionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horarioSeleccionado,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _horarioSeleccionado = picked;
      });
    }
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

  // Muestra dialogo de advertencia cuando no hay nombre ni foto
  void _mostrarAdvertenciaNombreOpcional() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '¿Continuar sin nombre?',
          style: TextStyle(fontSize: 24),
        ),
        content: const Text(
          'No has escrito un nombre para el medicamento. ¿Estás seguro de que quieres continuar?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Guardar con nombre por defecto
              final medicamento = Medicamento(
                idUsuario: widget.idUsuario,
                nombreMed: 'Medicamento sin nombre',
                categoriaMed: _categoriasSeleccionadas.isNotEmpty 
                    ? _categoriasSeleccionadas.join(', ') 
                    : null,
                horarioMed: _horarioSeleccionado,
                diasSemana: _diasSeleccionados.join(','),
              );
              context.read<MedicamentoBloc>().add(AgregarMedicamento(medicamento));
            },
            child: const Text(
              'Continuar',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }
}