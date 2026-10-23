class Tag < ApplicationRecord
  def display_name
    {
      "テクノ" => "Techno",
      "ハウス" => "House",
      "ヒップホップ" => "Hip Hop"
    }.fetch(name, name)
  end
end
