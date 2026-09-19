/// HOME carousel — Ipiranga natação (seed + mock WireMock UUIDs).
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
    this.photoUrl,
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
  final String? photoUrl;
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
    name: 'CE Ipiranga – Balneário Carlos Joel Nelli',
    distanceMeters: 4200,
    tipo: 'Recreativa',
    presence: PresenceLevel.poucaGente,
    presenceCount: 8,
    accessLabel: 'Grátis',
    covered: true,
    heated: true,
    relatos: 12,
    comentarios: 6,
    placeId: '952f671d-fb18-46eb-a45a-e0897e925650',
    photoUrl:
        'https://expresso.estadao.com.br/sao-paulo/wp-content/uploads/2025/06/20250616_Centro_Espirtivo_Ipiranga_SB-21-scaled.jpg',
  ),
  NearbyPoolMock(
    name: 'Sesc Ipiranga',
    distanceMeters: 4600,
    tipo: 'Semi-olímpica',
    presence: PresenceLevel.cheio,
    presenceCount: 24,
    accessLabel: 'Pago',
    covered: true,
    heated: true,
    relatos: 18,
    comentarios: 11,
    placeId: 'b90aa544-aa3c-4d59-a3e8-ff0869b709f0',
    photoUrl:
        'https://www.sescsp.org.br/wp-content/uploads/2023/11/Piscina-do-Sesc-Ipiranga-Divulgacao.png',
  ),
  NearbyPoolMock(
    name: 'Clube Atlético Ypiranga',
    distanceMeters: 3800,
    tipo: 'Olímpica',
    presence: PresenceLevel.vazio,
    presenceCount: 3,
    accessLabel: 'Pago',
    heated: true,
    relatos: 9,
    comentarios: 4,
    placeId: '63657e49-38cc-4622-af36-0e3809d41d21',
    photoUrl: 'https://cay.com.br/wp-content/uploads/2026/07/DSC0060-1-scaled.jpg',
  ),
  NearbyPoolMock(
    name: 'Aqua School Ipiranga',
    distanceMeters: 5100,
    tipo: 'Recreativa',
    presence: PresenceLevel.poucaGente,
    presenceCount: 6,
    accessLabel: 'Pago',
    heated: true,
    covered: true,
    relatos: 5,
    comentarios: 3,
    placeId: '553d0911-92dd-41d6-a63c-04c3b156d995',
    photoUrl:
        'https://www.aquaschool.com.br/wp-content/uploads/2025/04/estrutura2.jpg',
  ),
  NearbyPoolMock(
    name: 'Soul Beach Arena',
    distanceMeters: 2800,
    tipo: 'Recreativa',
    presence: PresenceLevel.cheio,
    presenceCount: 31,
    accessLabel: 'Pago',
    relatos: 7,
    comentarios: 15,
    placeId: 'c6d37240-a27f-494c-ad94-b8c752acaec8',
    photoUrl:
        'https://arenasoulbeach.com.br/img/arena-soul-beach-esporte-comida-servico-3.jpg',
  ),
];

const kMockPertoDeVoce = <NearbyPoolMock>[
  NearbyPoolMock(
    name: 'CE Ipiranga',
    distanceMeters: 4200,
    tipo: 'Recreativa',
    presence: PresenceLevel.poucaGente,
    presenceCount: 8,
    accessLabel: 'Grátis',
    placeId: '952f671d-fb18-46eb-a45a-e0897e925650',
    photoUrl:
        'https://expresso.estadao.com.br/sao-paulo/wp-content/uploads/2025/06/20250616_Centro_Espirtivo_Ipiranga_SB-21-scaled.jpg',
  ),
  NearbyPoolMock(
    name: 'Sesc Ipiranga',
    distanceMeters: 4600,
    tipo: 'Semi-olímpica',
    presence: PresenceLevel.cheio,
    presenceCount: 24,
    accessLabel: 'Pago',
    placeId: 'b90aa544-aa3c-4d59-a3e8-ff0869b709f0',
    photoUrl:
        'https://www.sescsp.org.br/wp-content/uploads/2023/11/Piscina-do-Sesc-Ipiranga-Divulgacao.png',
  ),
  NearbyPoolMock(
    name: 'Aqua School',
    distanceMeters: 5100,
    tipo: 'Recreativa',
    presence: PresenceLevel.poucaGente,
    presenceCount: 6,
    accessLabel: 'Pago',
    placeId: '553d0911-92dd-41d6-a63c-04c3b156d995',
    photoUrl:
        'https://www.aquaschool.com.br/wp-content/uploads/2025/04/estrutura2.jpg',
  ),
  NearbyPoolMock(
    name: 'Training UP',
    distanceMeters: 4400,
    tipo: 'Semi-olímpica',
    presence: PresenceLevel.vazio,
    presenceCount: 2,
    accessLabel: 'Pago',
    placeId: 'c93fcb17-14f5-4483-adce-288fff2a8f07',
  ),
];

const kMockEmAlta = <TrendMock>[
  TrendMock(
    rank: 1,
    keyword: 'ipiranga',
    subtitle: 'natação no bairro piloto',
  ),
  TrendMock(
    rank: 2,
    keyword: 'sesc ipiranga',
    subtitle: 'piscina coberta aquecida',
  ),
  TrendMock(
    rank: 3,
    keyword: 'ce ipiranga',
    subtitle: 'grátis com carteirinha SEME',
  ),
];
