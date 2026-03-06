/**
 * Users Management Screen — View all users, stats, send notifications
 */
import React, { useState, useEffect } from 'react';
import {
  View, Text, FlatList, StyleSheet,
  TouchableOpacity, ActivityIndicator, Alert, TextInput,
} from 'react-native';
import { getLiveLeaderboard, sendNotification } from '../services/api';

export default function UsersScreen() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      const res = await getLiveLeaderboard();
      setUsers(res.data.leaderboard || []);
    } catch (_) {
      setUsers([]);
    }
    setLoading(false);
  };

  const handleNotify = (user) => {
    Alert.prompt
      ? Alert.prompt(
          `Notifier ${user.username}`,
          'Message :',
          async (message) => {
            if (message) {
              try {
                await sendNotification(user.id, 'Message Admin', message);
                Alert.alert('✅', 'Notification envoyée');
              } catch (_) {
                Alert.alert('Erreur', 'Échec de l\'envoi');
              }
            }
          }
        )
      : Alert.alert('Notification', `Envoyer une notification à ${user.username}`);
  };

  const filtered = users.filter((u) =>
    u.username?.toLowerCase().includes(search.toLowerCase())
  );

  const podiumColors = ['#FFD700', '#C0C0C0', '#CD7F32'];

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#3F51B5" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Stats Summary */}
      <View style={styles.summaryRow}>
        <View style={styles.summaryCard}>
          <Text style={styles.summaryValue}>{users.length}</Text>
          <Text style={styles.summaryLabel}>Joueurs</Text>
        </View>
        <View style={styles.summaryCard}>
          <Text style={styles.summaryValue}>
            {users.reduce((s, u) => s + (u.totalDuels || 0), 0)}
          </Text>
          <Text style={styles.summaryLabel}>Duels totaux</Text>
        </View>
        <View style={styles.summaryCard}>
          <Text style={styles.summaryValue}>
            {users.reduce((s, u) => s + (u.wins || 0), 0)}
          </Text>
          <Text style={styles.summaryLabel}>Victoires</Text>
        </View>
      </View>

      {/* Search */}
      <TextInput
        style={styles.search}
        placeholder="🔍 Rechercher un utilisateur..."
        placeholderTextColor="#999"
        value={search}
        onChangeText={setSearch}
      />

      {/* Users List */}
      <FlatList
        data={filtered}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View style={styles.userCard}>
            <View style={styles.rankBadge}>
              <Text style={[
                styles.rankText,
                item.rank <= 3 && { color: podiumColors[item.rank - 1] },
              ]}>
                #{item.rank}
              </Text>
            </View>
            <View style={styles.userInfo}>
              <Text style={styles.username}>{item.username}</Text>
              <Text style={styles.userMeta}>
                Niv.{item.level} • {item.totalPoints} pts • {item.wins}/{item.totalDuels} wins
                {item.streakDays > 0 ? ` • 🔥${item.streakDays}j` : ''}
              </Text>
            </View>
            <TouchableOpacity style={styles.notifyBtn} onPress={() => handleNotify(item)}>
              <Text style={styles.notifyText}>🔔</Text>
            </TouchableOpacity>
          </View>
        )}
        ListEmptyComponent={
          <Text style={styles.emptyText}>Aucun utilisateur</Text>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5' },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  summaryRow: {
    flexDirection: 'row',
    padding: 12,
    gap: 10,
  },
  summaryCard: {
    flex: 1,
    backgroundColor: '#1A237E',
    borderRadius: 14,
    padding: 16,
    alignItems: 'center',
  },
  summaryValue: { fontSize: 24, fontWeight: '900', color: '#fff' },
  summaryLabel: { fontSize: 11, color: '#B0BEC5', marginTop: 2 },
  search: {
    marginHorizontal: 12,
    marginBottom: 8,
    backgroundColor: '#fff',
    padding: 14,
    borderRadius: 12,
    fontSize: 15,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  userCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    marginHorizontal: 12,
    marginBottom: 8,
    borderRadius: 14,
    padding: 14,
    shadowColor: '#000',
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: 2,
  },
  rankBadge: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  rankText: { fontWeight: '900', fontSize: 15, color: '#333' },
  userInfo: { flex: 1 },
  username: { fontSize: 15, fontWeight: '700', color: '#333' },
  userMeta: { fontSize: 12, color: '#777', marginTop: 2 },
  notifyBtn: {
    width: 38,
    height: 38,
    borderRadius: 10,
    backgroundColor: '#E8EAF6',
    justifyContent: 'center',
    alignItems: 'center',
  },
  notifyText: { fontSize: 18 },
  emptyText: { textAlign: 'center', color: '#999', marginTop: 40, fontSize: 15 },
});
