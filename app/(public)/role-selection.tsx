import React, { useState } from "react";
import { View, Pressable } from "react-native";
import { useRouter } from "expo-router";
import { MaterialIcons, Ionicons } from "@expo/vector-icons";

import { SafeAreaView } from "@/components/safe-area-view";
import { Button } from "@/components/ui/button";
import { Text } from "@/components/ui/text";
import { H1, H3, Muted } from "@/components/ui/typography";
import type { UserRole } from "@/lib/database.utils";
import { useColorScheme } from "@/lib/useColorScheme";

// Role options with colors and vector icons
const roleOptions = [
	{
		value: "client" as const,
		label: "Client",
		description: "I need legal assistance and want to connect with attorneys",
		icon: { library: "Ionicons", name: "person-outline" },
		colors: {
			light: {
				background: "bg-blue-50",
				border: "border-blue-200",
				selectedBorder: "border-blue-500",
				iconColor: "#3b82f6",
				checkColor: "#10b981",
			},
			dark: {
				background: "bg-blue-950",
				border: "border-blue-800",
				selectedBorder: "border-blue-400",
				iconColor: "#60a5fa",
				checkColor: "#34d399",
			},
		},
	},
	{
		value: "attorney" as const,
		label: "Attorney",
		description: "I am a licensed attorney looking to connect with clients",
		icon: { library: "MaterialIcons", name: "balance" },
		colors: {
			light: {
				background: "bg-emerald-50",
				border: "border-emerald-200",
				selectedBorder: "border-emerald-500",
				iconColor: "#10b981",
				checkColor: "#10b981",
			},
			dark: {
				background: "bg-emerald-950",
				border: "border-emerald-800",
				selectedBorder: "border-emerald-400",
				iconColor: "#34d399",
				checkColor: "#34d399",
			},
		},
	},
	{
		value: "admin" as const,
		label: "Administrator",
		description: "Platform administrator (invitation only)",
		icon: { library: "MaterialIcons", name: "admin-panel-settings" },
		colors: {
			light: {
				background: "bg-purple-50",
				border: "border-purple-200",
				selectedBorder: "border-purple-500",
				iconColor: "#8b5cf6",
				checkColor: "#10b981",
			},
			dark: {
				background: "bg-purple-950",
				border: "border-purple-800",
				selectedBorder: "border-purple-400",
				iconColor: "#a78bfa",
				checkColor: "#34d399",
			},
		},
	},
];

export default function RoleSelection() {
	const router = useRouter();
	const { colorScheme } = useColorScheme();
	const [selectedRole, setSelectedRole] = useState<UserRole | null>(null);

	const handleRoleSelect = (role: UserRole) => {
		setSelectedRole(role);
	};

	const handleContinue = () => {
		if (selectedRole) {
			router.push({
				pathname: "/sign-up",
				params: { role: selectedRole },
			});
		}
	};

	return (
		<SafeAreaView className="flex-1 bg-background p-4" edges={["bottom"]}>
			<View className="flex-1 gap-6">
				{/* Header */}
				<View className="items-center gap-2 pt-8">
					<H1 className="text-center">Choose Your Role</H1>
					<Muted className="text-center text-base">
						Select how you&apos;d like to use LinkToLawyers
					</Muted>
				</View>

				{/* Role Cards */}
				<View className="flex-1 gap-4 py-4">
					{roleOptions.map((option) => {
						const isSelected = selectedRole === option.value;
						const colors = option.colors[colorScheme || "light"];

						return (
							<Pressable
								key={option.value}
								onPress={() => handleRoleSelect(option.value)}
								className={`
									relative p-6 rounded-xl border-2 transition-all
									${colors.background}
									${isSelected ? colors.selectedBorder : colors.border}
								`}
								style={{
									shadowColor: isSelected ? "#000" : "#000",
									shadowOffset: {
										width: 0,
										height: isSelected ? 4 : 2,
									},
									shadowOpacity: isSelected ? 0.3 : 0.1,
									shadowRadius: isSelected ? 8 : 4,
									elevation: isSelected ? 8 : 4,
								}}
							>
								{/* Checkbox */}
								{isSelected && (
									<View className="absolute top-4 right-4">
										<View
											className="w-6 h-6 rounded-full items-center justify-center"
											style={{ backgroundColor: colors.checkColor }}
										>
											<Ionicons name="checkmark" size={16} color="white" />
										</View>
									</View>
								)}

								{/* Content */}
								<View className="flex-row items-center gap-4">
									{/* Icon */}
									<View className="items-center justify-center">
										{option.icon.library === "Ionicons" ? (
											<Ionicons
												name={option.icon.name as any}
												size={32}
												color={colors.iconColor}
											/>
										) : (
											<MaterialIcons
												name={option.icon.name as any}
												size={32}
												color={colors.iconColor}
											/>
										)}
									</View>

									{/* Text Content */}
									<View className="flex-1 gap-2">
										<H3 className="text-foreground font-semibold">
											{option.label}
										</H3>
										<Text className="text-muted-foreground text-base leading-relaxed">
											{option.description}
										</Text>
									</View>
								</View>
							</Pressable>
						);
					})}
				</View>

				{/* Continue Button */}
				<Button
					size="default"
					variant="default"
					onPress={handleContinue}
					disabled={!selectedRole}
					className="mt-4"
				>
					<Text>Continue</Text>
				</Button>
			</View>
		</SafeAreaView>
	);
}
