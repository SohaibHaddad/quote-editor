require "rails_helper"

RSpec.describe "Authentication", type: :request do
  it "redirects the root page to sign in when logged out" do
    get root_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders the sign-in page" do
    get new_user_session_path

    expect(response).to have_http_status(:ok)
  end

  it "signs in with username and password" do
    user = create(:user, password: "password123", password_confirmation: "password123")

    post user_session_path, params: { user: { username: user.username, password: "password123" } }

    expect(response).to redirect_to(root_path)
  end
end
