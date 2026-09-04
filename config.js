// Supabase connection for the punch list.
// The anon key is a public, publishable key — it is meant to ship in client code.
// What it can do is controlled entirely by the Row Level Security policies in schema.sql.
window.PUNCHLIST_CONFIG = {
  url:     "https://YOUR-PROJECT.supabase.co",
  anonKey: "YOUR-ANON-KEY"
};
