-- ---------------------------------------------------------------------------
-- M3: Fix N+1 chat thread query.
--
-- The Flutter ChatRepository currently fires one extra `_fetchLastMessage`
-- query per thread. Replace with a single round trip via this RPC, which
-- joins the latest message per thread using a LATERAL subquery.
--
-- Returns rows shaped to match the existing `chat_threads.select(...)`
-- contract plus a `last_message` JSONB blob.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.fetch_chat_threads(my_pet_id UUID)
RETURNS TABLE (
  id UUID,
  pet_id_1 UUID,
  pet_id_2 UUID,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  pet1 JSONB,
  pet2 JSONB,
  last_message JSONB
)
LANGUAGE SQL
STABLE
SECURITY INVOKER
AS $$
  SELECT
    ct.id,
    ct.pet_id_1,
    ct.pet_id_2,
    ct.created_at,
    ct.updated_at,
    to_jsonb(p1) AS pet1,
    to_jsonb(p2) AS pet2,
    CASE
      WHEN lm.id IS NULL THEN NULL
      ELSE to_jsonb(lm)
    END AS last_message
  FROM public.chat_threads ct
  LEFT JOIN public.pets p1 ON p1.id = ct.pet_id_1
  LEFT JOIN public.pets p2 ON p2.id = ct.pet_id_2
  LEFT JOIN LATERAL (
    SELECT m.*
    FROM public.messages m
    WHERE m.thread_id = ct.id
    ORDER BY m.created_at DESC
    LIMIT 1
  ) lm ON true
  WHERE ct.pet_id_1 = my_pet_id OR ct.pet_id_2 = my_pet_id
  ORDER BY COALESCE(lm.created_at, ct.updated_at, ct.created_at) DESC;
$$;

GRANT EXECUTE ON FUNCTION public.fetch_chat_threads(UUID) TO authenticated;
