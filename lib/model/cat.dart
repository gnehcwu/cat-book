class Cat {
  final String image;
  final String name;
  final int energyLevel;
  final String lifeSpan;
  final int strangerFriendly;
  final String description;
  final String wiki;
  final String tag;
  final int dogFriendly;
  final int healthIssue;
  final int social;
  final int childFriendly;
  final int affectionLevel;
  final int intelligence;
  final String temperament;
  final String origin;

  const Cat({
    this.name,
    this.wiki,
    this.energyLevel,
    this.lifeSpan,
    this.description,
    this.strangerFriendly,
    this.tag,
    this.image,
    this.dogFriendly,
    this.healthIssue,
    this.social,
    this.childFriendly,
    this.affectionLevel,
    this.intelligence,
    this.temperament,
    this.origin
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    var tags = List<String>();
    if (json['hairless'] == 1) tags.add('hairless');
    if (json['suppressed_tail'] == 1) tags.add('short tail');
    if (json['short_legs'] == 1) tags.add('short leg');
    if (json['dog_friendly'] >= 3) tags.add('dog friendly');
    if (json['vocalisation'] < 3) tags.add('quiet');
    if (json['health_issues'] <=3) tags.add('healthy');

    var sheddingLevel = json['shedding_level'];
    if (sheddingLevel <= 1) {
      tags.add('low shedding');
    } else if (sheddingLevel >= 2 && sheddingLevel <= 3) {
      tags.add('medium shedding');
    } else if (sheddingLevel > 3) {
      tags.add('high shedding');
    }

    return Cat(
      name: json['name'],
      wiki: json['wikipedia_url'],
      energyLevel: json['energy_level'],
      lifeSpan: json['life_span'],
      description: json['description'],
      strangerFriendly: json['stranger_friendly'],
      tag: tags.join(' '),
      image: 'assets/images/${json["name"]}.JPG',
      dogFriendly: json['dog_friendly'],
      healthIssue: json['health_issues'],
      social: json['social_needs'],
      childFriendly: json['child_friendly'],
      affectionLevel: json['affection_level'],
      intelligence: json['intelligence'],
      temperament: json['temperament'],
      origin: json['origin']
    );
  }
}