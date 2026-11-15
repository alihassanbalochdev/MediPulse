import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medipulse_medical/app.dart';
import 'package:medipulse_medical/core/sync/sync_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline-first: use only the bundled Outfit files, never download
  GoogleFonts.config.allowRuntimeFetching = false;

  // No keys = local-only mode. The app works fully, just without cloud backup.
  if (isSupabaseConfigured) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
    }

  runApp(const ProviderScope(child: MediPulseApp()));
}
