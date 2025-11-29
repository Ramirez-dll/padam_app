import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:padam_app/blocs/medicamento_bloc/medicamento_bloc.dart';
import 'package:padam_app/blocs/registro_toma_bloc/registro_toma_bloc.dart';
import 'package:padam_app/models/medicamento.dart';
import 'package:padam_app/pages/agregar_medicamento_page.dart';
import 'package:padam_app/pages/editar_medicamento_page.dart';

// Pagina principal para gestionar y visualizar los medicamentos del usuario
// 
// Funcionalidad:
// - Lista completa de medicamentos del usuario
// - Seguimiento de estado de toma (pendiente/completado)
// - Acciones rapidas para registrar tomas
// - Gestion completa (agregar, editar, eliminar)
// - Visualizacion de fotos de medicamentos
class ListaMedicamentosPage extends StatelessWidget {
  final int idUsuario;

  const ListaMedicamentosPage({super.key, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    // Cargar datos iniciales despues de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicamentoBloc>().add(CargarMedicamentos(idUsuario));
      context.read<RegistroTomaBloc>().add(CargarRegistrosHoy(idUsuario));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Medicamentos',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // Habilita el boton de retroceso
      ),
      body: MultiBlocListener(
        listeners: [
          // Listener para actualizar estados despues de registrar una toma
          BlocListener<RegistroTomaBloc, RegistroTomaState>(
            listener: (context, state) {
              if (state is TomaRegistrada) {
                // Recargar estados de toma despues de registrar
                context.read<RegistroTomaBloc>().add(CargarRegistrosHoy(idUsuario));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Toma registrada como ${state.registro.estado}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<MedicamentoBloc, MedicamentoState>(
          builder: (context, medicamentoState) {
            return BlocBuilder<RegistroTomaBloc, RegistroTomaState>(
              builder: (context, registroState) {
                // Combinar estados de ambos BLoCs para renderizar la interfaz
                if (medicamentoState is MedicamentoLoading) {
                  return _buildLoading();
                } else if (medicamentoState is MedicamentoCargado) {
                  final medicamentos = medicamentoState.medicamentos;
                  final estados = registroState is EstadosTomaCargados 
                      ? registroState.estados 
                      : <int, String>{};
                  
                  return _buildListaMedicamentos(medicamentos, estados, context);
                } else if (medicamentoState is MedicamentoError) {
                  return _buildError(medicamentoState.mensaje);
                }
                
                return _buildLoading();
              },
            );
          },
        ),
      ),
      // Boton flotante para agregar nuevos medicamentos
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarMedicamentoPage(idUsuario: idUsuario),
            ),
          ).then((_) {
            // Recargar lista despues de agregar
            context.read<MedicamentoBloc>().add(CargarMedicamentos(idUsuario));
          });
        },
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  // Construye la lista de medicamentos organizada por estado
  Widget _buildListaMedicamentos(
    List<Medicamento> medicamentos, 
    Map<int, String> estados, 
    BuildContext context
  ) {
    if (medicamentos.isEmpty) {
      return _buildEmptyState();
    }

    // Separar medicamentos por estado para organizar la vista
    final medicamentosPendientes = <Medicamento>[];
    final medicamentosCompletados = <Medicamento>[];

    for (final medicamento in medicamentos) {
      final estado = estados[medicamento.idMedicamento];
      if (estado == 'tomado') {
        medicamentosCompletados.add(medicamento);
      } else {
        medicamentosPendientes.add(medicamento);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Seccion de medicamentos pendientes
        if (medicamentosPendientes.isNotEmpty) ...[
          _buildSeccionTitulo('Pendientes para hoy', Colors.orange),
          ...medicamentosPendientes.map((med) => 
            _buildMedicamentoCard(med, estados[med.idMedicamento], context)
          ),
        ],
        
        // Seccion de medicamentos completados
        if (medicamentosCompletados.isNotEmpty) ...[
          _buildSeccionTitulo('Completados hoy', Colors.green),
          ...medicamentosCompletados.map((med) => 
            _buildMedicamentoCard(med, estados[med.idMedicamento], context)
          ),
        ],
      ],
    );
  }

  // Construye el titulo de una seccion de medicamentos
  Widget _buildSeccionTitulo(String titulo, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // Construye una tarjeta individual de medicamento
  Widget _buildMedicamentoCard(
    Medicamento medicamento, 
    String? estado, 
    BuildContext context
  ) {
    final tieneFoto = medicamento.imagenUrl != null && medicamento.imagenUrl!.isNotEmpty;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con informacion basica del medicamento
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Indicador visual del estado de toma
                  _buildEstadoIndicator(estado),
                  const SizedBox(width: 12),
                  
                  // Icono del medicamento
                  Icon(
                    Icons.medication_liquid,
                    size: 40,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  
                  // Informacion del medicamento (nombre y categoria)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicamento.nombreMed,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (medicamento.categoriaMed != null && medicamento.categoriaMed!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              medicamento.categoriaMed!,
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Menu de opciones (solo para medicamentos no tomados)
                  if (estado != 'tomado')
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 24),
                      onSelected: (value) {
                        if (value == 'eliminar') {
                          _confirmarEliminarMedicamento(context, medicamento);
                        } else if (value == 'editar') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarMedicamentoPage(medicamento: medicamento),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'editar',
                          child: Text('Editar', style: TextStyle(fontSize: 18)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'eliminar',
                          child: Text('Eliminar', style: TextStyle(fontSize: 18, color: Colors.red)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Informacion detallada de horario y dias
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horario de toma
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Horario: ${medicamento.horarioMed.format(context)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Dias de la semana
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Días: ${_formatearDias(medicamento.diasSemana)}',
                          style: const TextStyle(fontSize: 18),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botones de accion para registrar tomas (solo si no esta tomado)
            if (estado != 'tomado') ...[
              const SizedBox(height: 16),
              _buildBotonesAccion(medicamento.idMedicamento!, context),
            ],
            
            // Foto del medicamento (si existe)
            if (tieneFoto) ...[
              const SizedBox(height: 12),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: FileImage(File(medicamento.imagenUrl!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  // Construye el indicador visual del estado de toma
  Widget _buildEstadoIndicator(String? estado) {
    Color color;
    IconData icon;
    String tooltip;
    
    switch (estado) {
      case 'tomado':
        color = Colors.green;
        icon = Icons.check_circle;
        tooltip = 'Tomado';
        break;
      case 'omitido':
        color = Colors.red;
        icon = Icons.cancel;
        tooltip = 'Omitido';
        break;
      case 'pospuesto':
        color = Colors.orange;
        icon = Icons.schedule;
        tooltip = 'Pospuesto';
        break;
      default:
        color = Colors.grey;
        icon = Icons.pending;
        tooltip = 'Pendiente';
    }
    
    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 24, color: color),
    );
  }

  // Construye los botones de accion para registrar tomas
  Widget _buildBotonesAccion(int idMedicamento, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Boton para registrar como tomado
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<RegistroTomaBloc>().add(RegistrarToma(idMedicamento, 'tomado'));
              },
              icon: const Icon(Icons.check),
              label: const Text('Tomado', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Boton para posponer
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<RegistroTomaBloc>().add(RegistrarToma(idMedicamento, 'pospuesto'));
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Posponer', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Boton para omitir
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<RegistroTomaBloc>().add(RegistrarToma(idMedicamento, 'omitido'));
              },
              icon: const Icon(Icons.close),
              label: const Text('Omitir', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construye el estado de carga
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Cargando medicamentos...',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  // Construye el estado de error
  Widget _buildError(String mensaje) {
    return Center(
      child: Text(
        'Error: $mensaje',
        style: TextStyle(fontSize: 20, color: Colors.red),
      ),
    );
  }

  // Construye el estado vacio (sin medicamentos)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_liquid,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No tienes medicamentos registrados',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          SizedBox(height: 10),
          Text(
            'Presiona el botón + para agregar uno',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Muestra dialogo de confirmacion para eliminar medicamento
  void _confirmarEliminarMedicamento(BuildContext context, Medicamento medicamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Eliminar Medicamento',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${medicamento.nombreMed}"?',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MedicamentoBloc>().add(
                EliminarMedicamento(medicamento.idMedicamento!, idUsuario)
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Formatea los dias de la semana de formato abreviado a legible
  String _formatearDias(String diasSemana) {
    final diasMap = {
      'L': 'Lun',
      'M': 'Mar', 
      'X': 'Mié',
      'J': 'Jue',
      'V': 'Vie',
      'S': 'Sáb',
      'D': 'Dom'
    };
    
    final diasList = diasSemana.split(',');
    
    // Caso especial: todos los dias
    if (diasList.length == 7) {
      return 'Todos los días';
    }
    
    // Caso especial: dias de semana (Lunes a Viernes)
    if (diasList.length == 5 && 
        diasList.contains('L') && 
        diasList.contains('M') && 
        diasList.contains('X') && 
        diasList.contains('J') && 
        diasList.contains('V')) {
      return 'Lunes a Viernes';
    }
    
    // Formato normal: mostrar dias abreviados
    return diasList.map((dia) => diasMap[dia] ?? dia).join(', ');
  }
}