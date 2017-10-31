defmodule OpenPantry.Web.UserSelectionController do
  use OpenPantry.Web, :controller
  alias OpenPantry.User
  alias OpenPantry.CreditType
  alias OpenPantry.UserCredit
  import OpenPantry.Web.UserSelectionView, only: [login_token: 1]
  @unknown_language_id 184

  def index(conn, _params) do
    facility = facility(conn) |> Repo.preload(:users)
    render conn, "index.html",  users: facility.users, conn: conn, changeset: User.changeset(%User{})
  end

  def show(conn, params) do
    user = User.find(params["id"] |> String.to_integer) # make sure user exists
    redirect_and_notify(conn, user)
  end

  def create(conn, params) do
    user =  User.changeset(%User{}, %{name: name_from_params(params),
                                      family_members: family_members_from_params(params),
                                      primary_language_id: @unknown_language_id,
                                      facility_id: facility(conn).id,
                                     })
            |> Repo.insert!()

    for credit_type <- CreditType |> Repo.all do
      UserCredit.changeset(%UserCredit{},
        %{credit_type_id: credit_type.id, user_id: user.id, balance: credit_type.credits_per_period * user.family_members })
      |> Repo.insert!()
    end
    redirect_and_notify(conn, user)
  end

  defp name_from_params(params) do
    if Blank.blank?(params["user"]["name"]) do
      "Anonymous"
    else
      params["user"]["name"]
    end
  end

  defp family_members_from_params(params) do
    if Blank.blank?(params["user"]["family_members"]) do
      1
    else
      String.to_integer(params["user"]["family_members"])
    end
  end

  defp facility(conn) do
    conn.assigns[:facility]
  end


  defp redirect_and_notify(conn, user) do
    conn
    |> Plug.Conn.put_resp_cookie("user_id", Integer.to_string(user.id))
    |> redirect(to: "/en?login=#{login_token(user)}")
    |> put_flash(:info, "You are now logged in as #{user.name}, user id ##{user.id}")
    |> halt
  end

end
