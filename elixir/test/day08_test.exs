defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "day08" do
    input = """
    30373
    25512
    65332
    33549
    35390
    """
    assert Day08.problem1(input, :io) == 21
    assert Day08.problem2(input, :io) == 8
  end
end
