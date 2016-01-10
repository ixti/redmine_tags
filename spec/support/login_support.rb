module LoginSupport
  private

  def login_as(user)
    @request.session[:user_id] = user.id
    allow(User).to receive(:current).and_return(user)
  end
end
