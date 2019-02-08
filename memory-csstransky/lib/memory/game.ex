defmodule Memory.Game do
  @doc """
  When panel is clicked,
    if panel.hidden == true
      if compare_string == empty
        panel.hidden = false
        compare_string = panel.value

      else compare_string != empty
        if compare_string != panel.value
          short delay (1 sec?)
          panel.hidden = true
          compare_string_panels.hidden = true
          compare_string = ""
        else
          panel.hidden = false
          compare_string = ""

  Process.send_after
  """
  def flip(game, panel_index) do
    compare_string = game.compare_string
    panel = Enum.at(game.panel_list, panel_index)

    if panel.hidden && compare_string != "LOCK" do
      if compare_string == "" do
        panel_first_click(game, panel_index)
      else
        if compare_string != panel.value do
          panel_mismatch_click(game, panel_index)
        else
          panel_match_click(game, panel_index)
        end
      end
    else
      game # Do nothing
    end
  end

  def panel_first_click(game, panel_index) do
    panel = Enum.at(game.panel_list, panel_index)

    game
    |> set_panel_hidden(panel_index, false)
    |> Map.put(:compare_string, panel.value)
  end

  def panel_mismatch_click(game, panel_index) do
    game
    |> set_panel_hidden(panel_index, false)
    |> Map.put(:score, game.score+1)
    |> Map.put(:compare_string, "LOCK")
    |> Map.put(:flip_back_string, game.compare_string)
    |> Map.put(:flip_back_index, panel_index)
  end

  def flip_back(game) do
    if game.flip_back_string != "" do
      game
      |> set_panel_hidden(game.flip_back_index, true)
      |> set_compare_panels_hidden(game.flip_back_string, true)
      |> Map.put(:compare_string, "")
      |> Map.put(:flip_back_string, "")
      |> Map.put(:flip_back_index, -1)
    else
      game
    end
  end

  def panel_match_click(game, panel_index) do
    game
    |> set_panel_hidden(panel_index, false)
    |> Map.put(:compare_string, "")
  end

  def set_panel_hidden(game, panel_index, hidden?) do

    panel_list = Map.get(game, :panel_list)
    |> List.update_at(panel_index,
      fn panel -> Map.put(panel, :hidden, hidden?) end)

    game
    |> Map.put(:panel_list, panel_list)
  end

  def set_compare_panels_hidden(game, compare_string, hidden?) do

    panel_list = Map.get(game, :panel_list)
    |> Enum.map(fn panel ->
      if panel.value == compare_string do
        Map.put(panel, :hidden, hidden?)
      else
        panel
      end
    end)

    game
    |> Map.put(:panel_list, panel_list)
  end

  def reset do
    %{
      panel_list: starting_pair_list(),
      compare_string: "",
      score: 0,
      # These variables are so ugly I can't stand it
      # I can't wait to get rid of them when I get genServer working
      # No hard feelings to Ben who suggested this, but I almost got away with
      # only having 3 objects in my map
      flip_back_string: "",
      flip_back_index: -1,
    }
  end

  def client_view(game) do
    %{
      panel_list: game.panel_list,
      compare_string: game.compare_string,
      score: game.score,
    }
  end

  def starting_pair_list do
    panel_list = ~w{A A B B C C D D E E F F G G H H}

    panel_list
    |> Enum.shuffle
    |> Enum.map(fn letter -> %{value: letter, hidden: true} end)
  end
end
