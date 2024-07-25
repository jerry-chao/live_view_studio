defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
        servers: servers,
        selected_server: hd(servers),
        coffees: 0,
        form: to_form(changeset)
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)

    {:noreply,
     assign(socket,
       selected_server: server,
       page_title: "What's up #{server.name}?"
     )}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, selected_server: hd(socket.assigns.servers))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        socket = update(socket, :servers, &[server | &1])

        changeset = Servers.change_server(%Server{})

        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, changeset} ->
        IO.inspect(changeset, label: :changeset)

        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def render(assigns) do
    IO.inspect(assigns, label: :assigns)

    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link
            :for={server <- @servers}
            patch={~p"/servers?#{[id: server.id]}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <.form for={@form} phx-submit="save">
            <div class="field">
              <.input field={@form[:name]} placeholder="Name" />
            </div>

            <div class="field">
              <.input field={@form[:framework]} placeholder="Framework" />
            </div>

            <div class="field">
              <.input
                field={@form[:size]}
                placeholder="Size (MB)"
                type="number"
              />
            </div>

            <.button phx-disable-with="Saving...">
              Save
            </.button>
          </.form>

          <div class="server">
            <div class="header">
              <h2><%= @selected_server.name %></h2>
              <span class={@selected_server.status}>
                <%= @selected_server.status %>
              </span>
            </div>
            <div class="body">
              <div class="row">
                <span>
                  <%= @selected_server.deploy_count %> deploys
                </span>
                <span>
                  <%= @selected_server.size %> MB
                </span>
                <span>
                  <%= @selected_server.framework %>
                </span>
              </div>
              <h3>Last Commit Message:</h3>
              <blockquote>
                <%= @selected_server.last_commit_message %>
              </blockquote>
            </div>
          </div>
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust Lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
