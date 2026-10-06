class UsersRegistrationsController < Devise::RegistrationsController
  before_action :reject_guest, only: [:edit, :update, :destroy]

  private

  def reject_guest
    if current_user&.guest?
      redirect_to posts_path, alert: "ゲストは登録情報を変更できません"
    end
  end
end