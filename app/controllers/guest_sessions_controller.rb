class GuestSessionsController < ApplicationController
  def create
    guest_user = User.create!(
      name: "ゲスト",
      email: "guest-#{SecureRandom.uuid}@example.com",
      password: SecureRandom.hex(20),
      guest: true
    )

    sign_in guest_user
    redirect_to posts_path
  end
end