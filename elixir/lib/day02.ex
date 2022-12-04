defmodule Day02 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim
    |> String.split("\n")
    |> Enum.map(fn x -> x |> String.split(" ") end)
  end

  def round_result(move1, move2) do
    case {move1, move2} do
      {:rock, :rock} -> :tie
      {:rock, :paper} -> :two
      {:rock, :scissors} -> :one
      {:paper, :rock} -> :one
      {:paper, :paper} -> :tie
      {:paper, :scissors} -> :two
      {:scissors, :rock} -> :two
      {:scissors, :paper} -> :one
      {:scissors, :scissors} -> :tie
    end
  end

  def implied_move(opp_move, result) do
    case {opp_move, result} do
      {:rock, :one} -> :scissors
      {:rock, :tie} -> :rock
      {:rock, :two} -> :paper
      {:paper, :one} -> :rock
      {:paper, :tie} -> :paper
      {:paper, :two} -> :scissors
      {:scissors, :one} -> :paper
      {:scissors, :tie} -> :scissors
      {:scissors, :two} -> :rock
    end
  end

  def score_round(x, y) do
    opp_move = %{"A" => :rock, "B" => :paper, "C" => :scissors}[x]
    my_move = %{"X" => :rock, "Y" => :paper, "Z" => :scissors}[y]
    move_score = case my_move do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
    result_score = case round_result(opp_move, my_move) do
      :one -> 0
      :tie -> 3
      :two -> 6
    end
    move_score + result_score
  end

  def score_round2(x, y) do
    opp_move = %{"A" => :rock, "B" => :paper, "C" => :scissors}[x]
    result = %{"X" => :one, "Y" => :tie, "Z" => :two}[y]
    move_score = case implied_move(opp_move, result) do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
    result_score = case result do
      :one -> 0
      :tie -> 3
      :two -> 6
    end
    move_score + result_score
  end

  def problem1(input \\ "data/day02.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.map(fn [x, y] -> score_round(x, y) end)
    |> Enum.sum
  end

  def problem2(input \\ "data/day02.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.map(fn [x, y] -> score_round2(x, y) end)
    |> Enum.sum
  end
end
