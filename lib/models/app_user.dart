/// Decouples the app from `supabase_flutter`'s `User`, same reasoning as
/// `AppLocation`/`Place`.
class AppUser {
  const AppUser({required this.id, required this.email});

  final String id;
  final String? email;
}
