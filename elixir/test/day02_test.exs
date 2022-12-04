defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "day02" do
    input = """
    A Y
    B X
    C Z
    """
    assert Day02.problem1(input, :io) == 15
    assert Day02.problem2(input, :io) == 12
  end
end
