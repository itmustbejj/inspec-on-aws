tfstate_file = ::File.read('terraform.tfstate')
outputs = JSON.parse(tfstate_file)['modules'][0]['outputs'].map {|k,v| [k, v['value']]}.to_h
webserver_id = outputs['ec2_instance.webserver']
database_id = outputs['ec2_instance.database']
webserver_name = outputs['ec2_instance.webserver.name']
database_name = outputs['ec2_instance.database.name']
image_id = outputs['image_id']
vpc_id = outputs['vpc.id']
pub_subnet_id = outputs['subnet.public.id']
priv_subnet_id = outputs['subnet.private.id']
security_group_ssh_id = outputs['security_group.ssh.id']
security_group_mysql_id = outputs['security_group.mysql.id']
security_group_web_id = outputs['security_group.web.id']

describe aws_ec2_instance(name: webserver_name) do
  it { should be_running }
  its('image_id') { should eq image_id }
  its('instance_type') { should eq 't2.micro' }
  its('vpc_id') { should eq vpc_id }
  its('subnet_id') { should eq pub_subnet_id }
  its('security_group_ids') { should include security_group_ssh_id }
  its('security_group_ids') { should include security_group_web_id }
end

describe aws_ec2_instance(name: database_name) do
  it { should be_running }
  its('image_id') { should eq image_id }
  its('instance_type') { should eq 't2.micro' }
  its('public_ip_address') { should_not be }
  its('vpc_id') { should eq vpc_id }
  its('subnet_id') { should eq priv_subnet_id }
  its('security_group_ids') { should include security_group_ssh_id }
  its('security_group_ids') { should include security_group_mysql_id }
end

describe aws_vpc(vpc_id) do
  its('state') { should eq 'available' }
  its('cidr_block') { should eq '10.0.0.0/16' }
end

describe aws_subnet(pub_subnet_id) do
  it { should exist }
  its('vpc_id') { should eq vpc_id }
  its('cidr_block') { should cmp '10.0.1.0/24' }
  its('availability_zone') { should eq 'us-west-2a' }
end

describe aws_subnet(priv_subnet_id) do
  it { should exist }
  its('vpc_id') { should eq vpc_id }
  its('cidr_block') { should cmp '10.0.100.0/24' }
  its('availability_zone') { should eq 'us-west-2a' }
end

describe aws_security_group(security_group_ssh_id) do
  it { should exist }
  its('vpc_id') { should eq vpc_id }
  it { should allow_in_only(port: 22) }
  it { should_not allow_in(port: 631, ipv4_range: "0.0.0.0/0") }
end

describe aws_security_group(security_group_web_id) do
  it { should exist }
  its('vpc_id') { should eq vpc_id }
  it { should allow_in_only(port: 80) }
end

describe aws_security_group(security_group_mysql_id) do
  its('vpc_id') { should eq vpc_id }
  it { should exist }
  it { should allow_in_only(port: 3306, ipv4_range: ["10.0.100.0/24", "10.0.1.0/24"])}
end
