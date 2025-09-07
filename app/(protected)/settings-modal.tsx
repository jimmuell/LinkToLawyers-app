import { View } from "react-native";

import { SafeAreaView } from "@/components/safe-area-view";
import { Button } from "@/components/ui/button";
import { Text } from "@/components/ui/text";
import { H1 } from "@/components/ui/typography";
import { useAuth } from "@/context/supabase-provider";

export default function SettingsModal() {
	const { signOut } = useAuth();

	return (
		<SafeAreaView className="flex-1 bg-background">
			<View className="flex-1 p-4">
				{/* Content Area */}
				<View className="flex-1 items-center justify-center">
					<H1 className="text-center text-foreground">Settings</H1>
				</View>
				
				{/* Bottom Button Area */}
				<View className="pb-4">
					<Button
						variant="destructive"
						size="default"
						onPress={async () => {
							await signOut();
						}}
						className="w-full"
					>
						<Text className="text-white font-semibold">Log out</Text>
					</Button>
				</View>
			</View>
		</SafeAreaView>
	);
}
