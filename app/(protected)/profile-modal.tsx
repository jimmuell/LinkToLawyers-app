import { View } from "react-native";

import { SafeAreaView } from "@/components/safe-area-view";
import { H1 } from "@/components/ui/typography";

export default function ProfileModal() {
	return (
		<SafeAreaView className="flex-1 bg-background">
			<View className="flex-1 items-center justify-center p-4">
				<H1 className="text-center text-foreground">Profile</H1>
			</View>
		</SafeAreaView>
	);
}
