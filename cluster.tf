# Create an EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.pub1.id, aws_subnet.pub2.id, aws_subnet.pri1.id, aws_subnet.pri2.id]  # Update with your subnet IDs
    security_group_ids = [aws_security_group.eks-sg-1.id,aws_security_group.eks-sg-2.id]  # Update with your security group ID
  }

  tags = {
    Environment = "development"
  }
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks-cluster-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attach policy to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create node group IAM role
resource "aws_iam_role" "eks_node_group_role" {
  name               = "eks-node-group-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attach policy to the node group role
resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Create a node group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [aws_subnet.pub1.id, aws_subnet.pub2.id]  # Update with your subnet IDs
  tags = {
    Environment = "development"
  }
}
