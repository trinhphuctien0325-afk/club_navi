class UsersRegistrationsController < Devise::RegistrationsController
  before_action :reject_guest, only: [:edit, :update, :destroy]

    def after_sign_out_path_for(resource_or_scope)
    new_user_registration_path
  end
  private

  def reject_guest
    if current_user&.guest?
      redirect_to posts_path, alert: "ゲストは登録情報を変更できません"
    end
  end
end