defmodule Plug.Adapters.Wait1.TestFixture do
  use Plug.Router

  plug :match
  plug :dispatch

  def init(options) do
    # initialize options
    options
  end

  get "/" do
    send_resp(conn, 200, Poison.encode!(%{"hello" => "world"}))
  end
  get "/redirect" do
    conn
    |> put_resp_header("location", "/")
    |> send_resp(303, "")
  end
  get "/foo" do
    conn
    |> send_resp(200, Poison.encode!(%{"foo" => "bar"}))
  end
  post "/invalidate" do
    %{conn | resp_headers: [{"x-invalidates", "/"}, {"x-invalidates", "/redirect"}]}
    |> send_resp(200, "")
  end
  post "/invalidate-w-redirect" do
    %{conn | resp_headers: [{"x-invalidates", "/"}, {"x-invalidates", "/redirect"}, {"location", "http://localhost:3000/foo"}]}
    |> send_resp(303, "")
  end
  get "/raise" do
    put_resp_header(conn, "foo", "bar")
    raise :fake_error
  end
  get "/throw" do
    put_resp_header(conn, "foo", "bar")
    throw :fake_error
  end
  get "/cookie-set" do
    conn
    |> Plug.Conn.fetch_query_params
    |> put_resp_cookie("foo", Dict.get(conn.query_params, "foo"))
    |> send_resp(200, "")
  end
  get "/cookie-get" do
    conn = Plug.Conn.fetch_cookies(conn)
    conn
    |> send_resp(200, Poison.encode!(%{"foo" => Dict.get(conn.cookies, "foo")}))
  end
  get "/headers" do
    conn
    |> send_resp(200, Poison.encode!(:maps.from_list(conn.req_headers)))
  end

  match _ do
    send_resp(conn, 404, "")
  end
end

ExUnit.start()
