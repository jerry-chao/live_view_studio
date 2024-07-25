defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  @allowed_sort_by ~w(id size style topping_1 topping_2 price)

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_by = params["sort_by"] || "id"
    sort_order = params["sort_order"] || "asc"

    options = %{
      sort_by: valid_sort_by(sort_by),
      sort_order: String.to_atom(sort_order)
    }

    pizza_orders = PizzaOrders.list_pizza_orders(options)

    {:noreply, assign(socket, pizza_orders: pizza_orders, options: options)}
  end

  def sort_link(assigns) do
    ~H"""
    <.link patch={
      ~p"/pizza-orders?#{%{sort_by: @sort_by, sort_order: next_sort_order(@options.sort_order)}}"
    }>
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
end
