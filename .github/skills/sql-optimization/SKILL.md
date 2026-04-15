---
name: sql-optimization
description: "Universal SQL performance optimization workflow. Use when queries are slow, indexes are missing, or pagination/ordering is inefficient. Complements postgresql-optimization."
---

# SQL Optimization (universal)

Use this skill to improve SQL performance safely.

## When to use

- “This query is slow”
- “We need better pagination / sorting performance”
- “What indexes should we add?”

## Workflow

1) **Clarify the workload**
   - read/query frequency, expected row counts, latency target

2) **Inspect query shape**
   - filters, join order, aggregation, ordering

3) **Indexing strategy**
   - add indexes aligned with `WHERE` + `ORDER BY`
   - avoid over-indexing write-heavy tables

4) **Pagination**
   - prefer keyset pagination when offset becomes expensive

5) **Validate**
   - ensure correctness (same results)
   - keep migration changes safe and reversible

## Source

Inspired by the awesome-copilot skill:
https://github.com/github/awesome-copilot/tree/main/skills/sql-optimization
