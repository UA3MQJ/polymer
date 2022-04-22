defmodule Reaction.TransformPerformanceTest do
  use ExUnit.Case
  require Logger

  # @formula "NNCS"

  @rules %{
    "CO" => "S",
    "OO" => "N",
    "CS" => "O",
    "NO" => "C",
    "OS" => "C",
    "OC" => "S",
    "ON" => "C",
    "NN" => "C",
    "SO" => "O",
    "NC" => "S",
    "NS" => "S",
    "SN" => "S",
    "SS" => "N",
    "SC" => "S",
    "CC" => "N",
    "CN" => "C",
  }


  # @tag :skip
  test "perf" do
    # prepare compiler module
    Reaction.Polymer.compile(@rules)
    # prepare persistent_term
    Reaction.Polymer.prepare_pts(@rules)
    # prepare map
    tr_rules_map = Reaction.Polymer.prepare_map(@rules)
    # prepare map
    tr_rules_list = Reaction.Polymer.prepare_list(@rules)

    test_data = @rules
      |> Map.keys()
      |> Enum.map(fn(pair) ->
        to_charlist(pair)
      end)

    # Logger.debug ">>>>> test_data=#{inspect test_data}"

    # result1 =  test_data
    #   |> Enum.map(fn(pair) ->
    #     Reaction.Polymer.transform(pair, tr_rules_map, :map_get)
    #   end)

    # Logger.debug ">>>>> result1=#{inspect result1}"

    Benchee.run(%{
      "compiled_module_translator"    => fn ->
        _result =  test_data
          |> Enum.map(fn(pair) ->
            Reaction.Polymer.transform(pair, :compiled_module)
          end)
      end,
      "persistent_term_storage_translator" => fn ->
        _result =  test_data
          |> Enum.map(fn(pair) ->
            Reaction.Polymer.transform(pair, :persistent_term_storage)
          end)
      end,
      "map_get_translator" => fn ->
        _result =  test_data
          |> Enum.map(fn(pair) ->
            Reaction.Polymer.transform(pair, tr_rules_map, :map_get)
          end)
      end,
      "proplist_get_translator" => fn ->
        _result =  test_data
          |> Enum.map(fn(pair) ->
            Reaction.Polymer.transform(pair, tr_rules_list, :proplist_get)
          end)
      end
    })

  end
end
