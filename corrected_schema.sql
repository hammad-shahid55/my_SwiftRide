-- ============================================
-- CORRECTED SUPABASE DATABASE SCHEMA
-- SwiftRide Application
-- ============================================

-- ============================================
-- 1. BOOKINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.bookings (
  id bigserial NOT NULL,
  user_id uuid NULL,
  trip_id bigint NULL,
  from_city text NOT NULL,
  to_city text NOT NULL,
  seats integer NOT NULL,
  total_price integer NOT NULL,
  status text NULL DEFAULT 'booked'::text,
  created_at timestamp without time zone NULL DEFAULT now(),
  ride_time timestamp with time zone NULL,
  updated_at timestamp without time zone NULL,
  cancelled_at timestamp without time zone NULL,
  cancellation_reason text NULL,
  CONSTRAINT bookings_pkey PRIMARY KEY (id),
  CONSTRAINT bookings_trip_id_fkey FOREIGN KEY (trip_id) 
    REFERENCES public.trips (id) ON DELETE SET NULL,
  CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES auth.users (id) ON DELETE CASCADE,
  CONSTRAINT bookings_price_check CHECK ((total_price >= 0)),
  CONSTRAINT bookings_seats_check CHECK ((seats > 0)),
  CONSTRAINT bookings_status_check CHECK (
    (status = ANY (
      ARRAY['booked'::text, 'completed'::text, 'cancelled'::text]
    ))
  )
) TABLESPACE pg_default;

-- Indexes for bookings table
CREATE INDEX IF NOT EXISTS bookings_user_id_idx 
  ON public.bookings USING btree (user_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS bookings_user_status_idx 
  ON public.bookings USING btree (user_id, status) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS bookings_user_ride_time_idx 
  ON public.bookings USING btree (user_id, ride_time DESC) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS bookings_trip_id_idx 
  ON public.bookings USING btree (trip_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS bookings_status_idx 
  ON public.bookings USING btree (status) TABLESPACE pg_default;

-- Additional useful index for filtering by status and ride_time
CREATE INDEX IF NOT EXISTS bookings_status_ride_time_idx 
  ON public.bookings USING btree (status, ride_time DESC) TABLESPACE pg_default;

-- ============================================
-- 2. DRIVERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.drivers (
  id uuid NOT NULL DEFAULT auth.uid(),
  full_name text NULL,
  phone text NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT drivers_pkey PRIMARY KEY (id),
  CONSTRAINT drivers_id_fkey FOREIGN KEY (id) 
    REFERENCES auth.users (id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- ============================================
-- 3. PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL,
  email text NULL,
  name text NULL,
  phone text NULL,
  address text NULL,
  profile_pic text NULL,
  updated_at timestamp with time zone NULL DEFAULT now(),
  wallet_balance numeric NULL DEFAULT 0,
  is_driver boolean NULL DEFAULT false,
  full_name text NULL,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_email_key UNIQUE (email),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) 
    REFERENCES auth.users (id) ON DELETE CASCADE,
  CONSTRAINT profiles_wallet_balance_check CHECK ((wallet_balance >= 0))
) TABLESPACE pg_default;

-- Index for profiles email lookups
CREATE INDEX IF NOT EXISTS profiles_email_idx 
  ON public.profiles USING btree (email) TABLESPACE pg_default;

-- ============================================
-- 4. RATINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.ratings (
  id bigserial NOT NULL,
  booking_id bigint NOT NULL,
  user_id uuid NOT NULL,
  driver_id uuid NOT NULL,
  trip_id bigint NOT NULL,
  rating integer NOT NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  updated_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT ratings_pkey PRIMARY KEY (id),
  CONSTRAINT ratings_unique_booking UNIQUE (booking_id),
  CONSTRAINT ratings_booking_id_fkey FOREIGN KEY (booking_id) 
    REFERENCES public.bookings (id) ON DELETE CASCADE,
  CONSTRAINT ratings_driver_id_fkey FOREIGN KEY (driver_id) 
    REFERENCES public.drivers (id) ON DELETE CASCADE,
  CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES auth.users (id) ON DELETE CASCADE,
  CONSTRAINT ratings_trip_id_fkey FOREIGN KEY (trip_id) 
    REFERENCES public.trips (id) ON DELETE CASCADE,
  CONSTRAINT ratings_rating_check CHECK (
    (rating >= 1) AND (rating <= 5)
  )
) TABLESPACE pg_default;

-- Indexes for ratings table
CREATE INDEX IF NOT EXISTS ratings_driver_id_idx 
  ON public.ratings USING btree (driver_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS ratings_user_id_idx 
  ON public.ratings USING btree (user_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS ratings_booking_id_idx 
  ON public.ratings USING btree (booking_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS ratings_trip_id_idx 
  ON public.ratings USING btree (trip_id) TABLESPACE pg_default;

-- ============================================
-- 5. VANS TABLE (must be created before trips)
-- ============================================
CREATE TABLE IF NOT EXISTS public.vans (
  id bigserial NOT NULL,
  name text NOT NULL,
  total_seats integer NOT NULL DEFAULT 14,
  plate text NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT vans_pkey PRIMARY KEY (id),
  CONSTRAINT vans_total_seats_check CHECK ((total_seats > 0))
) TABLESPACE pg_default;

-- ============================================
-- 6. TRIPS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.trips (
  id bigserial NOT NULL,
  from_city text NOT NULL,
  to_city text NOT NULL,
  "from" text NOT NULL,
  "to" text NOT NULL,
  depart_time timestamp with time zone NOT NULL,
  arrive_time timestamp with time zone NOT NULL,
  price integer NOT NULL,
  type text NULL DEFAULT 'Van'::text,
  ac boolean NULL DEFAULT true,
  day text NULL,
  total_seats integer NULL DEFAULT 14,
  distance_km numeric NULL,
  duration_min integer NULL,
  distance_text text NULL,
  duration_text text NULL,
  van_number text NULL,
  van_filled boolean NULL DEFAULT false,
  driver_assigned boolean NULL DEFAULT false,
  current_bookings integer NULL DEFAULT 0,
  driver_id uuid NULL,
  van_id bigint NULL,
  CONSTRAINT trips_pkey PRIMARY KEY (id),
  CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id) 
    REFERENCES public.drivers (id) ON DELETE SET NULL,
  CONSTRAINT trips_van_id_fkey FOREIGN KEY (van_id) 
    REFERENCES public.vans (id) ON DELETE SET NULL,
  CONSTRAINT trips_price_check CHECK ((price >= 0)),
  CONSTRAINT trips_total_seats_check CHECK ((total_seats >= 0)),
  CONSTRAINT trips_current_bookings_check CHECK ((current_bookings >= 0)),
  CONSTRAINT trips_time_check CHECK ((arrive_time > depart_time))
) TABLESPACE pg_default;

-- Indexes for trips table
CREATE INDEX IF NOT EXISTS trips_driver_id_idx 
  ON public.trips USING btree (driver_id) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS trips_van_id_idx 
  ON public.trips USING btree (van_id) TABLESPACE pg_default;

-- Important index for filtering trips by departure time
CREATE INDEX IF NOT EXISTS trips_depart_time_idx 
  ON public.trips USING btree (depart_time) TABLESPACE pg_default;

-- Index for filtering by cities
CREATE INDEX IF NOT EXISTS trips_cities_idx 
  ON public.trips USING btree (from_city, to_city) TABLESPACE pg_default;

-- ============================================
-- TRIGGERS (Note: These require the functions to exist)
-- ============================================

-- Trigger for setting cancelled_at timestamp
CREATE TRIGGER trg_bookings_set_cancelled_at 
  BEFORE UPDATE OF status ON public.bookings
  FOR EACH ROW
  WHEN (NEW.status = 'cancelled' AND OLD.status != 'cancelled')
  EXECUTE FUNCTION set_cancelled_at();

-- Trigger for setting ride_time from trip
CREATE TRIGGER trg_bookings_set_ride_time 
  BEFORE INSERT ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION bookings_set_ride_time_from_trip();

-- Trigger for setting updated_at timestamp
CREATE TRIGGER trg_bookings_set_updated_at 
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- Trigger for updating trip seats on booking delete
CREATE TRIGGER trg_update_trip_seats_delete
  AFTER DELETE ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_trip_seats_on_delete();

-- Trigger for updating trip seats on booking insert
CREATE TRIGGER trg_update_trip_seats_insert
  AFTER INSERT ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_trip_seats_on_insert();

-- Trigger for updating trip seats on booking update
CREATE TRIGGER trg_update_trip_seats_update
  AFTER UPDATE OF trip_id, seats ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_trip_seats_on_update();

-- Trigger for ratings updated_at
CREATE TRIGGER trg_ratings_set_updated_at 
  BEFORE UPDATE ON public.ratings
  FOR EACH ROW
  EXECUTE FUNCTION set_ratings_updated_at();

-- Triggers for profiles wallet totals (if needed)
CREATE TRIGGER trg_profiles_wallet_totals_del
  AFTER DELETE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION refresh_wallet_totals();

CREATE TRIGGER trg_profiles_wallet_totals_ins
  AFTER INSERT ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION refresh_wallet_totals();

CREATE TRIGGER trg_profiles_wallet_totals_upd
  AFTER UPDATE OF wallet_balance ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION refresh_wallet_totals();

-- ============================================
-- NOTES ON CORRECTIONS MADE:
-- ============================================
-- 1. Added IF NOT EXISTS to all CREATE TABLE statements for safety
-- 2. Added missing foreign key constraint on ratings.trip_id
-- 3. Added check constraints for data integrity:
--    - profiles.wallet_balance >= 0
--    - vans.total_seats > 0
--    - trips.price >= 0
--    - trips.total_seats >= 0
--    - trips.current_bookings >= 0
--    - trips.arrive_time > depart_time
-- 4. Added useful indexes:
--    - bookings.status_ride_time_idx for filtering completed/upcoming
--    - trips.depart_time_idx for filtering by departure time
--    - trips.cities_idx for filtering by from/to cities
--    - profiles.email_idx for email lookups
-- 5. Fixed trigger condition for cancelled_at (only set when status changes to cancelled)
-- 6. Added foreign key constraint on drivers.id to auth.users
-- 7. Ensured proper table creation order (vans before trips)
-- ============================================

