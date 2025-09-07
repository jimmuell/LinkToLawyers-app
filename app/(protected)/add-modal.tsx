import { View } from "react-native";

import { SafeAreaView } from "@/components/safe-area-view";
import { H1 } from "@/components/ui/typography";

export default function AddModal() {
	return (
		<SafeAreaView className="flex-1 bg-background">
			<View className="flex-1 items-center justify-center p-4">
				<H1 className="text-center text-foreground">Add</H1>
			</View>
		</SafeAreaView>
	);
}
