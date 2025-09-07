import {
	createContext,
	PropsWithChildren,
	useContext,
	useEffect,
	useState,
} from "react";

import { Session } from "@supabase/supabase-js";

import { supabase } from "@/config/supabase";
import type { UserRole } from "@/lib/database.utils";

type AuthState = {
	initialized: boolean;
	session: Session | null;
	signUp: (
		email: string,
		password: string,
		fullName?: string,
		role?: UserRole,
	) => Promise<void>;
	signIn: (email: string, password: string) => Promise<void>;
	signOut: () => Promise<void>;
};

export const AuthContext = createContext<AuthState>({
	initialized: false,
	session: null,
	signUp: async () => {},
	signIn: async () => {},
	signOut: async () => {},
});

export const useAuth = () => useContext(AuthContext);

export function AuthProvider({ children }: PropsWithChildren) {
	const [initialized, setInitialized] = useState(false);
	const [session, setSession] = useState<Session | null>(null);

	const signUp = async (
		email: string,
		password: string,
		fullName?: string,
		role: UserRole = "client",
	) => {
		// Parse the full name into first and last name
		const nameParts = fullName?.trim().split(/\s+/) || [];
		const firstName = nameParts[0] || "";
		const lastName = nameParts.slice(1).join(" ") || "";

		const userData = {
			role: role,
			full_name: fullName || "",
			first_name: firstName,
			last_name: lastName,
			display_name: fullName || "", // This will be stored in raw_user_meta_data
		};
		
		console.log('Supabase signUp - sending user data:', userData);

		const { data, error } = await supabase.auth.signUp({
			email,
			password,
			options: {
				data: userData,
			},
		});

		if (error) {
			console.error("Error signing up:", error);
			return;
		}

		if (data.session) {
			setSession(data.session);
			console.log("User signed up:", data.user);
		} else {
			console.log("No user returned from sign up");
		}
	};

	const signIn = async (email: string, password: string) => {
		const { data, error } = await supabase.auth.signInWithPassword({
			email,
			password,
		});

		if (error) {
			console.error("Error signing in:", error);
			return;
		}

		if (data.session) {
			setSession(data.session);
			console.log("User signed in:", data.user);
		} else {
			console.log("No user returned from sign in");
		}
	};

	const signOut = async () => {
		const { error } = await supabase.auth.signOut();

		if (error) {
			console.error("Error signing out:", error);
			return;
		} else {
			console.log("User signed out");
		}
	};

	useEffect(() => {
		supabase.auth.getSession().then(({ data: { session } }) => {
			setSession(session);
		});

		supabase.auth.onAuthStateChange((_event, session) => {
			setSession(session);
		});

		setInitialized(true);
	}, []);

	return (
		<AuthContext.Provider
			value={{
				initialized,
				session,
				signUp,
				signIn,
				signOut,
			}}
		>
			{children}
		</AuthContext.Provider>
	);
}
