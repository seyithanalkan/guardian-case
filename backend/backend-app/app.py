from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2
import boto3
import json

app = Flask(__name__)
CORS(app)

# Function to fetch the cluster name dynamically containing "dev"
def get_dev_cluster_name():
    eks_client = boto3.client('eks')
    response = eks_client.list_clusters()
    for cluster in response['clusters']:
        if 'dev' in cluster:  # Check if "dev" is part of the cluster name
            return cluster  # Return the first cluster name that matches
    raise Exception("No EKS cluster with 'dev' found")

# Function to fetch the RDS identifier dynamically containing "dev"
def get_dev_rds_identifier():
    rds_client = boto3.client('rds')
    response = rds_client.describe_db_instances()
    for db_instance in response['DBInstances']:
        if 'dev' in db_instance['DBInstanceIdentifier']:  # Check if "dev" is part of the DB identifier
            return db_instance['DBInstanceIdentifier']  # Return the first DB identifier that matches
    raise Exception("No RDS instance with 'dev' found")

# Function to fetch the secret ID dynamically containing "rds"
def get_rds_secret_id():
    client = boto3.client('secretsmanager')
    secrets = client.list_secrets()
    for secret in secrets['SecretList']:
        if 'rds' in secret['Name']:  # Check if "rds" is part of the secret name
            return secret['Name']  # Return the first secret found that matches
    raise Exception("No RDS secret found")

# Function to fetch secrets from Secrets Manager
def get_db_credentials():
    client = boto3.client('secretsmanager')
    secret_id = get_rds_secret_id()  # Automatically fetch the secret ID
    secret_value = client.get_secret_value(SecretId=secret_id)
    secret_dict = json.loads(secret_value['SecretString'])
    return secret_dict['db_username'], secret_dict['db_password'], secret_dict['db_name']

# Function to fetch the RDS endpoint automatically using the filtered DB identifier
def get_rds_endpoint(rds_identifier):
    client = boto3.client('rds')
    response = client.describe_db_instances(DBInstanceIdentifier=rds_identifier)
    endpoint = response['DBInstances'][0]['Endpoint']['Address']  # Extract the RDS endpoint
    return endpoint

# Database connection
def get_db_connection(rds_identifier):
    db_username, db_password, db_name = get_db_credentials()
    db_host = get_rds_endpoint(rds_identifier)  # Automatically fetch the RDS endpoint using DB identifier
    conn = psycopg2.connect(
        host=db_host,
        database=db_name,
        user=db_username,
        password=db_password
    )
    return conn

# Function to check and create the table if it doesn't exist
def ensure_table_exists(rds_identifier):
    conn = get_db_connection(rds_identifier)
    cursor = conn.cursor()

    # Create the table if it doesn't exist
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS node_group (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255),
        hostname VARCHAR(255)
    );
    """)
    
    conn.commit()
    cursor.close()
    conn.close()

# Function to fetch EC2 instances for each node group and insert node names and hostnames into the database
def import_node_details(cluster_name, rds_identifier):
    eks_client = boto3.client('eks')
    ec2_client = boto3.client('ec2')
    autoscaling_client = boto3.client('autoscaling')

    # Fetch node groups in the EKS cluster
    response = eks_client.list_nodegroups(clusterName=cluster_name)
    nodegroups = response['nodegroups']

    conn = get_db_connection(rds_identifier)
    cursor = conn.cursor()

    for nodegroup in nodegroups:
        nodegroup_info = eks_client.describe_nodegroup(
            clusterName=cluster_name,
            nodegroupName=nodegroup
        )
        # Get the Auto Scaling Group name for the node group
        asg_name = nodegroup_info['nodegroup']['resources']['autoScalingGroups'][0]['name']
        
        # Use the Auto Scaling Group name to describe the instances in the group
        asg_info = autoscaling_client.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name]
        )
        
        instance_ids = [instance['InstanceId'] for instance in asg_info['AutoScalingGroups'][0]['Instances']]

        # Describe the EC2 instances to get details like private DNS names (hostnames)
        instances = ec2_client.describe_instances(InstanceIds=instance_ids)

        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                node_name = nodegroup_info['nodegroup']['nodegroupName']
                node_hostname = instance['PrivateDnsName']  # Get the private DNS name (hostname)

                # Insert into the database
                cursor.execute(
                    "INSERT INTO node_group (name, hostname) VALUES (%s, %s)",
                    (node_name, node_hostname)
                )
    
    conn.commit()
    cursor.close()
    conn.close()

@app.route("/", methods=["GET"])
def health_check():
    return jsonify({"message": "Healthy"}), 200

@app.route("/nodes", methods=["GET"])
def get_nodes():
    # Fetch the cluster name and RDS identifier dynamically
    cluster_name = get_dev_cluster_name()
    rds_identifier = get_dev_rds_identifier()

    conn = get_db_connection(rds_identifier)
    cursor = conn.cursor()
    cursor.execute("SELECT name, hostname FROM node_group")
    nodes = cursor.fetchall()
    conn.close()
    return jsonify(nodes)

if __name__ == "__main__":
    # Fetch the cluster name and RDS identifier dynamically
    cluster_name = get_dev_cluster_name()
    rds_identifier = get_dev_rds_identifier()

    # Ensure the table exists before importing node details
    ensure_table_exists(rds_identifier)
    # Import node details (names and hostnames) when starting the application
    import_node_details(cluster_name, rds_identifier)
    app.run(host='0.0.0.0', port=5000)


    ## deploy test###############