defmodule Servy.Handler do
  def handle(request) do
    # Pipe the response of each function into the next function
    # A series of transformations happening here
    request
    |> parse
    |> route
    |> format_response
  end

  def parse(request) do
    first_line = request |> String.split("\n") |> List.first()
    parts = first_line |> String.split(" ")
    method = Enum.at(parts, 0)
    path = Enum.at(parts, 1)
    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    # TODO: Create a new map that also has the response body
    conv = %{method: "GET", path: "/wildthings", resp_body: "tiger, lion, wolf"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    tiger, lion, wolf
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
