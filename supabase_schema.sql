-- ============================================
-- NABIH - Smart University Assistant
-- Supabase Database Schema
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

-- 2. EVENTS
CREATE TABLE IF NOT EXISTS public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  date DATE NOT NULL,
  time TEXT NOT NULL,
  location TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'Academic',
  organizer TEXT NOT NULL,
  created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. ANNOUNCEMENTS
CREATE TABLE IF NOT EXISTS public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author TEXT NOT NULL,
  target TEXT NOT NULL DEFAULT 'All',
  is_pinned BOOLEAN DEFAULT false,
  created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. SCHEDULES (class sessions)
CREATE TABLE IF NOT EXISTS public.schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  course_name TEXT NOT NULL,
  course_code TEXT NOT NULL,
  instructor TEXT NOT NULL,
  room TEXT NOT NULL,
  day_of_week INT NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  credit_hours INT NOT NULL DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  sender_name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'general' CHECK (type IN ('class', 'announcement', 'event', 'general')),
  target_role TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. NOTIFICATION READS (tracks which user read which notification)
CREATE TABLE IF NOT EXISTS public.notification_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(notification_id, user_id)
);

-- 7. GPA RECORDS
CREATE TABLE IF NOT EXISTS public.gpa_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  semester TEXT NOT NULL,
  courses JSONB NOT NULL DEFAULT '[]',
  gpa DOUBLE PRECISION NOT NULL DEFAULT 0,
  total_credits INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gpa_records ENABLE ROW LEVEL SECURITY;

-- PROFILES: users can read all profiles, update own
CREATE POLICY "Anyone can view profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- EVENTS: anyone can read, faculty/staff can create
CREATE POLICY "Anyone can view events" ON public.events FOR SELECT USING (true);
CREATE POLICY "Authenticated can create events" ON public.events FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Creator can update events" ON public.events FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Creator can delete events" ON public.events FOR DELETE USING (auth.uid() = created_by);

-- ANNOUNCEMENTS: anyone can read, staff can create
CREATE POLICY "Anyone can view announcements" ON public.announcements FOR SELECT USING (true);
CREATE POLICY "Authenticated can create announcements" ON public.announcements FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Creator can update announcements" ON public.announcements FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Creator can delete announcements" ON public.announcements FOR DELETE USING (auth.uid() = created_by);

-- SCHEDULES: users can CRUD own schedules
CREATE POLICY "Users can view own schedules" ON public.schedules FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own schedules" ON public.schedules FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own schedules" ON public.schedules FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own schedules" ON public.schedules FOR DELETE USING (auth.uid() = user_id);

-- NOTIFICATIONS: anyone authenticated can read, faculty can create
CREATE POLICY "Authenticated can view notifications" ON public.notifications FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated can create notifications" ON public.notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- NOTIFICATION READS: users can CRUD own
CREATE POLICY "Users can view own reads" ON public.notification_reads FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can mark as read" ON public.notification_reads FOR INSERT WITH CHECK (auth.uid() = user_id);

-- GPA RECORDS: users can CRUD own
CREATE POLICY "Users can view own gpa" ON public.gpa_records FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own gpa" ON public.gpa_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own gpa" ON public.gpa_records FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own gpa" ON public.gpa_records FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- AUTO-CREATE PROFILE ON SIGNUP (trigger)
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_role TEXT;
  user_name TEXT;
BEGIN
  -- Determine role from email
  IF NEW.email ~ '^s[0-9]+@uqu\.edu\.sa$' THEN
    user_role := 'student';
  ELSIF NEW.email ~ '^staff\..+@uqu\.edu\.sa$' THEN
    user_role := 'staff';
  ELSIF NEW.email LIKE '%@uqu.edu.sa' THEN
    user_role := 'faculty';
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
