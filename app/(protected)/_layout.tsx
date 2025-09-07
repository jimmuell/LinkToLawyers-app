import { Stack } from "expo-router";

export default function ProtectedLayout() {
	return (
		<Stack
			screenOptions={{
				headerShown: false,
			}}
		>
			<Stack.Screen name="(tabs)" />
			<Stack.Screen name="modal" options={{ presentation: "modal" }} />
			<Stack.Screen 
				name="profile-modal" 
				options={{ 
					presentation: "modal",
					headerShown: true,
					headerTitle: "Profile"
				}} 
			/>
			<Stack.Screen 
				name="notifications-modal" 
				options={{ 
					presentation: "modal",
					headerShown: true,
					headerTitle: "Notifications"
				}} 
			/>
			<Stack.Screen 
				name="add-modal" 
				options={{ 
					presentation: "modal",
					headerShown: true,
					headerTitle: "Add"
				}} 
			/>
			<Stack.Screen 
				name="settings-modal" 
				options={{ 
					presentation: "modal",
					headerShown: true,
					headerTitle: "Settings"
				}} 
			/>
		</Stack>
	);
}
