# Changelog

## 2026-10-18
- Deployed Athena Workgroup, Glue Database, and Glue Table.
- Configured CloudTrail table with partition projection on `day`.
- Initial query returned 0 rows due to date projection boundaries.
- Adjusted query to select without a date filter. Successfully returned 10 rows, scanning 47.89 KB.
- Confirmed forensic querying of AWS API logs.