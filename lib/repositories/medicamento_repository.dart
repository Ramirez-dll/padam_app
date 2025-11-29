import 'package:flutter/material.dart';
import 'package:padam_app/models/medicamento.dart';
import 'package:padam_app/services/storage_service.dart';

// Repository para la gestion de datos de medicamentos
// 
// Responsabilidades:
// - Gestiona el ciclo de vida completo de los medicamentos
// - Sincroniza datos en memoria con almacenamiento persistente
// - Proporciona operaciones CRUD para medicamentos
// - Filtra medicamentos por usuario
class MedicamentoRepository {
  List<Medicamento> _medicamentos = [];

  MedicamentoRepository() {
    _cargarMedicamentos(); // Cargar datos al inicializar el repository
  }

  // Carga todos los medicamentos desde el almacenamiento persistente
  // Se ejecuta automaticamente al crear el repository
  Future<void> _cargarMedicamentos() async {
    try {
      final medicamentosData = await StorageService.cargarMedicamentos();
      _medicamentos = medicamentosData.map((data) => Medicamento.fromMap(data)).toList();
      print('Medicamentos cargados en memoria: ${_medicamentos.length}');
    } catch (e) {
      print('Error al cargar medicamentos: $e');
      _medicamentos = []; // Inicializar lista vacia en caso de error
    }
  }

  // Guarda todos los cambios en el almacenamiento persistente
  // Se llama despues de cada operacion que modifique los datos
  Future<void> _guardarCambios() async {
    try {
      final medicamentosData = _medicamentos.map((med) => med.toMap()).toList();
      await StorageService.guardarMedicamentos(medicamentosData);
    } catch (e) {
      print('Error al guardar cambios: $e');
    }
  }

  // Obtiene todos los medicamentos de un usuario especifico
  // Parametros:
  //   - idUsuario: ID del usuario cuyos medicamentos se buscan
  // Retorna: Lista de medicamentos filtrada por usuario
  Future<List<Medicamento>> obtenerMedicamentos(int idUsuario) async {
    // Filtrar medicamentos por ID de usuario
    final medicamentosUsuario = _medicamentos
        .where((med) => med.idUsuario == idUsuario)
        .toList();
    
    print('Medicamentos para usuario $idUsuario: ${medicamentosUsuario.length}');
    return medicamentosUsuario;
  }

  // Guarda un nuevo medicamento en el sistema
  // Parametros:
  //   - medicamento: Objeto Medicamento a guardar (sin ID)
  // Retorna: ID asignado al medicamento
  Future<int> guardarMedicamento(Medicamento medicamento) async {
    try {
      // Generar ID unico basado en timestamp
      final idMedicamento = DateTime.now().millisecondsSinceEpoch;
      final nuevoMedicamento = medicamento.copyWith(
        idMedicamento: idMedicamento,
      );
      
      // Agregar a la lista en memoria
      _medicamentos.add(nuevoMedicamento);
      print('Medicamento guardado: ${nuevoMedicamento.nombreMed} (ID: $idMedicamento)');
      print('Total medicamentos: ${_medicamentos.length}');
      
      // Persistir cambios en almacenamiento
      await _guardarCambios();
      
      return idMedicamento;
    } catch (e) {
      print('Error al guardar medicamento: $e');
      rethrow;
    }
  }

  // Actualiza un medicamento existente
  // Parametros:
  //   - medicamento: Objeto Medicamento con los datos actualizados
  // Lanza excepcion si el medicamento no existe
  Future<void> actualizarMedicamento(Medicamento medicamento) async {
    try {
      // Buscar el medicamento por ID
      final index = _medicamentos.indexWhere((m) => m.idMedicamento == medicamento.idMedicamento);
      if (index != -1) {
        // Logs detallados para debugging de actualizacion de fotos
        print('ANTES de actualizar:');
        print('   - Foto anterior: ${_medicamentos[index].imagenUrl}');
        print('   - Foto nueva: ${medicamento.imagenUrl}');
        print('   - Es null la nueva?: ${medicamento.imagenUrl == null}');
        
        // Reemplazar el medicamento en la lista
        _medicamentos[index] = medicamento;
        
        print('DESPUÉS de actualizar:');
        print('   - Foto guardada: ${_medicamentos[index].imagenUrl}');
        print('   - Es null?: ${_medicamentos[index].imagenUrl == null}');
        
        // Persistir cambios
        await _guardarCambios();
      } else {
        throw Exception('Medicamento no encontrado');
      }
    } catch (e) {
      print('Error al actualizar medicamento: $e');
      rethrow;
    }
  }

  // Elimina un medicamento del sistema
  // Parametros:
  //   - idMedicamento: ID del medicamento a eliminar
  Future<void> eliminarMedicamento(int idMedicamento) async {
    try {
      // Remover de la lista en memoria
      _medicamentos.removeWhere((m) => m.idMedicamento == idMedicamento);
      print('Medicamento eliminado: $idMedicamento');
      print('Total medicamentos restantes: ${_medicamentos.length}');
      
      // Persistir cambios
      await _guardarCambios();
    } catch (e) {
      print('Error al eliminar medicamento: $e');
      rethrow;
    }
  }

  // Busca un medicamento especifico por su ID
  // Parametros:
  //   - idMedicamento: ID del medicamento a buscar
  // Retorna: Medicamento encontrado o null si no existe
  Future<Medicamento?> obtenerMedicamentoPorId(int idMedicamento) async {
    try {
      print('Buscando medicamento ID: $idMedicamento');
      print('Medicamentos en memoria: ${_medicamentos.length}');
      
      // Log de todos los medicamentos para debugging
      for (var med in _medicamentos) {
        print('   - ${med.idMedicamento}: ${med.nombreMed}');
      }
      
      // Buscar medicamento con manejo de caso no encontrado
      final medicamento = _medicamentos.firstWhere(
        (med) => med.idMedicamento == idMedicamento,
        orElse: () => Medicamento( // Valor por defecto para caso no encontrado
          idMedicamento: 0, // ID 0 indica no encontrado
          idUsuario: 0,
          nombreMed: 'Medicamento no encontrado',
          horarioMed: TimeOfDay.now(),
          diasSemana: '',
        ),
      );
      
      // Verificar si se encontro realmente el medicamento
      if (medicamento.idMedicamento == 0) {
        print('Medicamento no encontrado: $idMedicamento');
        return null;
      }
      
      print('Medicamento encontrado: ${medicamento.nombreMed}');
      return medicamento;
      
    } catch (e) {
      print('Error obteniendo medicamento por ID $idMedicamento: $e');
      return null;
    }
  }
}