defmodule LiveViewStudio.Downloads.Download do
  use Ecto.Schema
  import Ecto.Changeset

  schema "downloads" do
    field :channel, :integer
    field :url, :string
  end

  def changeset(download, attrs) do
    download
    |> cast(attrs, [:channel, :url])
    |> validate_required([:channel, :url])
  end

  def from_external_service(data) do
    %__MODULE__{}
    |> changeset(%{
      channel: data["channel"],
      url: data["url"]
    })
    |> apply_changes()
  end
end
