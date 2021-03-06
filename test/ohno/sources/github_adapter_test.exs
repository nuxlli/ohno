defmodule Ohno.Sources.GithubAdapterTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  import ShorterMaps
  alias Ohno.Sources.GithubAdapter

  describe to_string(__MODULE__) do
    setup do
      client = GithubAdapter.client()
      ExVCR.Config.filter_request_headers("Authorization")
      ~M{client}
    end

    test "fail to set a state for invalid commit sha", ~M{client} do
      use_cassette "github_422_commit" do
        {:error, %Tesla.Env{status: 422}} =
          GithubAdapter.statuses(client, "parafuzo/ohno", "xpto", %{
            state: "sucess"
          })
      end
    end

    @commit_sha "85c90339f3575f1808c6135e08bb8d780f4486f1"
    test "update a state for valid commit sha", ~M{client} do
      use_cassette "github_statuses_commit" do
        {:ok, %{"state" => "success"}} =
          GithubAdapter.statuses(client, "parafuzo/ohno", @commit_sha, %{
            state: "success",
            description: "Test github api client in this project",
            context: "ohno/test"
          })
      end
    end

    test "get a file content in repository by ref", ~M{client} do
      use_cassette "github_raw_file_from_commit_ref" do
        {:ok, file_content} =
          GithubAdapter.get_file(client, "parafuzo/ohno", @commit_sha, "./README.md")

        assert file_content =~ ~r/# ohno/
      end

      use_cassette "github_raw_file_from_branch_ref" do
        {:ok, file_content} =
          GithubAdapter.get_file(client, "parafuzo/ohno", "master", "./README.md")

        assert file_content =~ ~r/# ohno/
      end

      use_cassette "github_get_not_found file" do
        {:error, :not_found_file} =
          GithubAdapter.get_file(client, "parafuzo/ohno", "master", "./invalid_file.md")
      end
    end
  end
end
