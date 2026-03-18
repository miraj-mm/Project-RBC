-- Make email column UNIQUE in users table to prevent duplicates at database level
-- Run this in your Supabase SQL Editor

-- First, remove any existing duplicate emails (if any)
-- This will keep only the first occurrence of each email
DELETE FROM users a
USING users b
WHERE a.id > b.id 
AND a.email = b.email;

-- Add UNIQUE constraint to email column
ALTER TABLE users 
ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Create index on email for faster lookups (if not already exists)
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Verify the constraint was added
SELECT
    conname AS constraint_name,
    contype AS constraint_type
FROM pg_constraint
WHERE conrelid = 'users'::regclass
AND conname = 'users_email_unique';
