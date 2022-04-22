defmodule Reaction.ReactionPerformanceTest do
  use ExUnit.Case
  require Logger

  @formula "NNCS"

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

  @tag :skip
  test "perf" do

    Reaction.Polymer.compile(@rules)
    res = Reaction.run(@formula, @rules, 10, :map_reduce2)

    # Benchee.run(%{
    #   "recursive"    => fn ->
    #     Reaction.run(@formula, @rules, 10, :recursive)
    #   end,
    #   "recursive2"    => fn ->
    #     Reaction.run(@formula, @rules, 10, :recursive2)
    #   end,
    #   "map_reduce_stream" => fn ->
    #     Reaction.run(@formula, @rules, 10, :map_reduce)
    #   end,
    # })


  end
end
