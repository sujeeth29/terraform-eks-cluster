##-------Vpc for eks cluster -----------
resource "aws_vpc" "eks-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Eks-vpc"
    }
}
##-----------Internate gate way------
resource "aws_internet_gateway" "mygw-1" {
    vpc_id = aws_vpc.eks-vpc.id
    tags = {
        Name = "my-igw-1"
    }
}

##--------Public subnets--------
resource "aws_subnet" "pub1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "public-1"
    }
}
resource "aws_subnet" "pub2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "public-2"
    }
}
##--------Public route-table------------
resource "aws_route_table" "public-route" {
    vpc_id = aws_vpc.eks-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.mygw-1.id
    }
    tags = {
        Name = "eks-public-route"
    } 
}
##--------public subnets association to route table---------
resource "aws_route_table_association" "pub-subnet1" {
    route_table_id = aws_route_table.public-route.id
    subnet_id = aws_subnet.pub1.id
}
resource "aws_route_table_association" "pub-subnet2" {
    route_table_id = aws_route_table.public-route.id
    subnet_id = aws_subnet.pub2.id
}

##---------private subnets--------------
resource "aws_subnet" "pri1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "private-1"
    }
}
resource "aws_subnet" "pri2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "Private-2"
    } 
}

##----------Nat-gate-way-----------
resource "aws_eip" "eip-1" {
    vpc = true
}

resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.eip-1.id
    subnet_id = aws_subnet.pub1.id
}

##-----------private route tables --------------------
resource "aws_route_table" "private1" {
    vpc_id = aws_vpc.eks-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id
    }
    tags = {
      Name = "eks-private-route-1"
    }
}

resource "aws_route_table" "private2" {
    vpc_id = aws_vpc.eks-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id
    }
    tags = {
        Name = "eks-private-route-2"
    }
}

#-----------private route table subnets association------------------
resource "aws_route_table_association" "pri-rt1" {
    route_table_id = aws_route_table.private1.id
    subnet_id = aws_subnet.pri1.id  
}

resource "aws_route_table_association" "pri-rt2" {
    route_table_id = aws_route_table.private2.id
    subnet_id = aws_subnet.pri2.id
}

##-----------security groups ------------------
resource "aws_security_group" "eks-sg-1" {
    vpc_id = aws_vpc.eks-vpc.id
    description = "eks-security group 1"
    tags = {
      Name = "eks-sg-1"
    }
}
#sg-2
resource "aws_security_group" "eks-sg-2" {
    vpc_id = aws_vpc.eks-vpc.id
    description = "eks-security group 2"
    tags = {
      Name = "eks-sg-2"
    }
}
#sg-3
resource "aws_security_group" "eks-sg-3"{
    vpc_id = aws_vpc.eks-vpc.id
    description = "No description"
    tags = {
        Name = "eks-sg-3"
    }
}

#-ingress rule -1
resource "aws_vpc_security_group_ingress_rule" "ingress-sg1-1" {
    security_group_id = aws_security_group.eks-sg-1.id
    cidr_ipv4 = aws_security_group.eks-sg-1.id
    from_port = 0
    to_port = 0
    ip_protocol = "-1" 
}
resource "aws_vpc_security_group_ingress_rule" "ingress-sg1-2" {
    security_group_id = aws_security_group.eks-sg-1.id
    cidr_ipv4 = aws_security_group.eks-sg-2.id
    from_port = 0
    to_port = 0
    ip_protocol = "-1" 
}
##--------sg-2-ingress
resource "aws_vpc_security_group_ingress_rule" "ingress-sg2-1" {
    security_group_id = aws_security_group.eks-sg-2.id
    cidr_ipv4 = aws_security_group.eks-sg-1.id
    from_port = 0
    to_port = 0
    ip_protocol = "-1" 
}
resource "aws_vpc_security_group_ingress_rule" "ingress-sg2-2" {
    security_group_id = aws_security_group.eks-sg-2.id
    cidr_ipv4 = aws_security_group.eks-sg-2.id
    from_port = 0
    to_port = 0
    ip_protocol = "-1" 
}