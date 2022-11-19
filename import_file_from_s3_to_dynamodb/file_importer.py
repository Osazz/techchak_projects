
"""

When creating dynamodb table, make your :
- pkey = id : Type Number
- skey = first_name : Type String
- create
- after creating
- open the table
- click on explore table item
- click on  create item
- click on Add new attribute and add the remaining columns, leave type as string
"""


"""
ADD VALUE HERE - amywhere you see this please change the value to the correct value 

"""

import boto3
import csv

###################################################################
###########   Getting csv file from our s3 bucket     #############
###################################################################
bucket_name = "ADD VALUE HERE "
cvs_file_name = "ADD VALUE HERE"

s3 = boto3.client('s3')
csv_obj = s3.get_object(Bucket=bucket_name, Key=cvs_file_name)
csv_obj_data = csv_obj['Body'].read().decode('utf-8').splitlines()

###################################################################
######   Converting json result from s3 to a lsit dict      #######
###################################################################
# create a dictionary
data = {}

csvReader = csv.DictReader(csv_obj_data)
for rows in csvReader:

    key = rows['id']
    data[key] = rows


# Convert dict to list
dictlist = []
for __, value in data.items():
    dictlist.append(value)


###################################################################
######   Sending our object to dynamobd table               #######
###################################################################
dynamodb_client = boto3.client('dynamodb')

for val in dictlist:
    temp_dic = {
        "id": {'N': f"{val['id']}"},
        "first_name": {'S': f"{val['first_name']}"},
        "last_name": {'S': f"{val['last_name']}"},
        "email": {'S': f"{val['email']}"},
        "gender": {'S': f"{val['gender']}"},
        "ip_address": {'S': f"{val['ip_address']}"}
    }
    dynamodb_client.put_item(TableName="sample", Item=temp_dic)


