defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "day05" do
    input = """
        [D]
    [N] [C]
    [Z] [M] [P]
     1   2   3

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
    assert Day05.problem1(input, :io) == "CMZ"
    assert Day05.problem2(input, :io) == "MCD"
  end
end
