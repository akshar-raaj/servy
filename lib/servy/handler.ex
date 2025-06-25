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
    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    route(conv, conv.path)
  end

  def route(conv, "/wildthings") do
    %{conv | resp_body: "Tiger, Lion, Wolf"}
  end

  def route(conv, "/bears") do
    %{conv | resp_body: "Bears"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{byte_size conv.resp_body}

    #{conv.resp_body}
    """
  end
end


request = """
GET /wildthings HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client

"""

response = Servy.Handler.handle(request)
IO.puts response
