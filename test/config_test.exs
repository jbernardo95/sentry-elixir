defmodule Sentry.ConfigTest do
  use ExUnit.Case
  import Sentry.TestEnvironmentHelper
  alias Sentry.Config

  test "retrieves from application environment" do
    dsn = "https://public:secret@app.getsentry.com/1"
    modify_env(:sentry, dsn: dsn)
    assert dsn == Config.dsn()
  end

  test "retrieves from system environment" do
    dsn = "https://public:secret@app.getsentry.com/1"
    modify_system_env(%{"SENTRY_DSN" => dsn})

    assert dsn == Config.dsn()
  end

  test "sets application env if found in system env" do
    dsn = "https://public:secret@app.getsentry.com/1"
    modify_system_env(%{"SENTRY_DSN" => dsn})

    assert Config.dsn() == dsn
    assert Application.get_env(:sentry, :dsn) == dsn
  end

  test "retrieves from DSN query string" do
    modify_env(
      :sentry,
      dsn: "https://public:super_secret@app.getsentry.com/2?server_name=my_server"
    )

    assert "my_server" == Config.server_name()
  end

  test "sets application env if found in DSN query string" do
    modify_env(
      :sentry,
      dsn: "https://public:super_secret@app.getsentry.com/2?server_name=my_server"
    )

    assert "my_server" == Config.server_name()
    assert Application.get_env(:sentry, :server_name) == "my_server"
  end

  describe "source_code_path_pattern" do
    test "retrieves from environment" do
      modify_env(:sentry, source_code_path_pattern: "**/*test.ex")
      assert "**/*test.ex" == Config.source_code_path_pattern()
    end

    test "returns default when not configured" do
      assert "**/*.ex" == Config.source_code_path_pattern()
    end

    test "does not retrieve from DSN" do
      dsn = "https://public:super_secret@app.getsentry.com/2?source_code_path_pattern=test"
      modify_env(:sentry, dsn: dsn)
      refute "test" == Config.source_code_path_pattern()
    end
  end

  describe "included_environments" do
    test "retrieves and converts string from system environment" do
      delete_env(:sentry, [:included_environments])
      modify_system_env(%{"SENTRY_INCLUDED_ENVIRONMENTS" => "test,dev"})
      assert ["test", "dev"] == Config.included_environments()
    end

    test "retrieves and converts string from config" do
      modify_env(:sentry, included_environments: "test,dev")
      assert ["test", "dev"] == Config.included_environments()
    end
  end
end
