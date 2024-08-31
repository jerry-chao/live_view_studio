defmodule LiveViewStudioWeb.DownloadsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Downloads
  alias LiveViewStudio.Downloads.Download

  def mount(_params, _session, socket) do
    downloads = Downloads.list_downloads()
    changeset = Downloads.change_download(%Download{})

    {:ok,
     assign(socket,
       downloads: downloads,
       selected_download: hd(downloads),
       form: to_form(changeset)
     )}
  end

  def handle_event(_event, _unsigned_params, socket) do
    {:ok, socket}
  end
end
