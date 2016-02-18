module LoginSupport
  private

  def login_as(user)
    @request.session[:user_id] = user.id
    allow(User).to receive(:current).and_return(user)
  end

  def ui_login_user(login, password)
    visit '/my/page'

    expect(current_path).to eq('/login')

    within('#login-form form') do
      fill_in('username', with: login)
      fill_in('password', with: password)
      find('input[name=login]').click
    end

    expect(current_path).to eq('/my/page')
  end
end
