defmodule Reaction do
  require Logger

  def run(formula, rules, n) do
    {min_count, max_count} =
      formula
      |> pairs()
      |> step(n, rules)
      |> split_and_summ(String.first(formula), String.last(formula))
      |> Enum.map(fn {_sym, count} -> count end)
      |> Enum.min_max()

    max_count - min_count
  end

  defp pairs(formula) do
    formula
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.frequencies()
  end

  defp step(pairs, 0, _rules) do
    pairs
  end

  defp step(pairs, n, rules) do
    next_pairs =
      pairs
      |> Enum.reduce(%{}, fn {[a, b], count}, acc ->
        new = rules[a <> b]
        new_el1 = [a, new]
        new_el2 = [new, b]

        acc
        |> Map.update(new_el1, count, &(&1 + count))
        |> Map.update(new_el2, count, &(&1 + count))
      end)

    step(next_pairs, n - 1, rules)
  end

  defp split_and_summ(pairs, start_sym, end_sym) do
    pairs
    |> Enum.reduce(%{}, fn {[a, b], count}, acc ->
      acc
      |> Map.update(a, count, &(&1 + count))
      |> Map.update(b, count, &(&1 + count))
    end)
    |> Enum.map(fn
      {^start_sym, count} -> {start_sym, div(count, 2) + 1}
      {^end_sym, count} -> {end_sym, div(count, 2) + 1}
      {k, count} -> {k, div(count, 2)}
    end)
    |> Enum.into(%{})
  end
end
