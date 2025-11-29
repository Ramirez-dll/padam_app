import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Modelo que representa un medicamento en el sistema
// 
// Caracteristicas principales:
// - Gestiona la informacion completa de un medicamento
// - Incluye horarios, dias de toma y imagen asociada
// - Soporta serializacion para base de datos
// - Implementa Equatable para comparaciones eficientes
class Medicamento extends Equatable {
  final int? idMedicamento;        // ID unico (null para nuevos registros)
  final int idUsuario;             // ID del usuario dueño del medicamento
  final String nombreMed;          // Nombre del medicamento (requerido)
  final String? categoriaMed;      // Categoria opcional (ej: "analgesico")
  final TimeOfDay horarioMed;      // Hora programada para la toma
  final String diasSemana;         // Dias de toma en formato "1,3,5" (Lunes,Miercoles,Viernes)
  final String? imagenUrl;         // URL o path de la imagen del medicamento
  final bool activo;               // Estado activo/inactivo del medicamento

  const Medicamento({
    this.idMedicamento,
    required this.idUsuario,
    required this.nombreMed,
    this.categoriaMed,
    required this.horarioMed,
    required this.diasSemana,
    this.imagenUrl,
    this.activo = true,           // Por defecto los medicamentos estan activos
  });

  // Convierte el objeto Medicamento a un Map para guardar en base de datos
  // Formato de horario: "HH:MM" (ej: "08:30")
  // Activo se convierte a 1/0 para compatibilidad con SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_medicamento': idMedicamento,
      'id_usuario': idUsuario,
      'nombre_med': nombreMed,
      'categoria_med': categoriaMed,
      'horario_med': '${horarioMed.hour}:${horarioMed.minute.toString().padLeft(2, '0')}',
      'dias_semana': diasSemana,
      'imagen_url': imagenUrl,
      'activo': activo ? 1 : 0,
    };
  }

  // Crea un objeto Medicamento desde un Map de base de datos
  // Parsea el string de horario a TimeOfDay
  // Convierte el entero activo a booleano
  factory Medicamento.fromMap(Map<String, dynamic> map) {
    final timeParts = map['horario_med'].split(':');
    
    return Medicamento(
      idMedicamento: map['id_medicamento'],
      idUsuario: map['id_usuario'],
      nombreMed: map['nombre_med'],
      categoriaMed: map['categoria_med'],
      horarioMed: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      diasSemana: map['dias_semana'],
      imagenUrl: map['imagen_url'],
      activo: map['activo'] == 1,
    );
  }

  // Crea una copia del medicamento con algunos campos modificados
  // Util para actualizaciones parciales sin perder los datos existentes
  Medicamento copyWith({
    int? idMedicamento,
    int? idUsuario,
    String? nombreMed,
    String? categoriaMed,
    TimeOfDay? horarioMed,
    String? diasSemana,
    String? imagenUrl,
    bool? activo,
  }) {
    return Medicamento(
      idMedicamento: idMedicamento ?? this.idMedicamento,
      idUsuario: idUsuario ?? this.idUsuario,
      nombreMed: nombreMed ?? this.nombreMed,
      categoriaMed: categoriaMed ?? this.categoriaMed,
      horarioMed: horarioMed ?? this.horarioMed,
      diasSemana: diasSemana ?? this.diasSemana,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      activo: activo ?? this.activo,
    );
  }

  // Definicion de igualdad para Equatable
  // Dos medicamentos son iguales si todos estos campos coinciden
  @override
  List<Object?> get props => [
    idMedicamento,
    idUsuario,
    nombreMed,
    categoriaMed,
    horarioMed,
    diasSemana,
    imagenUrl,
    activo,
  ];
}