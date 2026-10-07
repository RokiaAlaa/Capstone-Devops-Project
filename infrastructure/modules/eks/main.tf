resource "aws_eks_cluster" "main" {
    name = "${var.project_name}-eks"
    role_arn = aws_iam_role.eks_cluster.arn
    version = "1.27"

    vpc_config {
        subnet_ids = concat(var.public_subnets, var.private_subnets)
        endpoint_private_access = true
        endpoint_public_access = true
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy
    ]

    tags = {
        Name = "${var.project_name}-eks"
    }
}

resource "aws_eks_node_group" "main" {
    cluster_name = aws_eks_cluster.main.name
    node_group_name = "${var.project_name}-node-group"
    node_role_arn = aws_iam_role.eks_nodes.arn
    subnet_ids = var.private_subnets
    version = "1.27"

    scaling_config {
        desired_size = 3
        max_size = 5
        min_size = 2
    }

    instance_types = ["t3.medium"]

    depends_on = [
        aws_iam_role_policy_attachment.eks_nodes_policy,
        aws_iam_role_policy_attachment.eks_cni_policy
    ]
}

resource "aws_iam_role" "eks_cluster" {
    name = "${var.project_name}-eks-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_cluster.name
}


resource "aws_iam_role" "eks_nodes" {
    name = "${var.project_name}-eks-nodes-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole" 
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "eks_nodes_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks_nodes.name
}