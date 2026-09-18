/// UI-only mock for HOME carousel (HOME-IA).
/// Not OpenAPI fields — presence/tipo/amenities are presentation stubs
/// until the backend exposes them. [placeId] may link to known QA places.
enum PresenceLevel {
  vazio,
  poucaGente,
  cheio;

  String get label => switch (this) {
        PresenceLevel.vazio => 'Vazio',
        PresenceLevel.poucaGente => 'Pouca gente',
        PresenceLevel.cheio => 'Cheio',
      };
}

class NearbyPoolMock {
  const NearbyPoolMock({
    required this.name,
    required this.distanceMeters,
    required this.tipo,
    required this.presence,
    required this.presenceCount,
    required this.accessLabel,
    this.covered = false,
    this.heated = false,
    this.totalPass = false,
    this.relatos,
    this.comentarios,
    this.placeId,
  });

  final String name;
  final int distanceMeters;
  final String tipo;
  final PresenceLevel presence;
  final int presenceCount;
  final String accessLabel;
  final bool covered;
  final bool heated;
  final bool totalPass;
  final int? relatos;
  final int? comentarios;
  final String? placeId;
}

class TrendMock {
  const TrendMock({
    required this.rank,
    required this.keyword,
    required this.subtitle,
  });
  final int rank;
  final String keyword;
  final String subtitle;
}

const kMockNearbyPools = <NearbyPoolMock>[
  NearbyPoolMock(
    name: 'Municipal Vila Mariana',
    distanceMeters: 450,
    tipo: 'Olímpica',
    presence: PresenceLevel.poucaGente,
    presenceCount: 12,
    accessLabel: 'Grátis',
    covered: true,
    heated: true,
    totalPass: true,
    relatos: 8,
    comentarios: 14,
    placeId: 'place_in_radius_qa',
  ),
  NearbyPoolMock(
    name: 'Lagoa Azul',
    distanceMeters: 1800,
    tipo: 'Recreativa',
    presence: PresenceLevel.vazio,
    presenceCount: 2,
    accessLabel: 'Grátis',
    relatos: 3,
    comentarios: 5,
  ),
  NearbyPoolMock(
    name: 'Clube Aquático Centro',
    distanceMeters: 2400,
    tipo: 'Semi-olímpica',
    presence: PresenceLevel.cheio,
    presenceCount: 48,
    accessLabel: 'Pago',
    heated: true,
    totalPass: true,
    relatos: 21,
    comentarios: 33,
    placeId: 'place_out_of_radius_qa',
  ),
];

const kMockPertoDeVoce = <NearbyPoolMock>[
  NearbyPoolMock(
    name: 'Lagoa Azul',
    distanceMeters: 1800,
    tipo: 'Recreativa',
    presence: PresenceLevel.vazio,
    presenceCount: 2,
    accessLabel: 'Grátis',
  ),
  NearbyPoolMock(
    name: 'Clube Aquático',
    distanceMeters: 2400,
    tipo: 'Semi-olímpica',
    presence: PresenceLevel.cheio,
    presenceCount: 48,
    accessLabel: 'Total Pass',
    totalPass: true,
  ),
];

const kMockEmAlta = <TrendMock>[
  TrendMock(
    rank: 1,
    keyword: 'vila mariana',
    subtitle: '28 check-ins recentes',
  ),
  TrendMock(
    rank: 2,
    keyword: 'água quente',
    subtitle: '19 posts recentes',
  ),
  TrendMock(
    rank: 3,
    keyword: 'total pass',
    subtitle: '15 menções recentes',
  ),
];
