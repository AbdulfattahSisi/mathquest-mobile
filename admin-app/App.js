/**
 * MathQuest Admin Dashboard — React Native (Expo)
 * ────────────────────────────────────────────────
 * Admin companion app for managing the MathQuest platform.
 * Tech: React Native + React Navigation + Axios + Chart Kit
 *
 * Features:
 *  • Dashboard with KPIs (users, duels, accuracy)
 *  • Question management (CRUD)
 *  • User management & analytics
 *  • Real-time stats from Node.js analytics service
 */

import React, { useState, useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import AsyncStorage from '@react-native-async-storage/async-storage';

import DashboardScreen from './src/screens/DashboardScreen';
import QuestionsScreen from './src/screens/QuestionsScreen';
import UsersScreen from './src/screens/UsersScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import LoginScreen from './src/screens/LoginScreen';

const Tab = createBottomTabNavigator();

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    const token = await AsyncStorage.getItem('admin_token');
    setIsLoggedIn(!!token);
    setLoading(false);
  };

  if (loading) return null;

  if (!isLoggedIn) {
    return (
      <>
        <StatusBar style="light" />
        <LoginScreen onLogin={() => setIsLoggedIn(true)} />
      </>
    );
  }

  return (
    <>
      <StatusBar style="light" />
      <NavigationContainer>
        <Tab.Navigator
          screenOptions={{
            headerStyle: { backgroundColor: '#1A237E' },
            headerTintColor: '#fff',
            tabBarActiveTintColor: '#3F51B5',
            tabBarInactiveTintColor: '#999',
            tabBarStyle: { paddingBottom: 5, height: 60 },
          }}
        >
          <Tab.Screen
            name="Dashboard"
            component={DashboardScreen}
            options={{
              title: '📊 Dashboard',
              tabBarLabel: 'Dashboard',
            }}
          />
          <Tab.Screen
            name="Questions"
            component={QuestionsScreen}
            options={{
              title: '❓ Questions',
              tabBarLabel: 'Questions',
            }}
          />
          <Tab.Screen
            name="Users"
            component={UsersScreen}
            options={{
              title: '👥 Utilisateurs',
              tabBarLabel: 'Users',
            }}
          />
          <Tab.Screen
            name="Settings"
            options={{
              title: '⚙️ Paramètres',
              tabBarLabel: 'Settings',
            }}
          >
            {() => (
              <SettingsScreen
                onLogout={() => {
                  AsyncStorage.removeItem('admin_token');
                  setIsLoggedIn(false);
                }}
              />
            )}
          </Tab.Screen>
        </Tab.Navigator>
      </NavigationContainer>
    </>
  );
}
