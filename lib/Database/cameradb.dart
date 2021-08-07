class CameraModel {
  final int id;
  final int flash;
  final int camindex;
  final double brightness;
  final String colour;

  CameraModel(
      {required this.id,
      required this.flash,
      required this.camindex,
      required this.brightness,
      required this.colour});

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "id": id,
      "flash": flash,
      "camindex": camindex,
      "brightness": brightness,
      "colour": colour,
    };
  }
}
