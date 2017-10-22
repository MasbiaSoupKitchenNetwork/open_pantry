defmodule OpenPantry.FoodSelectionTest do
  use OpenPantry.Web.AcceptanceCase, async: true

  import OpenPantry.CompleteFacility
  import OpenPantry.Web.UserSelectionView, only: [login_token: 1]
  import OpenPantry.Web.DisplayLogic, only: [dasherize: 1]
  import Wallaby.Query, only: [css: 1, css: 2, button: 1, link: 1]

  test "selection table has tab per credit type, plus meals and cart", %{session: session} do
    %{credit_types: [credit_type|_]} = two_credit_facility()

    session
    |> visit(food_selection_url(Endpoint, :index, "en"))
    |> assert_has(css(".#{dasherize(credit_type.name)}", text: credit_type.name))
    |> Wallaby.end_session
  end

  test "selection table shows first foods in stock on load", %{session: session} do
    %{credit_types: [credit_type|_], foods: [food|_]} = two_credit_facility()

    session
    |> resize_window(2000, 2000)
    |> visit(food_selection_url(Endpoint, :index, "en"))
    |> click(link(credit_type.name))
    |> take_screenshot
    |> assert_has(css(".#{dasherize(credit_type.name)}-stock-description", text: food.longdesc))
    |> Wallaby.end_session
  end

  test "selection table does not show second food in stock on load", %{session: session} do
    %{credit_types: [credit_type|_], foods: [_|[food2]]} = two_credit_facility()

    session
    |> visit(food_selection_url(Endpoint, :index, "en"))
    |> refute_has(css(".#{dasherize(credit_type.name)}-stock-description", text: food2.longdesc))
    |> Wallaby.end_session
  end

  test "selection table allows selecting second tab", %{session: session} do
    %{credit_types: [_|[credit_type2]], foods: [_|[food2]]} = two_credit_facility()

    session
    |> visit(food_selection_url(Endpoint, :index, "en"))
    |> click(link(credit_type2.name))
    |> assert_has(css(".#{dasherize(credit_type2.name)}-stock-description", text: food2.longdesc))
    |> Wallaby.end_session
  end

  # @tag :pending
  test "clicking + adds to cart, decrements stock quantity", %{session: session} do
    %{user: user } = one_credit_facility()
    session
    |> visit("/en/food_selections?login=#{login_token(user)}")
    |> assert_has(stock_available(20))
    |> click(css(".js-add-stock"))
    |> assert_has(stock_available(20))
    |> assert_has(stock_requested(0))
  end

  def stock_available(count), do: css(".js-available-quantity", text: "#{count}")
  def stock_requested(count), do: css(".js-current-quantity", text: "#{count}")
end
