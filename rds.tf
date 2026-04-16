# 1. DB security group 
resource "aws_security_group" "rds" {
  name   = "hal-ec-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC 내부 통신만 허용
  }
}

# 2. RDS instance
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "hal_ec_db"
  username             = "admin"
  password             = "yourpassword123" # 나중에 Secrets Manager로 옮기는 것이 좋음
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
}

# 3. DB subnet group
resource "aws_db_subnet_group" "main" {
  name       = "hal-ec-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# subnet 1
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"
  tags = { Name = "hal-ec-private-1" }
}

# subnet 2 
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1c"
  tags = { Name = "hal-ec-private-2" }
}
