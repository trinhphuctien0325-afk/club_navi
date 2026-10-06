["サンプルクラブA", "サンプルクラブB"].each do |name|
  Club.find_or_create_by!(name: name)
end

["テクノ", "ハウス", "ヒップホップ"].each do |name|
  Tag.find_or_create_by!(name: name)
end