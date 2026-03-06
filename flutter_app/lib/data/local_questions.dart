/// Embedded question bank — works 100% offline, no API needed.
/// Each question has the correctAnswer field set.

class LocalQuestion {
  final String id;
  final String subject;
  final String text;
  final List<LocalOption> options;
  final String correctAnswer; // label: 'A','B','C','D'
  final String explanation;
  final int difficulty; // 1–5

  const LocalQuestion({
    required this.id,
    required this.subject,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
  });
}

class LocalOption {
  final String label;
  final String value;
  const LocalOption(this.label, this.value);
}

// ─── MATHS ────────────────────────────────────────────────────────────────────
const _math = [
  LocalQuestion(
    id: 'q_m1', subject: 'math', difficulty: 1,
    text: 'Combien font 7 × 8 ?',
    options: [LocalOption('A','54'), LocalOption('B','56'), LocalOption('C','62'), LocalOption('D','48')],
    correctAnswer: 'B', explanation: '7 × 8 = 56',
  ),
  LocalQuestion(
    id: 'q_m2', subject: 'math', difficulty: 1,
    text: 'Quel est le résultat de 15 + 27 ?',
    options: [LocalOption('A','40'), LocalOption('B','43'), LocalOption('C','42'), LocalOption('D','41')],
    correctAnswer: 'C', explanation: '15 + 27 = 42',
  ),
  LocalQuestion(
    id: 'q_m3', subject: 'math', difficulty: 2,
    text: 'Quel est le carré de 13 ?',
    options: [LocalOption('A','156'), LocalOption('B','169'), LocalOption('C','144'), LocalOption('D','196')],
    correctAnswer: 'B', explanation: '13² = 169',
  ),
  LocalQuestion(
    id: 'q_m4', subject: 'math', difficulty: 2,
    text: 'Quelle est la valeur de √144 ?',
    options: [LocalOption('A','11'), LocalOption('B','13'), LocalOption('C','12'), LocalOption('D','14')],
    correctAnswer: 'C', explanation: '√144 = 12',
  ),
  LocalQuestion(
    id: 'q_m5', subject: 'math', difficulty: 3,
    text: 'Si f(x) = 2x² − 3x + 1, que vaut f(2) ?',
    options: [LocalOption('A','3'), LocalOption('B','5'), LocalOption('C','7'), LocalOption('D','9')],
    correctAnswer: 'A', explanation: 'f(2) = 2(4) − 6 + 1 = 3',
  ),
  LocalQuestion(
    id: 'q_m6', subject: 'math', difficulty: 3,
    text: 'Combien y a-t-il de nombres premiers entre 1 et 20 ?',
    options: [LocalOption('A','6'), LocalOption('B','7'), LocalOption('C','8'), LocalOption('D','9')],
    correctAnswer: 'C', explanation: '2,3,5,7,11,13,17,19 → 8 nombres premiers',
  ),
  LocalQuestion(
    id: 'q_m7', subject: 'math', difficulty: 4,
    text: 'Quelle est la dérivée de sin(x) × cos(x) ?',
    options: [LocalOption('A','cos²(x)−sin²(x)'), LocalOption('B','2sin(x)cos(x)'), LocalOption('C','1'), LocalOption('D','sin²(x)−cos²(x)')],
    correctAnswer: 'A', explanation: "d/dx[sin(x)cos(x)] = cos²(x) − sin²(x) = cos(2x)",
  ),
  LocalQuestion(
    id: 'q_m8', subject: 'math', difficulty: 4,
    text: 'Que vaut ∫₀¹ x² dx ?',
    options: [LocalOption('A','1/2'), LocalOption('B','1/3'), LocalOption('C','1/4'), LocalOption('D','2/3')],
    correctAnswer: 'B', explanation: '∫₀¹ x² dx = [x³/3]₀¹ = 1/3',
  ),
  LocalQuestion(
    id: 'q_m9', subject: 'math', difficulty: 5,
    text: 'Quelle est la limite de (sin x)/x quand x→0 ?',
    options: [LocalOption('A','0'), LocalOption('B','∞'), LocalOption('C','1'), LocalOption('D','π')],
    correctAnswer: 'C', explanation: 'Limite de (sin x)/x = 1 (règle de L\'Hôpital ou développement Taylor)',
  ),
  LocalQuestion(
    id: 'q_m10', subject: 'math', difficulty: 2,
    text: 'Quel est le PGCD de 48 et 18 ?',
    options: [LocalOption('A','6'), LocalOption('B','9'), LocalOption('C','12'), LocalOption('D','3')],
    correctAnswer: 'A', explanation: '48 = 2⁴×3, 18 = 2×3² → PGCD = 2×3 = 6',
  ),
  LocalQuestion(
    id: 'q_m11', subject: 'math', difficulty: 1,
    text: 'Combien font 144 ÷ 12 ?',
    options: [LocalOption('A','11'), LocalOption('B','12'), LocalOption('C','13'), LocalOption('D','14')],
    correctAnswer: 'B', explanation: '144 ÷ 12 = 12',
  ),
  LocalQuestion(
    id: 'q_m12', subject: 'math', difficulty: 2,
    text: 'Quel est le périmètre d\'un cercle de rayon 7 cm ?',
    options: [LocalOption('A','22π cm'), LocalOption('B','14π cm'), LocalOption('C','7π cm'), LocalOption('D','49π cm')],
    correctAnswer: 'B', explanation: 'P = 2πr = 2π×7 = 14π cm',
  ),
  LocalQuestion(
    id: 'q_m13', subject: 'math', difficulty: 3,
    text: 'Quelle est la somme des angles d\'un triangle ?',
    options: [LocalOption('A','90°'), LocalOption('B','360°'), LocalOption('C','180°'), LocalOption('D','270°')],
    correctAnswer: 'C', explanation: 'La somme des angles d\'un triangle = 180°',
  ),
  LocalQuestion(
    id: 'q_m14', subject: 'math', difficulty: 3,
    text: 'Résoudre : 3x + 5 = 20. Que vaut x ?',
    options: [LocalOption('A','4'), LocalOption('B','5'), LocalOption('C','6'), LocalOption('D','7')],
    correctAnswer: 'B', explanation: '3x = 15, x = 5',
  ),
  LocalQuestion(
    id: 'q_m15', subject: 'math', difficulty: 4,
    text: 'Combien de diagonales possède un hexagone ?',
    options: [LocalOption('A','6'), LocalOption('B','9'), LocalOption('C','12'), LocalOption('D','15')],
    correctAnswer: 'B', explanation: 'n(n-3)/2 = 6(3)/2 = 9 diagonales',
  ),
  LocalQuestion(
    id: 'q_m16', subject: 'math', difficulty: 5,
    text: 'Quelle est la somme de la série 1 + 1/2 + 1/4 + 1/8 + ... ?',
    options: [LocalOption('A','1'), LocalOption('B','2'), LocalOption('C','∞'), LocalOption('D','π')],
    correctAnswer: 'B', explanation: 'Série géométrique a/(1-r) = 1/(1-0.5) = 2',
  ),
  LocalQuestion(
    id: 'q_m17', subject: 'math', difficulty: 2,
    text: 'Quel est 25% de 200 ?',
    options: [LocalOption('A','25'), LocalOption('B','40'), LocalOption('C','50'), LocalOption('D','75')],
    correctAnswer: 'C', explanation: '25% × 200 = 50',
  ),
  LocalQuestion(
    id: 'q_m18', subject: 'math', difficulty: 4,
    text: 'Que vaut log₁₀(1000) ?',
    options: [LocalOption('A','2'), LocalOption('B','3'), LocalOption('C','4'), LocalOption('D','10')],
    correctAnswer: 'B', explanation: 'log₁₀(1000) = log₁₀(10³) = 3',
  ),
  LocalQuestion(
    id: 'q_m19', subject: 'math', difficulty: 3,
    text: 'Quelle est l\'aire d\'un triangle de base 10 cm et de hauteur 6 cm ?',
    options: [LocalOption('A','60 cm²'), LocalOption('B','30 cm²'), LocalOption('C','16 cm²'), LocalOption('D','36 cm²')],
    correctAnswer: 'B', explanation: 'A = b×h/2 = 10×6/2 = 30 cm²',
  ),
  LocalQuestion(
    id: 'q_m20', subject: 'math', difficulty: 5,
    text: 'Quelle est la valeur de e⁰ ?',
    options: [LocalOption('A','0'), LocalOption('B','e'), LocalOption('C','1'), LocalOption('D','∞')],
    correctAnswer: 'C', explanation: 'Tout nombre élevé à la puissance 0 vaut 1, donc e⁰ = 1',
  ),
  LocalQuestion(
    id: 'q_m21', subject: 'math', difficulty: 2,
    text: 'Combien font 3! (factorielle de 3) ?',
    options: [LocalOption('A','3'), LocalOption('B','6'), LocalOption('C','9'), LocalOption('D','27')],
    correctAnswer: 'B', explanation: '3! = 3 × 2 × 1 = 6',
  ),
  LocalQuestion(
    id: 'q_m22', subject: 'math', difficulty: 4,
    text: 'Quelle est la médiane de la série : 3, 7, 9, 12, 15 ?',
    options: [LocalOption('A','7'), LocalOption('B','9'), LocalOption('C','12'), LocalOption('D','9.2')],
    correctAnswer: 'B', explanation: 'La médiane d\'une série ordonnée impaire est la valeur centrale : 9',
  ),
  LocalQuestion(
    id: 'q_m23', subject: 'math', difficulty: 3,
    text: 'Résoudre : x² = 49. Les solutions sont :',
    options: [LocalOption('A','7'), LocalOption('B','-7'), LocalOption('C','7 et -7'), LocalOption('D','49')],
    correctAnswer: 'C', explanation: 'x² = 49 implique x = 7 ou x = -7',
  ),
  LocalQuestion(
    id: 'q_m24', subject: 'math', difficulty: 2,
    text: 'Que vaut 3! (factorielle de 3) ?',
    options: [LocalOption('A','3'), LocalOption('B','6'), LocalOption('C','9'), LocalOption('D','12')],
    correctAnswer: 'B', explanation: '3! = 3 × 2 × 1 = 6',
  ),
  LocalQuestion(
    id: 'q_m25', subject: 'math', difficulty: 3,
    text: 'Quelle est la dérivée de f(x) = 3x³ ?',
    options: [LocalOption('A','9x²'), LocalOption('B','3x²'), LocalOption('C','6x²'), LocalOption('D','x³')],
    correctAnswer: 'A', explanation: 'f\'(x) = 3 × 3x² = 9x²',
  ),
  LocalQuestion(
    id: 'q_m26', subject: 'math', difficulty: 2,
    text: 'Quel est le PGCD de 24 et 36 ?',
    options: [LocalOption('A','6'), LocalOption('B','12'), LocalOption('C','8'), LocalOption('D','4')],
    correctAnswer: 'B', explanation: 'PGCD(24, 36) = 12',
  ),
  LocalQuestion(
    id: 'q_m27', subject: 'math', difficulty: 4,
    text: 'Combien de diagonales possède un hexagone ?',
    options: [LocalOption('A','6'), LocalOption('B','9'), LocalOption('C','12'), LocalOption('D','15')],
    correctAnswer: 'B', explanation: 'Nombre de diagonales = n(n-3)/2 = 6×3/2 = 9',
  ),
  LocalQuestion(
    id: 'q_m28', subject: 'math', difficulty: 1,
    text: 'Combien font 25% de 200 ?',
    options: [LocalOption('A','25'), LocalOption('B','40'), LocalOption('C','50'), LocalOption('D','75')],
    correctAnswer: 'C', explanation: '25% de 200 = 200 × 0.25 = 50',
  ),
  LocalQuestion(
    id: 'q_m29', subject: 'math', difficulty: 3,
    text: 'Si log₁₀(x) = 3, que vaut x ?',
    options: [LocalOption('A','30'), LocalOption('B','300'), LocalOption('C','1000'), LocalOption('D','10000')],
    correctAnswer: 'C', explanation: 'log₁₀(x) = 3 → x = 10³ = 1000',
  ),
  LocalQuestion(
    id: 'q_m30', subject: 'math', difficulty: 4,
    text: 'Quelle est la somme des angles intérieurs d\'un pentagone ?',
    options: [LocalOption('A','360°'), LocalOption('B','540°'), LocalOption('C','720°'), LocalOption('D','480°')],
    correctAnswer: 'B', explanation: 'Somme = (n-2)×180 = 3×180 = 540°',
  ),
];

// ─── PHYSIQUE ─────────────────────────────────────────────────────────────────
const _physics = [
  LocalQuestion(
    id: 'q_p1', subject: 'physics', difficulty: 1,
    text: 'Quelle est la vitesse de la lumière dans le vide (en km/s) ?',
    options: [LocalOption('A','150 000'), LocalOption('B','300 000'), LocalOption('C','500 000'), LocalOption('D','1 000 000')],
    correctAnswer: 'B', explanation: 'c ≈ 300 000 km/s = 3×10⁸ m/s',
  ),
  LocalQuestion(
    id: 'q_p2', subject: 'physics', difficulty: 2,
    text: 'Quelle loi relie tension, intensité et résistance ?',
    options: [LocalOption('A','Loi de Newton'), LocalOption('B','Loi d\'Ohm'), LocalOption('C','Loi de Faraday'), LocalOption('D','Loi de Coulomb')],
    correctAnswer: 'B', explanation: 'U = R × I est la loi d\'Ohm',
  ),
  LocalQuestion(
    id: 'q_p3', subject: 'physics', difficulty: 2,
    text: 'Quelle est l\'unité du courant électrique dans le SI ?',
    options: [LocalOption('A','Volt'), LocalOption('B','Ohm'), LocalOption('C','Ampère'), LocalOption('D','Watt')],
    correctAnswer: 'C', explanation: "L'Ampère (A) est l'unité SI du courant",
  ),
  LocalQuestion(
    id: 'q_p4', subject: 'physics', difficulty: 3,
    text: 'Un objet de 2 kg est lancé à 10 m/s. Quelle est son énergie cinétique ?',
    options: [LocalOption('A','20 J'), LocalOption('B','50 J'), LocalOption('C','100 J'), LocalOption('D','200 J')],
    correctAnswer: 'C', explanation: 'Ec = ½mv² = ½ × 2 × 100 = 100 J',
  ),
  LocalQuestion(
    id: 'q_p5', subject: 'physics', difficulty: 3,
    text: 'Quelle est la formule de la force gravitationnelle selon Newton ?',
    options: [LocalOption('A','F = ma'), LocalOption('B','F = Gm₁m₂/r²'), LocalOption('C','F = kq₁q₂/r²'), LocalOption('D','F = mv²/r')],
    correctAnswer: 'B', explanation: 'Loi de gravitation universelle : F = Gm₁m₂/r²',
  ),
  LocalQuestion(
    id: 'q_p6', subject: 'physics', difficulty: 4,
    text: 'Quelle est la formule de l\'énergie de masse selon Einstein ?',
    options: [LocalOption('A','E = mv²'), LocalOption('B','E = ½mv²'), LocalOption('C','E = mc²'), LocalOption('D','E = hν')],
    correctAnswer: 'C', explanation: 'Équivalence masse-énergie : E = mc²',
  ),
  LocalQuestion(
    id: 'q_p7', subject: 'physics', difficulty: 1,
    text: 'Quelle planète est la plus proche du Soleil ?',
    options: [LocalOption('A','Vénus'), LocalOption('B','Mars'), LocalOption('C','Mercure'), LocalOption('D','Terre')],
    correctAnswer: 'C', explanation: 'Mercure est la planète la plus proche du Soleil',
  ),
  LocalQuestion(
    id: 'q_p8', subject: 'physics', difficulty: 2,
    text: 'Quelle est l\'accélération de la pesanteur terrestre (en m/s²) ?',
    options: [LocalOption('A','8.9'), LocalOption('B','9.81'), LocalOption('C','10.5'), LocalOption('D','11.2')],
    correctAnswer: 'B', explanation: 'g ≈ 9,81 m/s² sur Terre',
  ),
  LocalQuestion(
    id: 'q_p9', subject: 'physics', difficulty: 3,
    text: 'Quelle est l\'unité de mesure de la puissance électrique ?',
    options: [LocalOption('A','Joule'), LocalOption('B','Ampère'), LocalOption('C','Watt'), LocalOption('D','Coulomb')],
    correctAnswer: 'C', explanation: 'Le Watt (W) mesure la puissance : P = U × I',
  ),
  LocalQuestion(
    id: 'q_p10', subject: 'physics', difficulty: 4,
    text: 'Quel phénomène explique le changement de direction de la lumière entre deux milieux ?',
    options: [LocalOption('A','Diffraction'), LocalOption('B','Réflexion'), LocalOption('C','Réfraction'), LocalOption('D','Dispersion')],
    correctAnswer: 'C', explanation: 'La réfraction est le changement de direction de la lumière entre deux milieux (loi de Snell-Descartes)',
  ),
  LocalQuestion(
    id: 'q_p11', subject: 'physics', difficulty: 1,
    text: 'L\'eau bout à combien de degrés Celsius (pression standard) ?',
    options: [LocalOption('A','80°C'), LocalOption('B','90°C'), LocalOption('C','100°C'), LocalOption('D','120°C')],
    correctAnswer: 'C', explanation: 'L\'eau bout à 100°C sous pression atmosphérique standard',
  ),
  LocalQuestion(
    id: 'q_p12', subject: 'physics', difficulty: 5,
    text: 'Quelle particule subatomique a une charge positive ?',
    options: [LocalOption('A','Électron'), LocalOption('B','Neutron'), LocalOption('C','Proton'), LocalOption('D','Photon')],
    correctAnswer: 'C', explanation: 'Le proton porte une charge positive +e',
  ),
  LocalQuestion(
    id: 'q_p13', subject: 'physics', difficulty: 3,
    text: 'Quelle est la 3ème loi de Newton ?',
    options: [LocalOption('A','F = ma'), LocalOption('B','Action = Réaction'), LocalOption('C','E = mc²'), LocalOption('D','PV = nRT')],
    correctAnswer: 'B', explanation: 'La 3ème loi de Newton : à chaque action correspond une réaction égale et opposée',
  ),
  LocalQuestion(
    id: 'q_p14', subject: 'physics', difficulty: 2,
    text: 'Quelle est l\'unité de mesure de la fréquence ?',
    options: [LocalOption('A','Newton'), LocalOption('B','Hertz'), LocalOption('C','Pascal'), LocalOption('D','Farad')],
    correctAnswer: 'B', explanation: 'Le Hertz (Hz) est l\'unité de fréquence : 1 Hz = 1 cycle/seconde',
  ),
  LocalQuestion(
    id: 'q_p15', subject: 'physics', difficulty: 4,
    text: 'Quel est le principe de conservation le plus fondamental en physique ?',
    options: [LocalOption('A','Conservation de la masse'), LocalOption('B','Conservation de l\'énergie'), LocalOption('C','Conservation de la quantité de mouvement'), LocalOption('D','Tous ces principes')],
    correctAnswer: 'D', explanation: 'La masse, l\'énergie (E=mc²) et la quantité de mouvement sont toutes conservées',
  ),
  LocalQuestion(
    id: 'q_p16', subject: 'physics', difficulty: 5,
    text: 'Quelle est la longueur d\'onde approximative de la lumière visible rouge ?',
    options: [LocalOption('A','400 nm'), LocalOption('B','550 nm'), LocalOption('C','700 nm'), LocalOption('D','900 nm')],
    correctAnswer: 'C', explanation: 'La lumière rouge a une longueur d\'onde d\'environ 620-750 nm',
  ),
  LocalQuestion(
    id: 'q_p17', subject: 'physics', difficulty: 3,
    text: 'Quelle force maintient les planètes en orbite autour du Soleil ?',
    options: [LocalOption('A','Force électromagnétique'), LocalOption('B','Force nucléaire'), LocalOption('C','Force gravitationnelle'), LocalOption('D','Force centrifuge')],
    correctAnswer: 'C', explanation: 'La force gravitationnelle (F = Gm₁m₂/r²) maintient les planètes en orbite',
  ),
  LocalQuestion(
    id: 'q_p18', subject: 'physics', difficulty: 2,
    text: 'Quelle est l\'unité de mesure de la pression ?',
    options: [LocalOption('A','Newton'), LocalOption('B','Pascal'), LocalOption('C','Joule'), LocalOption('D','Watt')],
    correctAnswer: 'B', explanation: 'La pression se mesure en Pascal (Pa). 1 Pa = 1 N/m²',
  ),
  LocalQuestion(
    id: 'q_p19', subject: 'physics', difficulty: 1,
    text: 'De quelle couleur est le ciel par temps clair ?',
    options: [LocalOption('A','Rouge'), LocalOption('B','Vert'), LocalOption('C','Bleu'), LocalOption('D','Jaune')],
    correctAnswer: 'C', explanation: 'La diffusion de Rayleigh fait apparaître le ciel bleu car les courtes longueurs d\'onde (bleu) sont plus diffusées',
  ),
  LocalQuestion(
    id: 'q_p20', subject: 'physics', difficulty: 3,
    text: 'Quelle est la formule de l\'énergie cinétique ?',
    options: [LocalOption('A','E = mc²'), LocalOption('B','E = ½mv²'), LocalOption('C','E = mgh'), LocalOption('D','E = Fd')],
    correctAnswer: 'B', explanation: 'L\'énergie cinétique Ec = ½mv², avec m la masse et v la vitesse',
  ),
  LocalQuestion(
    id: 'q_p21', subject: 'physics', difficulty: 4,
    text: 'Quel phénomène explique la déviation de la lumière à travers un prisme ?',
    options: [LocalOption('A','Réflexion'), LocalOption('B','Diffraction'), LocalOption('C','Réfraction'), LocalOption('D','Polarisation')],
    correctAnswer: 'C', explanation: 'La réfraction est le changement de direction de la lumière lorsqu\'elle passe d\'un milieu à un autre',
  ),
  LocalQuestion(
    id: 'q_p22', subject: 'physics', difficulty: 2,
    text: 'Quelle est la vitesse du son dans l\'air (environ) ?',
    options: [LocalOption('A','300 m/s'), LocalOption('B','340 m/s'), LocalOption('C','400 m/s'), LocalOption('D','500 m/s')],
    correctAnswer: 'B', explanation: 'La vitesse du son dans l\'air est d\'environ 340 m/s (à 20°C)',
  ),
];

// ─── CHIMIE ───────────────────────────────────────────────────────────────────
const _chemistry = [
  LocalQuestion(
    id: 'q_c1', subject: 'chemistry', difficulty: 1,
    text: 'Quel est le symbole chimique de l\'or ?',
    options: [LocalOption('A','Or'), LocalOption('B','Au'), LocalOption('C','Ag'), LocalOption('D','Fe')],
    correctAnswer: 'B', explanation: 'Au vient du latin Aurum (or)',
  ),
  LocalQuestion(
    id: 'q_c2', subject: 'chemistry', difficulty: 2,
    text: 'Combien d\'électrons peut contenir la couche L (n=2) ?',
    options: [LocalOption('A','2'), LocalOption('B','6'), LocalOption('C','8'), LocalOption('D','18')],
    correctAnswer: 'C', explanation: 'La couche L (n=2) peut contenir 2n² = 8 électrons',
  ),
  LocalQuestion(
    id: 'q_c3', subject: 'chemistry', difficulty: 2,
    text: 'Quelle est la formule chimique de l\'eau ?',
    options: [LocalOption('A','HO'), LocalOption('B','H₂O'), LocalOption('C','H₂O₂'), LocalOption('D','OH')],
    correctAnswer: 'B', explanation: 'L\'eau est H₂O : 2 hydrogènes + 1 oxygène',
  ),
  LocalQuestion(
    id: 'q_c4', subject: 'chemistry', difficulty: 3,
    text: 'Quel gaz est produit lors de la réaction entre l\'acide chlorhydrique (HCl) et du zinc ?',
    options: [LocalOption('A','O₂'), LocalOption('B','CO₂'), LocalOption('C','H₂'), LocalOption('D','Cl₂')],
    correctAnswer: 'C', explanation: 'Zn + 2HCl → ZnCl₂ + H₂↑',
  ),
  LocalQuestion(
    id: 'q_c5', subject: 'chemistry', difficulty: 3,
    text: 'Quel est le pH d\'une solution neutre à 25°C ?',
    options: [LocalOption('A','0'), LocalOption('B','7'), LocalOption('C','14'), LocalOption('D','1')],
    correctAnswer: 'B', explanation: 'À 25°C, le pH neutre est exactement 7',
  ),
  LocalQuestion(
    id: 'q_c6', subject: 'chemistry', difficulty: 4,
    text: 'Quel type de liaison relie les atomes dans une molécule d\'eau ?',
    options: [LocalOption('A','Ionique'), LocalOption('B','Métallique'), LocalOption('C','Covalente'), LocalOption('D','Van der Waals')],
    correctAnswer: 'C', explanation: 'L\'eau présente des liaisons covalentes polaires O-H',
  ),
  LocalQuestion(
    id: 'q_c7', subject: 'chemistry', difficulty: 2,
    text: 'Combien d\'éléments le tableau périodique contient-il actuellement ?',
    options: [LocalOption('A','92'), LocalOption('B','108'), LocalOption('C','118'), LocalOption('D','126')],
    correctAnswer: 'C', explanation: 'Le tableau périodique contient 118 éléments reconnus',
  ),
  LocalQuestion(
    id: 'q_c8', subject: 'chemistry', difficulty: 1,
    text: 'Quel gaz respirons-nous principalement ?',
    options: [LocalOption('A','Oxygène'), LocalOption('B','Azote'), LocalOption('C','CO₂'), LocalOption('D','Hélium')],
    correctAnswer: 'B', explanation: 'L\'atmosphère contient ~78% d\'azote (N₂), 21% d\'oxygène (O₂)',
  ),
  LocalQuestion(
    id: 'q_c9', subject: 'chemistry', difficulty: 3,
    text: 'Quel est le numéro atomique du carbone ?',
    options: [LocalOption('A','4'), LocalOption('B','6'), LocalOption('C','8'), LocalOption('D','12')],
    correctAnswer: 'B', explanation: 'Le carbone (C) a un numéro atomique Z = 6',
  ),
  LocalQuestion(
    id: 'q_c10', subject: 'chemistry', difficulty: 4,
    text: 'Quelle est la masse molaire de l\'eau (H₂O) en g/mol ?',
    options: [LocalOption('A','16'), LocalOption('B','18'), LocalOption('C','20'), LocalOption('D','32')],
    correctAnswer: 'B', explanation: 'M(H₂O) = 2(1) + 16 = 18 g/mol',
  ),
  LocalQuestion(
    id: 'q_c11', subject: 'chemistry', difficulty: 2,
    text: 'Quel métal est liquide à température ambiante ?',
    options: [LocalOption('A','Plomb'), LocalOption('B','Étain'), LocalOption('C','Mercure'), LocalOption('D','Gallium')],
    correctAnswer: 'C', explanation: 'Le mercure (Hg) est liquide à température ambiante (point de fusion −39°C)',
  ),
  LocalQuestion(
    id: 'q_c12', subject: 'chemistry', difficulty: 5,
    text: 'Quel est le nombre d\'Avogadro ?',
    options: [LocalOption('A','6,022 × 10²³'), LocalOption('B','3,14 × 10²³'), LocalOption('C','1,602 × 10⁻¹⁹'), LocalOption('D','9,81 × 10²²')],
    correctAnswer: 'A', explanation: 'Le nombre d\'Avogadro Nₐ = 6,022 × 10²³ mol⁻¹',
  ),
  LocalQuestion(
    id: 'q_c13', subject: 'chemistry', difficulty: 3,
    text: 'Quelle est la formule du sel de table ?',
    options: [LocalOption('A','KCl'), LocalOption('B','NaCl'), LocalOption('C','CaCl₂'), LocalOption('D','MgCl₂')],
    correctAnswer: 'B', explanation: 'Le sel de table est le chlorure de sodium : NaCl',
  ),
  LocalQuestion(
    id: 'q_c14', subject: 'chemistry', difficulty: 4,
    text: 'Quel est le gaz responsable de l\'effet de serre principal ?',
    options: [LocalOption('A','O₂'), LocalOption('B','N₂'), LocalOption('C','CO₂'), LocalOption('D','H₂')],
    correctAnswer: 'C', explanation: 'Le dioxyde de carbone (CO₂) est le principal gaz à effet de serre anthropique',
  ),
  LocalQuestion(
    id: 'q_c15', subject: 'chemistry', difficulty: 2,
    text: 'Quel est le symbole chimique du sodium ?',
    options: [LocalOption('A','So'), LocalOption('B','Na'), LocalOption('C','Sd'), LocalOption('D','S')],
    correctAnswer: 'B', explanation: 'Na vient du latin Natrium (sodium)',
  ),
  LocalQuestion(
    id: 'q_c16', subject: 'chemistry', difficulty: 5,
    text: 'Qu\'est-ce qu\'un isotope ?',
    options: [LocalOption('A','Même protons, neutrons diff.'), LocalOption('B','Même neutrons, protons diff.'), LocalOption('C','Même électrons, protons diff.'), LocalOption('D','Même masse, charges diff.')],
    correctAnswer: 'A', explanation: 'Les isotopes ont le même nombre de protons mais un nombre différent de neutrons',
  ),
  LocalQuestion(
    id: 'q_c17', subject: 'chemistry', difficulty: 3,
    text: 'Quelle est la formule de l\'acide sulfurique ?',
    options: [LocalOption('A','HCl'), LocalOption('B','HNO₃'), LocalOption('C','H₂SO₄'), LocalOption('D','H₃PO₄')],
    correctAnswer: 'C', explanation: 'L\'acide sulfurique est H₂SO₄',
  ),
  LocalQuestion(
    id: 'q_c18', subject: 'chemistry', difficulty: 2,
    text: 'Quel gaz est produit lors de la photosynthèse ?',
    options: [LocalOption('A','CO₂'), LocalOption('B','O₂'), LocalOption('C','N₂'), LocalOption('D','H₂')],
    correctAnswer: 'B', explanation: 'La photosynthèse produit de l\'oxygène (O₂) : 6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂',
  ),
  LocalQuestion(
    id: 'q_c19', subject: 'chemistry', difficulty: 1,
    text: 'Quel est le métal le plus léger ?',
    options: [LocalOption('A','Aluminium'), LocalOption('B','Lithium'), LocalOption('C','Sodium'), LocalOption('D','Magnésium')],
    correctAnswer: 'B', explanation: 'Le lithium (Li) est le métal le plus léger avec une densité de 0.534 g/cm³',
  ),
  LocalQuestion(
    id: 'q_c20', subject: 'chemistry', difficulty: 3,
    text: 'Quelle est la masse molaire de l\'eau (H₂O) ?',
    options: [LocalOption('A','16 g/mol'), LocalOption('B','18 g/mol'), LocalOption('C','20 g/mol'), LocalOption('D','22 g/mol')],
    correctAnswer: 'B', explanation: 'M(H₂O) = 2×1 + 16 = 18 g/mol',
  ),
  LocalQuestion(
    id: 'q_c21', subject: 'chemistry', difficulty: 4,
    text: 'Quel type de liaison chimique unit les atomes dans NaCl ?',
    options: [LocalOption('A','Covalente'), LocalOption('B','Ionique'), LocalOption('C','Métallique'), LocalOption('D','Van der Waals')],
    correctAnswer: 'B', explanation: 'NaCl (sel de table) est un composé ionique : Na⁺ et Cl⁻ sont liés par liaison ionique',
  ),
  LocalQuestion(
    id: 'q_c22', subject: 'chemistry', difficulty: 2,
    text: 'Combien d\'électrons possède un atome de carbone ?',
    options: [LocalOption('A','4'), LocalOption('B','6'), LocalOption('C','8'), LocalOption('D','12')],
    correctAnswer: 'B', explanation: 'Le carbone a le numéro atomique 6, donc 6 protons et 6 électrons',
  ),
];

// ─── CULTURE GÉNÉRALE ─────────────────────────────────────────────────────────
const _general = [
  LocalQuestion(
    id: 'q_g1', subject: 'general', difficulty: 1,
    text: 'En quelle année la Tour Eiffel a-t-elle été construite ?',
    options: [LocalOption('A','1889'), LocalOption('B','1900'), LocalOption('C','1875'), LocalOption('D','1920')],
    correctAnswer: 'A', explanation: 'La Tour Eiffel a été construite en 1889 pour l\'Exposition universelle',
  ),
  LocalQuestion(
    id: 'q_g2', subject: 'general', difficulty: 2,
    text: 'Quel est le pays le plus grand du monde par superficie ?',
    options: [LocalOption('A','Canada'), LocalOption('B','Chine'), LocalOption('C','Russie'), LocalOption('D','États-Unis')],
    correctAnswer: 'C', explanation: 'La Russie est le plus grand pays avec 17,1 millions de km²',
  ),
  LocalQuestion(
    id: 'q_g3', subject: 'general', difficulty: 1,
    text: 'Combien de joueurs compte une équipe de football (sur le terrain) ?',
    options: [LocalOption('A','10'), LocalOption('B','11'), LocalOption('C','12'), LocalOption('D','9')],
    correctAnswer: 'B', explanation: '11 joueurs par équipe sur le terrain',
  ),
  LocalQuestion(
    id: 'q_g4', subject: 'general', difficulty: 2,
    text: 'Quelle est la capitale du Maroc ?',
    options: [LocalOption('A','Casablanca'), LocalOption('B','Marrakech'), LocalOption('C','Rabat'), LocalOption('D','Fès')],
    correctAnswer: 'C', explanation: 'Rabat est la capitale administrative du Maroc',
  ),
  LocalQuestion(
    id: 'q_g5', subject: 'general', difficulty: 3,
    text: 'Quel est le fleuve le plus long d\'Afrique ?',
    options: [LocalOption('A','Congo'), LocalOption('B','Niger'), LocalOption('C','Nil'), LocalOption('D','Zambèze')],
    correctAnswer: 'C', explanation: 'Le Nil mesure environ 6 650 km, le plus long d\'Afrique',
  ),
  LocalQuestion(
    id: 'q_g6', subject: 'general', difficulty: 1,
    text: 'Combien de continents y a-t-il sur Terre ?',
    options: [LocalOption('A','5'), LocalOption('B','6'), LocalOption('C','7'), LocalOption('D','8')],
    correctAnswer: 'C', explanation: 'Il y a 7 continents : Afrique, Amérique du Nord/Sud, Antarctique, Asie, Europe, Océanie',
  ),
  LocalQuestion(
    id: 'q_g7', subject: 'general', difficulty: 2,
    text: 'Qui a peint La Joconde ?',
    options: [LocalOption('A','Michel-Ange'), LocalOption('B','Raphaël'), LocalOption('C','Léonard de Vinci'), LocalOption('D','Picasso')],
    correctAnswer: 'C', explanation: 'Léonard de Vinci a peint La Joconde (Mona Lisa) vers 1503-1519',
  ),
  LocalQuestion(
    id: 'q_g8', subject: 'general', difficulty: 1,
    text: 'Quelle est la langue la plus parlée au monde ?',
    options: [LocalOption('A','Anglais'), LocalOption('B','Espagnol'), LocalOption('C','Mandarin'), LocalOption('D','Hindi')],
    correctAnswer: 'C', explanation: 'Le mandarin (chinois) est la langue maternelle la plus parlée (~920 millions)',
  ),
  LocalQuestion(
    id: 'q_g9', subject: 'general', difficulty: 2,
    text: 'Quel est l\'océan le plus grand du monde ?',
    options: [LocalOption('A','Atlantique'), LocalOption('B','Indien'), LocalOption('C','Pacifique'), LocalOption('D','Arctique')],
    correctAnswer: 'C', explanation: 'L\'océan Pacifique est le plus grand avec 165,25 millions de km²',
  ),
  LocalQuestion(
    id: 'q_g10', subject: 'general', difficulty: 3,
    text: 'En quelle année le Maroc a-t-il obtenu son indépendance ?',
    options: [LocalOption('A','1952'), LocalOption('B','1956'), LocalOption('C','1960'), LocalOption('D','1962')],
    correctAnswer: 'B', explanation: 'Le Maroc a obtenu son indépendance le 2 mars 1956',
  ),
  LocalQuestion(
    id: 'q_g11', subject: 'general', difficulty: 2,
    text: 'Quelle est la monnaie du Japon ?',
    options: [LocalOption('A','Won'), LocalOption('B','Yuan'), LocalOption('C','Yen'), LocalOption('D','Baht')],
    correctAnswer: 'C', explanation: 'Le Yen (¥) est la monnaie du Japon',
  ),
  LocalQuestion(
    id: 'q_g12', subject: 'general', difficulty: 3,
    text: 'Qui a écrit "Le Petit Prince" ?',
    options: [LocalOption('A','Victor Hugo'), LocalOption('B','Saint-Exupéry'), LocalOption('C','Molière'), LocalOption('D','Camus')],
    correctAnswer: 'B', explanation: 'Antoine de Saint-Exupéry a écrit Le Petit Prince en 1943',
  ),
  LocalQuestion(
    id: 'q_g13', subject: 'general', difficulty: 1,
    text: 'Combien de côtés a un pentagone ?',
    options: [LocalOption('A','4'), LocalOption('B','5'), LocalOption('C','6'), LocalOption('D','7')],
    correctAnswer: 'B', explanation: 'Un pentagone a 5 côtés (penta = 5)',
  ),
  LocalQuestion(
    id: 'q_g14', subject: 'general', difficulty: 4,
    text: 'Quelle ville est surnommée "la ville rouge" ?',
    options: [LocalOption('A','Fès'), LocalOption('B','Casablanca'), LocalOption('C','Marrakech'), LocalOption('D','Rabat')],
    correctAnswer: 'C', explanation: 'Marrakech est surnommée la ville rouge en raison de la couleur de ses remparts',
  ),
  LocalQuestion(
    id: 'q_g15', subject: 'general', difficulty: 2,
    text: 'Quel est l\'élément chimique le plus abondant dans l\'univers ?',
    options: [LocalOption('A','Oxygène'), LocalOption('B','Carbone'), LocalOption('C','Hydrogène'), LocalOption('D','Hélium')],
    correctAnswer: 'C', explanation: 'L\'hydrogène représente ~75% de la masse de l\'univers',
  ),
  LocalQuestion(
    id: 'q_g16', subject: 'general', difficulty: 3,
    text: 'Quel pays a la plus grande population mondiale ?',
    options: [LocalOption('A','Inde'), LocalOption('B','Chine'), LocalOption('C','États-Unis'), LocalOption('D','Indonésie')],
    correctAnswer: 'A', explanation: 'L\'Inde a dépassé la Chine en population en 2023 (~1,4 milliard)',
  ),
  LocalQuestion(
    id: 'q_g17', subject: 'general', difficulty: 2,
    text: 'Quelle est la plus haute montagne du monde ?',
    options: [LocalOption('A','K2'), LocalOption('B','Mont Blanc'), LocalOption('C','Everest'), LocalOption('D','Kilimandjaro')],
    correctAnswer: 'C', explanation: 'L\'Everest culmine à 8 849 m, le point le plus haut de la Terre',
  ),
  LocalQuestion(
    id: 'q_g18', subject: 'general', difficulty: 4,
    text: 'En quelle année le premier pas sur la Lune a-t-il eu lieu ?',
    options: [LocalOption('A','1965'), LocalOption('B','1969'), LocalOption('C','1972'), LocalOption('D','1967')],
    correctAnswer: 'B', explanation: 'Neil Armstrong a marché sur la Lune le 20 juillet 1969 (Apollo 11)',
  ),
  LocalQuestion(
    id: 'q_g19', subject: 'general', difficulty: 1,
    text: 'Quel animal est le symbole du Maroc ?',
    options: [LocalOption('A','Aigle'), LocalOption('B','Lion'), LocalOption('C','Chameau'), LocalOption('D','Gazelle')],
    correctAnswer: 'B', explanation: 'Le lion de l\'Atlas est le symbole du Maroc',
  ),
  LocalQuestion(
    id: 'q_g20', subject: 'general', difficulty: 3,
    text: 'Quel est le plus grand désert du monde ?',
    options: [LocalOption('A','Sahara'), LocalOption('B','Gobi'), LocalOption('C','Antarctique'), LocalOption('D','Arabie')],
    correctAnswer: 'C', explanation: 'L\'Antarctique est le plus grand désert (14 millions km²), le Sahara est le plus grand désert chaud',
  ),
  LocalQuestion(
    id: 'q_g21', subject: 'general', difficulty: 1,
    text: 'Combien de continents y a-t-il sur Terre ?',
    options: [LocalOption('A','5'), LocalOption('B','6'), LocalOption('C','7'), LocalOption('D','8')],
    correctAnswer: 'C', explanation: 'Il y a 7 continents : Afrique, Amérique du Nord/Sud, Antarctique, Asie, Europe, Océanie',
  ),
  LocalQuestion(
    id: 'q_g22', subject: 'general', difficulty: 2,
    text: 'Quel est le plus long fleuve d\'Afrique ?',
    options: [LocalOption('A','Congo'), LocalOption('B','Niger'), LocalOption('C','Nil'), LocalOption('D','Zambèze')],
    correctAnswer: 'C', explanation: 'Le Nil est le plus long fleuve d\'Afrique avec environ 6 650 km',
  ),
  LocalQuestion(
    id: 'q_g23', subject: 'general', difficulty: 2,
    text: 'Qui a peint la Joconde ?',
    options: [LocalOption('A','Michel-Ange'), LocalOption('B','Raphaël'), LocalOption('C','Léonard de Vinci'), LocalOption('D','Botticelli')],
    correctAnswer: 'C', explanation: 'La Joconde (Mona Lisa) a été peinte par Léonard de Vinci vers 1503-1519',
  ),
  LocalQuestion(
    id: 'q_g24', subject: 'general', difficulty: 3,
    text: 'Quelle est la monnaie du Japon ?',
    options: [LocalOption('A','Won'), LocalOption('B','Yuan'), LocalOption('C','Yen'), LocalOption('D','Baht')],
    correctAnswer: 'C', explanation: 'Le yen (¥) est la monnaie officielle du Japon',
  ),
  LocalQuestion(
    id: 'q_g25', subject: 'general', difficulty: 1,
    text: 'Combien de joueurs composent une équipe de football sur le terrain ?',
    options: [LocalOption('A','9'), LocalOption('B','10'), LocalOption('C','11'), LocalOption('D','12')],
    correctAnswer: 'C', explanation: 'Une équipe de football compte 11 joueurs sur le terrain',
  ),
  LocalQuestion(
    id: 'q_g26', subject: 'general', difficulty: 4,
    text: 'En quelle année le Maroc a-t-il obtenu son indépendance ?',
    options: [LocalOption('A','1952'), LocalOption('B','1956'), LocalOption('C','1960'), LocalOption('D','1962')],
    correctAnswer: 'B', explanation: 'Le Maroc a obtenu son indépendance de la France le 2 mars 1956',
  ),
];

// ─── API publique ──────────────────────────────────────────────────────────────
const allLocalQuestions = [..._math, ..._physics, ..._chemistry, ..._general];

List<LocalQuestion> getQuestionsForSubject(String subjectSlug, {int count = 10}) {
  final all = [...allLocalQuestions];
  all.shuffle();

  // Filter by subject if we have enough, otherwise use all
  final filtered = all.where((q) {
    if (subjectSlug == 'math') return q.subject == 'math';
    if (subjectSlug == 'physics') return q.subject == 'physics';
    if (subjectSlug == 'chemistry') return q.subject == 'chemistry';
    if (subjectSlug == 'general') return q.subject == 'general';
    return true; // mixed or unknown
  }).toList();

  final pool = filtered.length >= count ? filtered : all;
  pool.shuffle();
  return pool.take(count).toList();
}
