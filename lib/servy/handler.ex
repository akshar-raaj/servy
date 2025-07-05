defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests and returns appropriate response"

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [log: 1, rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

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

  # This is route/1 A function clause
  @doc "Path function handler. Handles GET /wildthings"
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
