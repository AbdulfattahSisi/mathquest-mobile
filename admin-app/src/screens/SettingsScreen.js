/**
 * Admin Settings Screen — Logout, broadcast, about
 */
import React, { useState } from 'react';
import {
  View, Text, ScrollView, StyleSheet,
  TouchableOpacity, TextInput, Alert,
} from 'react-native';
import { broadcastNotification } from '../services/api';

export default function SettingsScreen({ onLogout }) {
  const [broadcastTitle, setBroadcastTitle] = useState('');
  const [broadcastMsg, setBroadcastMsg] = useState('');

  const handleBroadcast = async () => {
    if (!broadcastTitle || !broadcastMsg) {
      Alert.alert('Erreur', 'Titre et message requis');
      return;
    }
    try {
      await broadcastNotification(broadcastTitle, broadcastMsg);
      Alert.alert('✅', 'Broadcast envoyé à tous les utilisateurs connectés');
      setBroadcastTitle('');
      setBroadcastMsg('');
    } catch (_) {
      Alert.alert('Erreur', 'Échec du broadcast');
    }
  };

  return (
    <ScrollView style={styles.container}>
      {/* Broadcast Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>📢 Diffusion globale</Text>
        <Text style={styles.sectionDesc}>
          Envoyer un message à tous les utilisateurs connectés via WebSocket
        </Text>
        <TextInput
          style={styles.input}
          placeholder="Titre"
          placeholderTextColor="#999"
          value={broadcastTitle}
          onChangeText={setBroadcastTitle}
        />
        <TextInput
          style={[styles.input, { height: 80 }]}
          placeholder="Message"
          placeholderTextColor="#999"
          value={broadcastMsg}
          onChangeText={setBroadcastMsg}
          multiline
        />
        <TouchableOpacity style={styles.broadcastBtn} onPress={handleBroadcast}>
          <Text style={styles.broadcastBtnText}>Envoyer le broadcast</Text>
        </TouchableOpacity>
      </View>

      {/* Tech Stack */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🛠️ Stack Technique</Text>
        {[
          { label: 'Admin App', value: 'React Native (Expo)', icon: '📱' },
          { label: 'Mobile App', value: 'Flutter / Dart', icon: '💙' },
          { label: 'Backend API', value: 'Python FastAPI', icon: '🐍' },
          { label: 'Analytics', value: 'Node.js / Express', icon: '🟢' },
          { label: 'Base de données', value: 'PostgreSQL', icon: '🐘' },
          { label: 'Communication', value: 'API REST + WebSocket', icon: '🔗' },
          { label: 'IA / ML', value: 'scikit-learn + OpenAI GPT', icon: '🤖' },
          { label: 'DevOps', value: 'Docker / Docker Compose', icon: '🐳' },
        ].map((tech, i) => (
          <View key={i} style={styles.techRow}>
            <Text style={styles.techIcon}>{tech.icon}</Text>
            <View>
              <Text style={styles.techLabel}>{tech.label}</Text>
              <Text style={styles.techValue}>{tech.value}</Text>
            </View>
          </View>
        ))}
      </View>

      {/* About */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>ℹ️ À propos</Text>
        <Text style={styles.aboutText}>
          MathQuest Admin v1.0.0{'\n'}
          Tableau de bord d'administration pour la plateforme MathQuest.{'\n\n'}
          Projet AE — Application Éducative{'\n'}
          Stage OCP Khouribga
        </Text>
      </View>

      {/* Logout */}
      <TouchableOpacity style={styles.logoutBtn} onPress={onLogout}>
        <Text style={styles.logoutText}>🚪 Se déconnecter</Text>
      </TouchableOpacity>

      <View style={{ height: 40 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5', padding: 16 },
  section: {
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 18,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: 2,
  },
  sectionTitle: { fontSize: 17, fontWeight: '800', color: '#333', marginBottom: 6 },
  sectionDesc: { fontSize: 13, color: '#777', marginBottom: 12 },
  input: {
    backgroundColor: '#F5F5F5',
    padding: 14,
    borderRadius: 12,
    fontSize: 15,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  broadcastBtn: {
    backgroundColor: '#FF9800',
    padding: 14,
    borderRadius: 12,
    alignItems: 'center',
  },
  broadcastBtnText: { color: '#fff', fontWeight: '700', fontSize: 15 },
  techRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  techIcon: { fontSize: 22, marginRight: 14, width: 30 },
  techLabel: { fontSize: 13, fontWeight: '700', color: '#333' },
  techValue: { fontSize: 12, color: '#777' },
  aboutText: { fontSize: 13, color: '#666', lineHeight: 20 },
  logoutBtn: {
    backgroundColor: '#F44336',
    padding: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginBottom: 10,
  },
  logoutText: { color: '#fff', fontWeight: '800', fontSize: 16 },
});
