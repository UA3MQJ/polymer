defmodule Reaction do
  require Logger

  @default_algorithm_version :recursive2

  def run(formula, rules, n),
    do: run(formula, rules, n, @default_algorithm_version)

  def run(formula, rules, n, algorithm) do
    polymere = apply(__MODULE__, algorithm, [formula, rules, n])
    # {min_freq, max_freq} = polymere
    #   |> Enum.frequencies()
    #   |> Enum.map(fn({_pol, count}) -> count end)
    #   |> Enum.min_max()

    # max_freq - min_freq
  end

  # recursive
  def recursive(formula, rules, n) do
    # Reaction.Polymer.compile(rules)

    cformula = to_charlist(formula)

    Enum.map(0..(size(n)), fn(x) ->  el((n), x, cformula) end)
  end

  defp size(step), do: 3*Bitwise.bsl(1, step)

  defp el(0, idx, formula), do: :lists.nth(idx + 1, formula)
  defp el(lvl, idx, formula) do
    case rem(idx, 2) do
      0 ->
        el(lvl-1, div(idx, 2), formula)
      1 ->
        a = div(idx, 2)
        sym = [el(lvl-1, a, formula), el(lvl-1, a+1, formula)]
        Reaction.Polymer.transform(sym)
    end
  end
  # -------------------------------

  def map_reduce(formula, rules, n) do
    # Reaction.Polymer.compile(rules)

    rules_map = rules
      |> Enum.map(fn({k,v}) -> {to_charlist(k), hd(to_charlist(v))} end)
      |> Enum.into(%{})

    cformula = to_charlist(formula)

    polymer = 1..n
      |> Enum.reduce(cformula, fn _i, acc ->
        acc
          |> Reaction.Formula.stream()
          |> Enum.to_list()
      end)
  end
  # --------------------------------

  def recursive2(formula, rules, n) do
    # Reaction.Polymer.compile(rules)

    cformula = to_charlist(formula)

    # react(cformula, [])
    step_react(cformula, n)
  end

  defp step_react(cformula, 0), do: cformula
  defp step_react(cformula, n), do: step_react(react(cformula), n-1)

  defp react(cformula),            do: react(cformula,    [])
  defp react([a, b|tail], result), do: react([b] ++ tail, [Reaction.Polymer.transform([a, b]), a] ++ result)
  defp react([b]        , result), do: react([],          [b] ++ result)
  defp react([]         , result), do: :lists.reverse(result)

  # -------------------------------

  def map_reduce2(formula, rules, n) do
    {min_count, max_count} = formula
      |> pairs()
      |> step(n, rules)
      |> split_and_summ(String.first(formula), String.last(formula))
      |> Enum.map(fn({_sym, count}) -> count end)
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
    next_pairs = pairs
      |> Enum.reduce(%{}, fn({[a, b], count}, acc) ->
        new = rules[a<>b]
        new_el1 = [a, new]
        new_el2 = [new, b]

        acc
          |> Map.update(new_el1, count, &(&1 + count))
          |> Map.update(new_el2, count, &(&1 + count))
      end)
    step(next_pairs, n-1, rules)
  end

  defp split_and_summ(pairs, start_sym, end_sym) do
    pairs
      |> Enum.reduce(%{}, fn({[a, b], count}, acc) ->
        acc
          |> Map.update(a, count, &(&1 + count))
          |> Map.update(b, count, &(&1 + count))
      end)
      |> Enum.map(fn
        {^start_sym, count} -> {start_sym, div(count, 2)+1}
        {^end_sym, count}   -> {end_sym, div(count, 2)+1}
        {k, count}          -> {k, div(count, 2)}
      end)
      |> Enum.into(%{})
  end
end

defmodule Reaction.Formula do
  require Logger
  def stream(cformula) do
    Stream.resource(
      #start_fun
      fn ->
        {[], cformula} # state
      end,
      # next_fun
      fn state ->
        case state do
          {[], :end} ->
            {:halt, nil}
          {[], [el1, el2 | []]} = _state ->
            new_el = Reaction.Polymer.transform([el1, el2])
            {[ el1 ], {[new_el, el2], :end}}
          {[], [el1, el2 | tail]} = _state ->
            new_el = Reaction.Polymer.transform([el1, el2])
            {[ el1 ], {[new_el], [el2] ++ tail}}
          {el, tail} ->
            {el, {[], tail}}
        end
      end,
      # end_fun
      fn _ ->
        :ok
      end
    )
  end
end
