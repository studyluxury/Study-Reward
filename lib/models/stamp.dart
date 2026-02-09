class Stamp {
  String shape; // round / squircle / diamond / star
  String color; // p1..p5

  Stamp({required this.shape, required this.color});

  Map<String, dynamic> toJson() => {"shape": shape, "color": color};

  factory Stamp.fromJson(Map<String, dynamic> json) => Stamp(
        shape: (json["shape"] ?? "round") as String,
        color: (json["color"] ?? "p1") as String,
      );
}
