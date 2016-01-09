module LoginSupport
  private

  def login_as_admin
    admin = create :admin
    @request.session[:user_id] = admin.id
    allow(User).to receive(:current).and_return(admin)
  end
end
