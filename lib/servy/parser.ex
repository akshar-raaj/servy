defmodule Servy.Parser do
  def parse(request) do
    # A classic example of a pipeline.
    # The request is a string, and we want to convert it to a map.
    # We split the request string by newlines, take the first line, and then split that line by spaces.
    # The first two elements of the resulting list are the method and path
    # The third element is ignored (the HTTP version).
    # We then create a map with the method, path, status (initially nil),
    # and an empty response body.
    [request_and_headers, params_string] = request |> String.split("\n\n")
    [request_line | header_lines] = request_and_headers |> String.split("\n")
    headers = parse_headers(header_lines, %{})
    params = URI.decode_query(params_string)
    [method, path, _] = request_line |> String.trim |> String.split(" ")
    %{method: method, path: path, status: nil, resp_body: "", params: params, headers: headers}
  end

  def parse_headers([head | tail], headers) do
    [key, value] = head |> String.split(": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers
end
