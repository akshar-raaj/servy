defmodule Servy.Parser do
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
end
