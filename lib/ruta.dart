class Ruta {
  final String id;
  final String nombre;

  Ruta({required this.id, required this.nombre});

  // Método para convertir de un JSON a un objeto Ruta
  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'],
      nombre: json['nombre'].toString(), // Convierte a String si es necesario
    );
  }

  // Método para convertir de un objeto Ruta a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  // Método para convertir una lista de JSON a una lista de objetos Ruta
  static List<Ruta> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Ruta.fromJson(json)).toList();
  }
}