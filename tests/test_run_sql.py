"""Tests for scripts/run_sql.py (no AWS needed).

Run:  pip install pytest boto3 && pytest -v
"""
import glob
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))

import run_sql  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")


def test_split_simple():
    assert run_sql.split_statements("SELECT 1; SELECT 2;") == ["SELECT 1", "SELECT 2"]


def test_split_ignores_semicolons_in_strings_and_comments():
    sql = """
    -- comment; with semicolon
    INSERT INTO t VALUES ('a;b', 'it''s; fine');
    /* block; comment */ SELECT "weird;name" FROM t;
    """
    assert run_sql.split_statements(sql) == [
        "INSERT INTO t VALUES ('a;b', 'it''s; fine')",
        'SELECT "weird;name" FROM t',
    ]


def test_split_handles_missing_final_semicolon():
    assert run_sql.split_statements("SELECT 1;\nSELECT 2") == ["SELECT 1", "SELECT 2"]


def test_comment_only_file_produces_no_statements():
    assert run_sql.split_statements("-- just a comment\n-- another;\n") == []


def test_lesson_files_split_into_expected_counts():
    counts = {os.path.basename(p): len(run_sql.split_statements(open(p).read()))
              for p in glob.glob(os.path.join(ROOT, "sql", "**", "*.sql"), recursive=True)}
    assert counts["01-schema.sql"] == 13
    assert counts["02-seed-data.sql"] == 5
    assert counts["01-select-basics.sql"] == 11
    assert counts["06-modify-data.sql"] == 8   # the commented-out failing examples are skipped
    assert counts["solutions.sql"] == 10


def test_field_values():
    assert run_sql.field_value({"isNull": True}) == "NULL"
    assert run_sql.field_value({"stringValue": "Ghana"}) == "Ghana"
    assert run_sql.field_value({"longValue": 3}) == "3"
    assert run_sql.field_value({"booleanValue": False}) == "False"


def test_describe_query_result():
    result = {
        "columnMetadata": [{"label": "country"}, {"label": "customers"}],
        "records": [[{"stringValue": "Ghana"}, {"longValue": 3}],
                    [{"stringValue": "United States"}, {"longValue": 2}]],
    }
    assert run_sql.describe(result) == (
        "country       | customers\n"
        "--------------+----------\n"
        "Ghana         | 3        \n"
        "United States | 2        \n"
        "(2 rows)"
    )


def test_describe_dml_result():
    assert run_sql.describe({"numberOfRecordsUpdated": 4}) == "OK (4 rows affected)"


class FakeClient:
    """Mimics the rds-data client: paused twice, then answers."""

    class exceptions:
        class DatabaseResumingException(Exception):
            pass

        class BadRequestException(Exception):
            pass

    def __init__(self):
        self.calls = 0

    def execute_statement(self, **kwargs):
        self.calls += 1
        if self.calls <= 2:
            raise self.exceptions.DatabaseResumingException()
        return {"numberOfRecordsUpdated": 0}


def test_execute_waits_for_resume(monkeypatch):
    monkeypatch.setattr(run_sql.time, "sleep", lambda s: None)
    client = FakeClient()
    assert run_sql.execute(client, {}, "SELECT 1") == {"numberOfRecordsUpdated": 0}
    assert client.calls == 3
