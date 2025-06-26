defmodule Servy.Handler do
  def handle(request) do
    # Pipe the response of each function into the next function
    # A series of transformations happening here
    request
    |> parse
    |> log
    |> rewrite_path
    |> rewrite_bear_query_params
    |> route
    |> track
    |> format_response
  end

  # A single expression in the function body. Hence can be written on one line without an end
  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")
    %{method: method, path: path, status: nil, resp_body: ""}
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    IO.puts "Rewriting wildlife to wildthings"
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def rewrite_bear_query_params(%{path: "/bears?id=" <> bear_id} = conv) do
    IO.puts "Rewriting bear query param to bear detail"
    %{conv | path: "/bears/" <> bear_id}
  end

  # Default catch-all function clause.
  def rewrite_bear_query_params(conv), do: conv

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/wildthings") do
    %{conv | status: 200, resp_body: "Tiger, Lion, Wolf"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | status: 200, resp_body: "Bears"}
  end

  def route(conv, "GET", "/bears/" <> id) do
    %{conv | status: 200, resp_body: "Bear #{id}!"}
  end

  def route(conv, "DELETE", "/bears/" <> id) do
    %{conv | status: 204, resp_body: "Deleted Bear #{id}!"}
  end

  def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "Not Found: #{path}"}
  end

  def track(%{status: 404} = conv) do
    IO.puts ("Warning: 404 for #{conv.path}")
    conv
  end

  # Default function clause that matches non 404 statuses
  def track(conv), do: conv

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_response conv.status}
    Content-Type: text/html
    Content-Length: #{byte_size conv.resp_body}

    #{conv.resp_body}
    """
  end

  defp status_response(code) do
    %{
      200=> "OK",
      404=> "Not Found",
      201=> "Created",
      204=> "No Content",
      500=> "Internal Server Error"
    }[code]
  end
end


request = """
GET /wildthings HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

bears_request = """
GET /bears HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

tigers_request = """
GET /tigers HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

bear_request = """
GET /bears/10 HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

delete_bear_request = """
DELETE /bears/10 HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

response = Servy.Handler.handle(request)
IO.puts response

bears_response = Servy.Handler.handle(bears_request)
IO.puts bears_response

tigers_response = Servy.Handler.handle(tigers_request)
IO.puts tigers_response

bear_response = Servy.Handler.handle(bear_request)
IO.puts bear_response

delete_bear_response = Servy.Handler.handle(delete_bear_request)
IO.puts delete_bear_response

request = """
GET /wildlife HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears?id=5 HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

response = Servy.Handler.handle(request)
IO.puts response
