defmodule Servy.Plugins do
  @moduledoc "Helper functions"

  # A single expression in the function body. Hence can be written on one line without an end
  # IO.inspect writes to stdout, and in addition also returns the value passed to it.
  # Hence, can be safely used in a pipeline.
  def log(conv), do: IO.inspect conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    IO.puts "Rewriting wildlife to wildthings"
    # Return an updated conv with the path changed
    # This is a new map with the same keys as conv, but with the path changed
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> bear_id} = conv) do
    # Bear with query parameter.
    # Modify it to route to bear detail.
    IO.puts "Rewriting bear query param to bear detail"
    %{conv | path: "/bears/" <> bear_id}
  end

  # A function clause that matches when the path is not "/wildlife"
  # This is a default catch-all function clause.
  # Ordering is important in Elixir. The first matching function clause is executed.
  # As this is a generic function, it will match any conv that does not match the previous clause.
  def rewrite_path(conv), do: conv


  def track(%{status: 404} = conv) do
    IO.puts ("Warning: 404 for #{conv.path}")
    conv
  end

  # Default function clause that matches non 404 statuses
  def track(conv), do: conv
end


defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests"

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [log: 1, rewrite_path: 1, track: 1]

  @doc "Transforms a request into a response"
  def handle(request) do
    # Pipe the response of each function into the next function
    # A series of transformations happening here
    request
    |> parse
    |> log
    |> rewrite_path
    |> log
    |> route
    |> track
    |> emojify
    |> format_response
  end

  def parse(request) do
    # A classic example of a pipeline.
    # The request is a string, and we want to convert it to a map.
    # We split the request string by newlines, take the first line, and then split that line by spaces.
    # The first two elements of the resulting list are the method and path
    # The third element is ignored (the HTTP version).
    # We then create a map with the method, path, status (initially nil),
    # and an empty response body.
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")
    %{method: method, path: path, status: nil, resp_body: ""}
  end

  # This is route/1 A function clause
  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Tiger, Lion, Wolf"}
  end

  # Another function clause for route/3
  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Bears"}
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    file_path = @pages_path |> Path.join("form.html")
    case File.read(file_path) do
      {:ok, content} ->
        %{conv | status: 200, resp_body: content}
      {:error, :enoent} ->
        %{conv | status: 404, resp_body: "Cannot create a bear"}
    end
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}!"}
  end

  def route(%{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{conv | status: 204, resp_body: "Deleted Bear #{id}!"}
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    about_path = @pages_path |> Path.join("about.html")
    case File.read(about_path) do
      {:ok, contents} ->
        %{conv | status: 200, resp_body: contents}
      {:error, :enoent} ->
        %{conv | status: 404, resp_body: "File not found"}
      {:error, a} ->
        %{conv | status: 500, resp_body: "File Error: #{a}"}
    end
  end

  def route(%{path: path} = conv) do
    file_path = @pages_path |> Path.join(path <> ".html")
    case File.read(file_path) do
      {:ok, content} ->
        %{conv | status: 200, resp_body: content}
      {:error, :enoent} ->
        %{conv | status: 404, resp_body: "Not Found: #{path}"}
    end
  end

  def emojify(%{status: 200} = conv) do
    %{conv | resp_body: "🎉" <> conv.resp_body <> "🎉"}
  end

  def emojify(conv), do: conv

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

request = """
GET /about HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /contact HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

response = Servy.Handler.handle(request)
IO.puts response
