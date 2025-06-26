defmodule Servy.Handler do
  def handle(request) do
    # Pipe the response of each function into the next function
    # A series of transformations happening here
    request
    |> parse
    |> log
    |> route
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

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/wildthings") do
    %{conv | status: 200, resp_body: "Tiger, Lion, Wolf"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | status: 200, resp_body: "Bears"}
  end

  def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "Not Found: #{path}"}
  end

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
      201=> "Created"
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

response = Servy.Handler.handle(request)
IO.puts response

bears_response = Servy.Handler.handle(bears_request)
IO.puts bears_response

tigers_response = Servy.Handler.handle(tigers_request)
IO.puts tigers_response
