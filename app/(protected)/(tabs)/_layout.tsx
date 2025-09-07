import React from "react";
import { Tabs, useRouter } from "expo-router";
import { View, Pressable } from "react-native";
import { Ionicons } from "@expo/vector-icons";

import { useColorScheme } from "@/lib/useColorScheme";
import { colors } from "@/constants/colors";

export default function TabsLayout() {
	const { colorScheme } = useColorScheme();
	const router = useRouter();
	
	const iconColor = colorScheme === "dark" ? colors.dark.foreground : colors.light.foreground;
	const backgroundColor = colorScheme === "dark" ? colors.dark.background : colors.light.background;

	// Header icon component with circular background
	const HeaderIcon = ({ iconName, onPress }: { iconName: any; onPress?: () => void }) => (
		<Pressable
			onPress={onPress}
			className="w-10 h-10 rounded-full border border-gray-300 items-center justify-center"
			style={{ backgroundColor: backgroundColor }}
		>
			<Ionicons name={iconName} size={20} color={iconColor} />
		</Pressable>
	);

	return (
		<Tabs
			screenOptions={{
				headerShown: true,
				headerStyle: {
					backgroundColor:
						colorScheme === "dark"
							? colors.dark.background
							: colors.light.background,
				},
				headerTintColor:
					colorScheme === "dark"
						? colors.dark.foreground
						: colors.light.foreground,
				tabBarStyle: {
					backgroundColor: colorScheme === "dark" ? "#1a1a1a" : "#ffffff",
					borderTopWidth: 1,
					borderTopColor: colorScheme === "dark" ? "#333333" : "#e5e5e5",
					paddingBottom: 25,
					paddingTop: 8,
					height: 85,
				},
				tabBarActiveTintColor: "#007AFF",
				tabBarInactiveTintColor: colorScheme === "dark" ? "rgba(255, 255, 255, 0.5)" : "rgba(0, 0, 0, 0.5)",
				tabBarShowLabel: true,
				tabBarLabelStyle: {
					fontSize: 12,
					fontWeight: "500",
					marginBottom: 2,
				},
			}}
		>
			<Tabs.Screen 
				name="index" 
				options={{ 
					title: "Home",
					headerTitle: "Home",
					headerLeft: () => (
						<View className="ml-4">
							<HeaderIcon 
								iconName="person" 
								onPress={() => {
									router.push("/(protected)/profile-modal");
								}} 
							/>
						</View>
					),
					headerRight: () => (
						<View className="flex-row gap-3 mr-4">
							<HeaderIcon 
								iconName="notifications" 
								onPress={() => {
									router.push("/(protected)/notifications-modal");
								}} 
							/>
							<HeaderIcon 
								iconName="add" 
								onPress={() => {
									router.push("/(protected)/add-modal");
								}} 
							/>
							<HeaderIcon 
								iconName="settings" 
								onPress={() => {
									router.push("/(protected)/settings-modal");
								}} 
							/>
						</View>
					),
					tabBarIcon: ({ color, size }) => (
						<Ionicons name="home" size={size} color={color} />
					),
				}} 
			/>
			<Tabs.Screen 
				name="requests" 
				options={{ 
					title: "Requests",
					headerTitle: "Requests", 
					tabBarIcon: ({ color, size }) => (
						<Ionicons name="document-text" size={size} color={color} />
					),
				}} 
			/>
			<Tabs.Screen 
				name="help" 
				options={{ 
					title: "Help",
					headerTitle: "Help",
					tabBarIcon: ({ color, size }) => (
						<Ionicons name="help-circle" size={size} color={color} />
					),
				}} 
			/>
		</Tabs>
	);
}
