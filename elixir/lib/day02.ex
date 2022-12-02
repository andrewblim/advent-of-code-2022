defmodule Day02 do
  def read_input(file) do
    {:ok, file} = File.read(file)
    file
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

  def score_round(opp_move, my_move) do
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

  def score_round2(opp_move, result) do
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

  def read_notation(opp_notation, my_notation) do
    opp_move = %{"A" => :rock, "B" => :paper, "C" => :scissors}[opp_notation]
    my_move = %{"X" => :rock, "Y" => :paper, "Z" => :scissors}[my_notation]
    {opp_move, my_move}
  end

  def read_notation2(opp_notation, result_notation) do
    opp_move = %{"A" => :rock, "B" => :paper, "C" => :scissors}[opp_notation]
    result = %{"X" => :one, "Y" => :tie, "Z" => :two}[result_notation]
    {opp_move, result}
  end

  def problem1() do
    read_input("data/day02.txt")
    |> Enum.map(fn [opp_notation, my_notation] ->
      {opp_move, my_move} = read_notation(opp_notation, my_notation)
      score_round(opp_move, my_move)
    end)
    |> Enum.sum
  end

  def problem2() do
    read_input("data/day02.txt")
    |> Enum.map(fn [opp_notation, my_notation] ->
      {opp_move, my_move} = read_notation2(opp_notation, my_notation)
      score_round2(opp_move, my_move)
    end)
    |> Enum.sum
  end
end
