/**
 * Questions Management Screen — View, search, filter questions
 * Fetches from FastAPI backend (Python)
 */
import React, { useState, useEffect } from 'react';
import {
  View, Text, FlatList, StyleSheet, TextInput,
  TouchableOpacity, ActivityIndicator, Alert,
} from 'react-native';
import { getSubjects, getQuestions } from '../services/api';

export default function QuestionsScreen() {
  const [subjects, setSubjects] = useState([]);
  const [questions, setQuestions] = useState([]);
  const [selectedSubject, setSelectedSubject] = useState(null);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadSubjects();
  }, []);

  const loadSubjects = async () => {
    try {
      const res = await getSubjects();
      setSubjects(res.data);
    } catch (_) {
      // Fallback subjects
      setSubjects([
        { slug: 'math', name: 'Mathématiques' },
        { slug: 'physics', name: 'Physique' },
        { slug: 'chemistry', name: 'Chimie' },
        { slug: 'general', name: 'Culture Générale' },
      ]);
    }
    setLoading(false);
  };

  const loadQuestions = async (slug) => {
    setSelectedSubject(slug);
    setLoading(true);
    try {
      const res = await getQuestions(slug);
      setQuestions(res.data);
    } catch (err) {
      Alert.alert('Erreur', 'Impossible de charger les questions');
      setQuestions([]);
    }
    setLoading(false);
  };

  const filtered = questions.filter((q) =>
    q.text?.toLowerCase().includes(search.toLowerCase())
  );

  const difficultyColor = (d) => {
    if (d <= 1) return '#4CAF50';
    if (d <= 2) return '#8BC34A';
    if (d <= 3) return '#FF9800';
    if (d <= 4) return '#FF5722';
    return '#F44336';
  };

  return (
    <View style={styles.container}>
      {/* Subject Tabs */}
      <View style={styles.tabs}>
        {subjects.map((s) => (
          <TouchableOpacity
            key={s.slug}
            style={[styles.tab, selectedSubject === s.slug && styles.tabActive]}
            onPress={() => loadQuestions(s.slug)}
          >
            <Text style={[styles.tabText, selectedSubject === s.slug && styles.tabTextActive]}>
              {s.name}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Search */}
      <TextInput
        style={styles.search}
        placeholder="🔍 Rechercher une question..."
        placeholderTextColor="#999"
        value={search}
        onChangeText={setSearch}
      />

      {/* Questions List */}
      {loading ? (
        <ActivityIndicator size="large" color="#3F51B5" style={{ marginTop: 40 }} />
      ) : selectedSubject ? (
        <FlatList
          data={filtered}
          keyExtractor={(item) => item.id}
          renderItem={({ item, index }) => (
            <View style={styles.questionCard}>
              <View style={styles.questionHeader}>
                <Text style={styles.questionNumber}>Q{index + 1}</Text>
                <View style={[styles.diffBadge, { backgroundColor: difficultyColor(item.difficulty) }]}>
                  <Text style={styles.diffText}>Niv.{item.difficulty}</Text>
                </View>
                {item.generated_by_ai && (
                  <View style={styles.aiBadge}>
                    <Text style={styles.aiText}>🤖 IA</Text>
                  </View>
                )}
              </View>
              <Text style={styles.questionText}>{item.text}</Text>
              <View style={styles.optionsRow}>
                {(item.options || []).map((opt, i) => (
                  <View
                    key={i}
                    style={[
                      styles.option,
                      opt.label === item.correct_answer && styles.optionCorrect,
                    ]}
                  >
                    <Text style={styles.optionText}>
                      {opt.label}: {opt.value}
                    </Text>
                  </View>
                ))}
              </View>
              {item.explanation && (
                <Text style={styles.explanation}>💡 {item.explanation}</Text>
              )}
              <View style={styles.statsRow}>
                <Text style={styles.statText}>
                  Affichée {item.times_shown || 0}x • Correct {item.times_correct || 0}x
                  {item.times_shown > 0 &&
                    ` (${Math.round((item.times_correct / item.times_shown) * 100)}%)`}
                </Text>
              </View>
            </View>
          )}
          ListEmptyComponent={
            <Text style={styles.emptyText}>Aucune question trouvée</Text>
          }
        />
      ) : (
        <View style={styles.placeholder}>
          <Text style={styles.placeholderIcon}>📚</Text>
          <Text style={styles.placeholderText}>Sélectionnez une matière</Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5' },
  tabs: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    padding: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  tab: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 8,
    marginHorizontal: 3,
  },
  tabActive: { backgroundColor: '#3F51B5' },
  tabText: { fontSize: 11, fontWeight: '600', color: '#666' },
  tabTextActive: { color: '#fff' },
  search: {
    margin: 12,
    backgroundColor: '#fff',
    padding: 14,
    borderRadius: 12,
    fontSize: 15,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  questionCard: {
    backgroundColor: '#fff',
    marginHorizontal: 12,
    marginBottom: 10,
    borderRadius: 14,
    padding: 16,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
  questionHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
  questionNumber: {
    fontSize: 13,
    fontWeight: '800',
    color: '#3F51B5',
    marginRight: 8,
  },
  diffBadge: { borderRadius: 6, paddingHorizontal: 8, paddingVertical: 2, marginRight: 6 },
  diffText: { color: '#fff', fontSize: 10, fontWeight: '700' },
  aiBadge: {
    backgroundColor: '#E8EAF6',
    borderRadius: 6,
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
  aiText: { fontSize: 10, fontWeight: '700', color: '#3F51B5' },
  questionText: { fontSize: 15, fontWeight: '600', color: '#333', marginBottom: 10 },
  optionsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  option: {
    backgroundColor: '#F5F5F5',
    borderRadius: 8,
    paddingHorizontal: 10,
    paddingVertical: 6,
    marginBottom: 4,
  },
  optionCorrect: { backgroundColor: '#C8E6C9', borderWidth: 1, borderColor: '#4CAF50' },
  optionText: { fontSize: 12, color: '#333' },
  explanation: { fontSize: 12, color: '#666', marginTop: 8, fontStyle: 'italic' },
  statsRow: { marginTop: 8, borderTopWidth: 1, borderTopColor: '#F0F0F0', paddingTop: 6 },
  statText: { fontSize: 11, color: '#999' },
  emptyText: { textAlign: 'center', color: '#999', marginTop: 40, fontSize: 15 },
  placeholder: { alignItems: 'center', marginTop: 80 },
  placeholderIcon: { fontSize: 50, marginBottom: 12 },
  placeholderText: { fontSize: 16, color: '#999' },
});
