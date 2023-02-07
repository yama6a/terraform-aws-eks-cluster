project_name      = "sandbox"
env               = "staging"
high_availability = false
aws_region        = "eu-west-1"

domains = {
  "example.com" = [
    "*.example.com"
  ],
  "example.edu" = [
    "api.example.edu",
    "*.api.example.edu",
    "www.example.edu"
  ],
}

tags = {
  terraformSource = "https://github.com/ymakhloufi/terraform-aws-eks-cluster"
}

services = {
  "my-awesome-service" = {
    create_ecr_repo        = true
    enable_dynamodb_access = true
    eventbus               = true

    postgres_dbs = [
      {
        "db_name"             = "pg-db-name-1"
        "instance_class"      = "db.t4g.micro",
        "multi_az"            = false,
        "deletion_protection" = false,
      },
      {
        "db_name"             = "pg-db-name-2"
        "instance_class"      = "db.t4g.micro",
        "multi_az"            = false,
        "deletion_protection" = false,
      },
    ],

    mysql_dbs = [
      {
        "db_name"             = "mysql-db-name-1"
        "instance_class"      = "db.t4g.micro",
        "multi_az"            = false,
        "deletion_protection" = false,
      },
      {
        "db_name"             = "mqsql-db-name-2"
        "instance_class"      = "db.t4g.micro",
        "multi_az"            = false,
        "deletion_protection" = false,
      },
    ],

    mariadb_dbs = [
      {
        "db_name"             = "mariadb-db-name-1"
        "instance_class"      = "db.t4g.micro",
        "multi_az"            = false,
        "deletion_protection" = false,
      },
      {
        "db_name"             = "mariadb-db-name-2"
        "instance_class"      = "db.t4g.micro",
        "multi_az"            = false,
        "deletion_protection" = false,
      },
    ],
  },
}
