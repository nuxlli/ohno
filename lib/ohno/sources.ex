defmodule Ohno.Sources do

  @adapter Keyword.get(
             Application.get_env(:ohno, __MODULE__),
             :adapter,
             Ohno.Sources.GithubAdapter
           )

  alias Ohno.Repo
  alias Ohno.Sources.Repository

  @states %{
    [:NEW, :STATUS_UNKNOWN, :QUEUED, :WORKING] => "pending",
    [:SUCCESS] => "success",
    [:FAILURE, :TIMEOUT, :CANCELLED] => "failure",
    [:INTERNAL_ERROR] => "error"
  }

  def job_state(%{status: status}) do
    @states
    |> Enum.find(fn {opts, _} -> Enum.any?(opts, &(&1 == status)) end)
    |> case do
      {_, state} -> state
      nil -> nil
    end
  end

  def statuses(repo, commit_sha, parameters) do
    @adapter.client()
    |> @adapter.statuses(repo, commit_sha, parameters)
  end

  def get_file(repo, commit_sha, path) do
    @adapter.client()
    |> @adapter.get_file(repo, commit_sha, path)
  end

  def target_url() do
    Keyword.get(Application.get_env(:ohno, __MODULE__), :target_url)
  end

  def add_repository(attrs) do
    attrs
    |> Repository.changeset()
    |> Repo.insert()
  end

  def get_repository(id) do
    case Repo.get(Repository, id) do
      %Repository{} = r -> {:ok, r}
      _ -> {:error, :not_found}
    end
  end

  def query_repositories() do
    Ohno.Sources.Repository
  end

  def repo_by_url(url) do
    with {:ok, github_repo} <- parse_repo(url),
         %Repository{} = repo <- Repo.get_by(Repository, github_repo: github_repo) do
      {:ok, repo}
    else
      _ ->
        {:error, "#{url} repository not registered in the service"}
    end
  end

  def parse_repo(<<"https://github.com/", repo::binary>>) do
    {:ok, repo}
  end

  def parse_repo(_), do: {:error, :invalid_repo}
end
