-- ============================================
-- NABIH v2 (Preview) - Smart University Assistant
-- Supabase Database Schema
--
-- ACTIVE in this version:
--   FR_001 - Registration & Login  → auth.users (Supabase Auth) + public.profiles
--   FR_002 - Campus Navigation     → no DB table required (client-side data)
--   FR_003 - User Profile          → public.profiles
--
-- COMING SOON (tables commented out):
--   events, announcements, schedules, notifications, gpa_records
-- ============================================

-- 1. PROFILES (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'visitor' CHECK (role IN ('student', 'faculty', 'staff', 'visitor')),
  department TEXT,
  student_id TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- PROFILES: authenticated users can read all profiles, insert/update own
CREATE POLICY "Authenticated users can view profiles" ON public.profiles FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- ============================================
-- AUTO-CREATE PROFILE ON SIGNUP (trigger)
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_role TEXT;
  user_name TEXT;
BEGIN
  -- Determine role from email (case-insensitive).
  -- For @uqu.edu.sa non-student emails, faculty/staff cannot be distinguished
  -- from email alone — the Flutter app lets the user choose and overwrites this
  -- via a profiles upsert after OTP verification.
  IF lower(NEW.email) ~ '^s[0-9]+@uqu\.edu\.sa$' THEN
    user_role := 'student';
  ELSIF lower(NEW.email) LIKE '%@uqu.edu.sa' THEN
    user_role := 'faculty'; -- temporary default; corrected by app upsert
  ELSE
    user_role := 'visitor';
  END IF;

  -- Extract name from metadata or email
  user_name := COALESCE(
    NEW.raw_user_meta_data->>'name',
    split_part(NEW.email, '@', 1)
  );

  INSERT INTO public.profiles (id, name, email, role)
  VALUES (NEW.id, user_name, NEW.email, user_role)
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================