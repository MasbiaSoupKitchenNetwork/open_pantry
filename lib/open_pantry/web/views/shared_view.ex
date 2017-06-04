defmodule OpenPantry.Web.SharedView do
  use OpenPantry.Web, :view
  import OpenPantry.Stock
  import OpenPantry.Web.DisplayLogic
  alias OpenPantry.StockDistribution
  alias OpenPantry.UserOrder
  alias OpenPantry.Image

  @doc """
    Renders a distribution line item for food selection index, or to send update to same page via channel
  """
  def render_distribution(%StockDistribution{id: id}) do
    render_to_string(__MODULE__, "distribution.html", distribution: StockDistribution.find(id, [:stock]))
  end

  @doc """
    Renders a line for user order management index, or to send update to same page via channel
  """
  def render_order_link(user_order = %UserOrder{id: id}, conn) do
    render_to_string(__MODULE__, "user_order_details.html", order: user_order, conn: conn)
  end

  def image_url(stock) do
    Image.url({:stock_image, stock}, :thumb)
  end

end
