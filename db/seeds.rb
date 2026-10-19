[ "サンプルクラブA", "サンプルクラブB" ].each do |name|
  Club.find_or_create_by!(name: name)
end

[ "テクノ", "ハウス", "ヒップホップ" ].each do |name|
  Tag.find_or_create_by!(name: name)
end

if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  Admin.find_or_create_by!(email: ENV.fetch("ADMIN_EMAIL")) do |admin|
    admin.password = ENV.fetch("ADMIN_PASSWORD")
    admin.password_confirmation = ENV.fetch("ADMIN_PASSWORD")
  end
end
