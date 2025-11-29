import 'package:equatable/equatable.dart';

// Modelo que representa el registro de una toma de medicamento
// 
// Funcionalidad:
// - Registra cuando un usuario toma (o no) un medicamento
// - Permite seguimiento de adherencia terapeutica
// - Incluye timestamp de planificacion y registro real
// - Soporta observaciones adicionales
class RegistroToma extends Equatable {
  final int? idRegistro;                 // ID unico del registro
  final int idMedicamento;               // ID del medicamento relacionado
  final DateTime fechaHoraPlanificada;   // Cuando deberia haberse tomado
  final DateTime fechaHoraRegistro;      // Cuando se registro realmente
  final String estado;                   // 'tomado', 'omitido', 'pospuesto'
  final String? observaciones;           // Comentarios opcionales

  const RegistroToma({
    this.idRegistro,
    required this.idMedicamento,
    required this.fechaHoraPlanificada,
    required this.fechaHoraRegistro,
    required this.estado,
    this.observaciones,
  });

  // Convierte el objeto RegistroToma a Map para base de datos
  // Las fechas se convierten a formato ISO8601 para consistencia
  Map<String, dynamic> toMap() {
    return {
      'id_registro': idRegistro,
      'id_medicamento': idMedicamento,
      'fecha_hora_planificada': fechaHoraPlanificada.toIso8601String(),
      'fecha_hora_registro': fechaHoraRegistro.toIso8601String(),
      'estado': estado,
      'observaciones': observaciones,
    };
  }

  // Crea un objeto RegistroToma desde un Map de base de datos
  // Parsea las fechas desde strings ISO8601
  factory RegistroToma.fromMap(Map<String, dynamic> map) {
    return RegistroToma(
      idRegistro: map['id_registro'],
      idMedicamento: map['id_medicamento'],
      fechaHoraPlanificada: DateTime.parse(map['fecha_hora_planificada']),
      fechaHoraRegistro: DateTime.parse(map['fecha_hora_registro']),
      estado: map['estado'],
      observaciones: map['observaciones'],
    );
  }

  // Definicion de igualdad para Equatable
  @override
  List<Object?> get props => [
    idRegistro,
    idMedicamento,
    fechaHoraPlanificada,
    fechaHoraRegistro,
    estado,
    observaciones,
  ];
}