defmodule Reaction.ReactionTest do
  use ExUnit.Case

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
  test "A" do
    # assert 1588 ==
    Reaction.run(@formula, @rules, 10)
  end

  @tag :skip
  test "B" do
    # assert 2_188_189_693_529 ==
    Reaction.run(@formula, @rules, 40)
  end
end
