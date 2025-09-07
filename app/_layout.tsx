import "../global.css";

import { Stack } from "expo-router";
import * as SplashScreen from "expo-splash-screen";

import { AuthProvider, useAuth } from "@/context/supabase-provider";

// Disable Reanimated strict mode warnings by overriding console.warn
if (__DEV__) {
	const originalWarn = console.warn;
	console.warn = (...args) => {
		const message = args[0];
		if (
			typeof message === "string" &&
			(message.includes("[Reanimated]") ||
				message.includes("Reading from `value`") ||
				message.includes("Writing to `value`"))
		) {
			return; // Suppress Reanimated warnings
		}
		originalWarn.apply(console, args);
	};
}

SplashScreen.preventAutoHideAsync();

SplashScreen.setOptions({
	duration: 400,
	fade: true,
});

export default function RootLayout() {
	return (
		<AuthProvider>
			<RootNavigator />
		</AuthProvider>
	);
}

function RootNavigator() {
	const { initialized, session } = useAuth();

	if (!initialized) return;
	else {
		SplashScreen.hideAsync();
	}

	return (
		<Stack screenOptions={{ headerShown: false, gestureEnabled: false }}>
			<Stack.Protected guard={!!session}>
				<Stack.Screen name="(protected)" />
			</Stack.Protected>

			<Stack.Protected guard={!session}>
				<Stack.Screen name="(public)" />
			</Stack.Protected>
		</Stack>
	);
}
