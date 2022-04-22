defmodule Reaction.Polymer do
  @default_translator :compiled_module

  def transform(pair),
    do: transform(pair, @default_translator)
  def transform(pair, :compiled_module),
    do: Reaction.CompiledPolymer.transform(pair)
  def transform(pair, :persistent_term_storage),
    do: :persistent_term.get(pair)

  def transform(pair, rules, :map_get),
    do: Map.get(rules, pair)

  def transform(pair, rules, :proplist_get),
    do: :proplists.get_value(pair, rules)

  def compile(rules) do
    ast = rules
      |> Enum.map(fn({k,v}) ->
        ch_param = to_charlist(k)
        [ch_result] = to_charlist(v)
        quote do
          def transform(unquote(ch_param)), do: unquote(ch_result)
        end
      end)
    Module.create(Reaction.CompiledPolymer, ast, Macro.Env.location(__ENV__))
  end

  def prepare_pts(rules) do
    rules
      |> Enum.map(fn({k,v}) ->
        ch_param = to_charlist(k)
        [ch_result] = to_charlist(v)
        :persistent_term.put(ch_param, ch_result)
      end)
  end

  def prepare_map(rules) do
    rules
      |> Enum.map(fn({k,v}) ->
        ch_param = to_charlist(k)
        [ch_result] = to_charlist(v)
        {ch_param, ch_result}
      end)
      |> Enum.into(%{})
  end

  def prepare_list(rules) do
    rules
      |> Enum.map(fn({k,v}) ->
        ch_param = to_charlist(k)
        [ch_result] = to_charlist(v)
        {ch_param, ch_result}
      end)
  end
end
