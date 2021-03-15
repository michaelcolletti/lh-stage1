resource "aws_instance" "nodeserver" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.FrontEnd.id]
  key_name                    = var.key_name
  tags = {
    Name = "node"
    env = "dev"
    tier = "api"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y && sudo yum update --security
  sudo yum install python36-pip.noarch nodejs git.x86_64  -y 
  sudo mkdir noderepo;cd noderepo
  sudo curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
  sudo curl -sL curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  sudo pip install npm@latest
  curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo 
  sudo yum install yarn -y
  git clone https://github.com/michaelcolletti/node-app.git && cd node-app 
  npm install -g nodemon && npm install -g newman && npm install -g
  npm run dev 

HEREDOC
}
resource "aws_instance" "webserver" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.FrontEnd.id]
  key_name                    = var.key_name
  tags = {
    Name = "webserver"
    env = "dev"
    tier = "frontend"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo mkdir -p /apps/web
  sudo yum update -y;sudo yum update --security
  sudo yum install git httpd -y 
  sudo systemctl enable httpd;sudo systemctl start httpd

HEREDOC
}

resource "aws_instance" "lhlanding" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.FrontEnd.id]
  key_name                    = var.key_name
  tags = {
    Name = "loudhailer"
    env = "dev"
    tier = "frontend"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo mkdir -p /apps/web
  sudo yum update -y;sudo yum update --security
  sudo yum install git httpd -y 
  sudo systemctl enable httpd;sudo systemctl start httpd

HEREDOC
}
resource "aws_instance" "letsbuki" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.FrontEnd.id]
  key_name                    = var.key_name
  tags = {
    Name = "letsbukiFE"
    env = "dev"
    tier = "frontend"
    proj = "letsbuki"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo mkdir -p /apps/web
  sudo yum update -y;sudo yum update --security
  sudo yum install git httpd -y 
  sudo systemctl enable httpd ;sudo systemctl start httpd
# Copy data from s3 bucket for content
HEREDOC

}

resource "aws_instance" "timeseriesdb" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PrivateAZA.id
  vpc_security_group_ids      = [aws_security_group.Database.id]
  key_name                    = var.key_name
  tags = {
    Name = "TSDB-HIPAA"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  #sleep 180
  #  sudo yum install -y https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  sudo tee /etc/yum.repos.d/timescale_timescaledb.repo <<EOL
[timescale_timescaledb]
name=timescale_timescaledb
baseurl=https://packagecloud.io/timescale/timescaledb/el/7/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/timescale/timescaledb/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOL
  sudo yum update -y
  sudo yum install -y timescaledb-postgresql-12
  sudo systemctl enable timescaledb-postgresql-12 ;sudo systemctl start timescaledb-postgresql-12;sudo service timescaledb-postgresql-12 status 
# sudo echo "exclude=postgres-12" >>/etc/yum.conf 
  sudo -u postgres service postgres-12 start

HEREDOC

}

###############################################
# CONSIDER USING A HOSTED AWS SOLUTION LIKE AMP
###############################################
resource "aws_instance" "monitoring" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.FrontEnd.id]
  key_name                    = var.key_name
  tags = {
    Name = "monitoring"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y;sudo yum update --security 
  sudo mkdir /monitoring;cd /monitoring
  sudo yum install git python36-pip.noarch -y 
  sudo useradd -m -s /bin/bash prometheus
  sudo su - prometheus "wget https://github.com/prometheus/prometheus/releases/download/v2.2.1/prometheus-2.2.1.linux-amd64.tar.gz"
  sudo tar -xzvf prometheus-2.2.1.linux-amd64.tar.gz;sudo mv prometheus-2.2.1.linux-amd64/ prometheus/ 
HEREDOC
}

resource "aws_instance" "kitchensinkjenkins" {
  ami                         = var.AmiLinux[var.region]
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.PublicAZA.id
  vpc_security_group_ids      = [aws_security_group.BuildMon.id]
  key_name                    = var.key_name
  tags = {
    Name = "kitchensinkjenkins"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sudo yum update -y;sudo yum update --security  -y
  sudo yum install git jenkins -y && sudo systemctl enable jenkins; sudo systemctl start jenkins;sudo systemctl status jenkins
  
HEREDOC
}
