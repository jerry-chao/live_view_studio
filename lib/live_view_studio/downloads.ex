defmodule LiveViewStudio.Downloads do
  alias LiveViewStudio.Downloads.Download

  def list_downloads do
    [
      %Download{id: 1, channel: 1, url: "https://elixir-lang.org"},
      %Download{id: 2, channel: 2, url: "https://phoenixframework.org"},
      %Download{id: 3, channel: 3, url: "https://liveviewstudio.com"}
    ]
  end

  def change_download(%Download{} = download, attrs \\ %{}) do
    Download.changeset(download, attrs)
  end
end
