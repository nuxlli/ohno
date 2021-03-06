defmodule Ohno.Builder.Job do
  use Ohno, :schema

  alias Ohno.Builder.JobStatus

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "builder_jobs" do
    field :gcloud_build_id, :binary_id
    field :status, JobStatus, default: :NEW

    belongs_to :stage, Ohno.Builder.Stage

    timestamps()
  end

  def success?(%__MODULE__{status: :SUCCESS}), do: true
  def success?(_), do: false

  @required_fields [:stage_id, :status]
  @optional_fields [:gcloud_build_id]

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, JobStatus.__enum_map__())
  end
end
