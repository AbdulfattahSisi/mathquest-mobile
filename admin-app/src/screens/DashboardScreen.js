/**
 * Admin Dashboard Screen — KPIs, Charts, Real-Time Stats
 * Fetches data from both FastAPI (backend) and Node.js (analytics)
 */
import React, { useState, useEffect, useCallback } from 'react';
import {
  View, Text, ScrollView, StyleSheet,
  RefreshControl, Dimensions, ActivityIndicator,
} from 'react-native';
import { LineChart, BarChart } from 'react-native-chart-kit';
import { getAnalyticsOverview, getDailyAnalytics, getPerformanceAnalytics } from '../services/api';

const screenWidth = Dimensions.get('window').width - 40;

export default function DashboardScreen() {
  const [overview, setOverview] = useState(null);
  const [dailyData, setDailyData] = useState(null);
  const [performance, setPerformance] = useState(null);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    try {
      const [ov, daily, perf] = await Promise.all([
        getAnalyticsOverview(),
        getDailyAnalytics(),
        getPerformanceAnalytics(),
      ]);
      setOverview(ov.data);
      setDailyData(daily.data);
      setPerformance(perf.data);
    } catch (err) {
      console.log('Dashboard fetch error:', err.message);
      // Use fallback data for demo
      setOverview({ totalUsers: 0, totalDuels: 0, totalQuestions: 100, averageScore: '0' });
    }
    setLoading(false);
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchData();
    setRefreshing(false);
  };

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#3F51B5" />
      </View>
    );
  }

  const kpis = [
    { label: 'Utilisateurs', value: overview?.totalUsers ?? 0, icon: '👥', color: '#4CAF50' },
    { label: 'Duels joués', value: overview?.totalDuels ?? 0, icon: '⚔️', color: '#FF9800' },
    { label: 'Questions', value: overview?.totalQuestions ?? 0, icon: '❓', color: '#2196F3' },
    { label: 'Score moyen', value: overview?.averageScore ?? '0', icon: '📈', color: '#9C27B0' },
  ];

  // Build chart data from daily analytics
  const chartLabels = dailyData?.data?.slice(0, 7).reverse().map(
    (d) => new Date(d.date).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' })
  ) || ['--'];
  const chartValues = dailyData?.data?.slice(0, 7).reverse().map((d) => d.activeUsers) || [0];

  const perfLabels = performance?.subjects?.map((s) => s.slug) || ['--'];
  const perfValues = performance?.subjects?.map((s) => parseFloat(s.avgAccuracy)) || [0];

  return (
    <ScrollView
      style={styles.container}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
    >
      {/* KPI Cards */}
      <View style={styles.kpiRow}>
        {kpis.map((kpi, i) => (
          <View key={i} style={[styles.kpiCard, { borderLeftColor: kpi.color }]}>
            <Text style={styles.kpiIcon}>{kpi.icon}</Text>
            <Text style={styles.kpiValue}>{kpi.value}</Text>
            <Text style={styles.kpiLabel}>{kpi.label}</Text>
          </View>
        ))}
      </View>

      {/* DAU Line Chart */}
      <View style={styles.chartCard}>
        <Text style={styles.chartTitle}>📊 Utilisateurs actifs (7 derniers jours)</Text>
        <LineChart
          data={{
            labels: chartLabels,
            datasets: [{ data: chartValues.length > 0 ? chartValues : [0] }],
          }}
          width={screenWidth}
          height={200}
          chartConfig={chartConfig}
          bezier
          style={styles.chart}
        />
      </View>

      {/* Performance Bar Chart */}
      <View style={styles.chartCard}>
        <Text style={styles.chartTitle}>🎯 Précision moyenne par matière (%)</Text>
        <BarChart
          data={{
            labels: perfLabels,
            datasets: [{ data: perfValues.length > 0 ? perfValues : [0] }],
          }}
          width={screenWidth}
          height={200}
          chartConfig={barChartConfig}
          style={styles.chart}
          showValuesOnTopOfBars
        />
      </View>

      {/* Tech Stack Footer */}
      <View style={styles.techBadge}>
        <Text style={styles.techText}>
          React Native • Node.js/Express • FastAPI • PostgreSQL • AI/ML
        </Text>
      </View>

      <View style={{ height: 30 }} />
    </ScrollView>
  );
}

const chartConfig = {
  backgroundGradientFrom: '#1E1E2E',
  backgroundGradientTo: '#2A2A3E',
  decimalPlaces: 0,
  color: (opacity = 1) => `rgba(63, 81, 181, ${opacity})`,
  labelColor: () => '#999',
  propsForDots: { r: '4', strokeWidth: '2', stroke: '#3F51B5' },
};

const barChartConfig = {
  ...chartConfig,
  color: (opacity = 1) => `rgba(76, 175, 80, ${opacity})`,
  barPercentage: 0.6,
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5', padding: 16 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  kpiRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  kpiCard: {
    width: '48%',
    backgroundColor: '#fff',
    borderRadius: 14,
    padding: 16,
    marginBottom: 12,
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOpacity: 0.06,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 3 },
    elevation: 3,
  },
  kpiIcon: { fontSize: 22, marginBottom: 6 },
  kpiValue: { fontSize: 26, fontWeight: '900', color: '#1A237E' },
  kpiLabel: { fontSize: 12, color: '#666', marginTop: 2 },
  chartCard: {
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOpacity: 0.06,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 3 },
    elevation: 3,
  },
  chartTitle: { fontSize: 15, fontWeight: '700', marginBottom: 12, color: '#333' },
  chart: { borderRadius: 12 },
  techBadge: {
    backgroundColor: '#1A237E',
    borderRadius: 12,
    padding: 12,
    alignItems: 'center',
  },
  techText: { color: '#fff', fontSize: 11, fontWeight: '600' },
});
