defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  @allowed_sort_by ~w(item quantity days_until_expires)

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = params["sort_by"] || "id"
    sort_order = params["sort_order"] || "asc"

    options = %{
      sort_by: valid_sort_by(sort_by),
      sort_order: String.to_atom(sort_order),
      page: param_to_integer(params["page"], 1),
      per_page: param_to_integer(params["per_page"], 10)
    }

    donations = Donations.list_donations(options)

    {:noreply,
     assign(socket, donations: donations, options: options, total: Donations.count_donations())}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/donations?#{params}")

    {:noreply, socket}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  defp sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: next_sort_order(assigns.options.sort_order)
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={~p"/donations?#{@params}"}>
      <%= render_slot(@inner_block) %>
      <%= sort_indicator(@sort_by, @options) %>
    </.link>
    """
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  defp sort_indicator(_column, _options), do: ""

  defp valid_sort_by(%{"sort_by" => sort_by}) when sort_by in @allowed_sort_by do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  defp more_pages?(options, total) do
    options.page * options.per_page < total
  end

  defp pages(options, total) do
    page_count = ceil(total / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2), page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end
end
