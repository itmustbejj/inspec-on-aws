my_user = 'jhudson@chef.io'

control "aws_iam_user recall" do
  describe aws_iam_user(username: my_user) do
    it { should exist }
  end
end

control "aws_iam_user properties" do
  describe aws_iam_user(username: my_user) do
    it { should have_mfa_enabled }
    it { should have_console_password }
    its('access_keys.count') { should eq 1 }
  end

  describe aws_iam_user(username: my_user) do
    it { should have_console_password }
  end

  aws_iam_user(username: my_user).access_keys.each { |access_key|
    describe access_key.access_key_id do
      subject { access_key }
     its('status') { should eq 'Active' }
    end
  }
end
