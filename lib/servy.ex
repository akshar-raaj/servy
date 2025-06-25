defmodule Servy do
  def hello(name) do
    "Hello, #{name}!"
  end

  def double(x) do
    x + x
  end

  def four_times(x) do
    x |> double |> double
  end
end
