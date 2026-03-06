-- MathQuest - Sample seed data

INSERT INTO subjects (name, slug, description, icon, color) VALUES
  ('Mathématiques', 'math',    'Algèbre, calcul, géométrie, ...',    'calculator',        'blue'),
  ('Physique',      'physics', 'Mécanique, électricité, optique ...','atom',              'purple'),
  ('Chimie',        'chem',    'Atomes, réactions, liaisons ...',    'flask',             'green'),
  ('Langues',       'lang',    'Grammaire, conjugaison, vocab ...',  'language',          'amber');

INSERT INTO badges (name, description, icon, condition_type, condition_value) VALUES
  ('Premier Pas',   'Remportez votre premier duel',                 'emoji_events',  'duels_won',    1),
  ('Imbattable',    'Remportez 10 duels',                           'military_tech', 'duels_won',    10),
  ('Génie Math',    'Atteignez le niveau 10',                       'school',        'level_reached',10),
  ('Perfectionniste','Obtenez 100% dans un duel',                   'grade',         'accuracy',     100),
  ('Régulier',      'Connectez-vous 7 jours de suite',              'local_fire_department','streak_days',7),
  ('Marathonien',   'Connectez-vous 30 jours de suite',             'workspace_premium','streak_days',30);

INSERT INTO questions (subject_id, text, options, correct_answer, explanation, difficulty) VALUES
  (
    (SELECT id FROM subjects WHERE slug='math'),
    'Quelle est la dérivée de f(x) = 3x² + 2x − 5 ?',
    '[{"label":"A","value":"6x + 2"},{"label":"B","value":"3x + 2"},{"label":"C","value":"6x² + 2"},{"label":"D","value":"3x² + 2x"}]',
    'A', 'La dérivée de axⁿ est n·a·xⁿ⁻¹. Donc (3x²)\'' = 6x et (2x)\'' = 2.', 2
  ),
  (
    (SELECT id FROM subjects WHERE slug='math'),
    'Résoudre : 2x + 5 = 13',
    '[{"label":"A","value":"x = 3"},{"label":"B","value":"x = 4"},{"label":"C","value":"x = 9"},{"label":"D","value":"x = 6"}]',
    'B', '2x = 13 − 5 = 8, donc x = 4.', 1
  ),
  (
    (SELECT id FROM subjects WHERE slug='physics'),
    'Quelle est la formule de l''énergie cinétique ?',
    '[{"label":"A","value":"E = mc²"},{"label":"B","value":"Ec = ½mv²"},{"label":"C","value":"Ec = mgh"},{"label":"D","value":"Ec = mv"}]',
    'B', 'Ec = ½mv² est la formule classique de l''énergie cinétique.', 2
  );
