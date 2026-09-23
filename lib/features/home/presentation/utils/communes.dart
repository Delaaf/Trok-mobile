/// Point géographique connu, utilisé pour la sélection manuelle et la
/// détection "position la plus proche". `commune` est nul pour une ville
/// hors Abidjan (on ne détaille pas leurs quartiers), non-nul pour une
/// commune précise d'Abidjan.
class LocationPoint {
  const LocationPoint({required this.label, required this.latitude, required this.longitude, this.city, this.commune, this.freeText});

  final String label;
  final double latitude;
  final double longitude;
  final String? city;
  final String? commune;

  /// Renseigné pour un résultat issu de la recherche GeoNames, où on ne sait
  /// pas si c'est une "ville" ou une "commune" au sens de nos colonnes —
  /// filtre générique (OR city/commune) côté backend.
  final String? freeText;
}

/// Communes d'Abidjan (détail fin, car c'est la ville avec le plus de trafic
/// attendu au lancement) — chacune filtre sur `commune`, avec `city` implicite
/// "Abidjan".
const abidjanCommunes = <LocationPoint>[
  LocationPoint(label: 'Abobo', latitude: 5.4199, longitude: -4.0207, city: 'Abidjan', commune: 'Abobo'),
  LocationPoint(label: 'Adjamé', latitude: 5.3599, longitude: -4.0248, city: 'Abidjan', commune: 'Adjamé'),
  LocationPoint(label: 'Angré', latitude: 5.3833, longitude: -3.9833, city: 'Abidjan', commune: 'Angré'),
  LocationPoint(label: 'Attécoubé', latitude: 5.3333, longitude: -4.0333, city: 'Abidjan', commune: 'Attécoubé'),
  LocationPoint(label: 'Bingerville', latitude: 5.3556, longitude: -3.8917, city: 'Abidjan', commune: 'Bingerville'),
  LocationPoint(label: 'Cocody', latitude: 5.3600, longitude: -3.9800, city: 'Abidjan', commune: 'Cocody'),
  LocationPoint(label: 'Koumassi', latitude: 5.2989, longitude: -3.9528, city: 'Abidjan', commune: 'Koumassi'),
  LocationPoint(label: 'Marcory', latitude: 5.2967, longitude: -3.9836, city: 'Abidjan', commune: 'Marcory'),
  LocationPoint(label: 'Plateau', latitude: 5.3200, longitude: -4.0200, city: 'Abidjan', commune: 'Plateau'),
  LocationPoint(label: 'Port-Bouët', latitude: 5.2500, longitude: -3.9333, city: 'Abidjan', commune: 'Port-Bouët'),
  LocationPoint(label: 'Riviera', latitude: 5.3667, longitude: -3.9500, city: 'Abidjan', commune: 'Riviera'),
  LocationPoint(label: 'Treichville', latitude: 5.2953, longitude: -4.0067, city: 'Abidjan', commune: 'Treichville'),
  LocationPoint(label: 'Yopougon', latitude: 5.3453, longitude: -4.0728, city: 'Abidjan', commune: 'Yopougon'),
];

/// Autres grandes villes de Côte d'Ivoire — filtre sur `city` uniquement
/// (pas de découpage par quartier pour l'instant).
const otherIvorianCities = <LocationPoint>[
  LocationPoint(label: 'Bouaké', latitude: 7.6906, longitude: -5.0303, city: 'Bouaké'),
  LocationPoint(label: 'Yamoussoukro', latitude: 6.8276, longitude: -5.2893, city: 'Yamoussoukro'),
  LocationPoint(label: 'San-Pédro', latitude: 4.7485, longitude: -6.6363, city: 'San-Pédro'),
  LocationPoint(label: 'Korhogo', latitude: 9.4580, longitude: -5.6296, city: 'Korhogo'),
  LocationPoint(label: 'Daloa', latitude: 6.8770, longitude: -6.4502, city: 'Daloa'),
  LocationPoint(label: 'Man', latitude: 7.4125, longitude: -7.5539, city: 'Man'),
  LocationPoint(label: 'Gagnoa', latitude: 6.1319, longitude: -5.9506, city: 'Gagnoa'),
  LocationPoint(label: 'Abengourou', latitude: 6.7297, longitude: -3.4964, city: 'Abengourou'),
  LocationPoint(label: 'Divo', latitude: 5.8372, longitude: -5.3572, city: 'Divo'),
  LocationPoint(label: 'Grand-Bassam', latitude: 5.2118, longitude: -3.7380, city: 'Grand-Bassam'),
];

/// Tous les points connus, pour la recherche "position la plus proche".
const allLocationPoints = [...abidjanCommunes, ...otherIvorianCities];
