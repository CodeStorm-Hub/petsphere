/// Escapes PostgreSQL ILIKE/LIKE special chars for PostgREST filters (% _ \).
/// Clamps length to reduce accidental expensive scans.
String escapeIlikePattern(String raw) {
  var q = raw.trim();
  if (q.length > 120) {
    q = q.substring(0, 120);
  }
  return q
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
