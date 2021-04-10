import os
import boto3


INSTANCE_ID = os.environ['INSTANCE_ID']
ec2 = boto3.client('ec2')


class InstanceManager:
    @staticmethod
    def status():
        response = ec2.describe_instance_status(
            InstanceIds=[INSTANCE_ID],
            IncludeAllInstances=True
        )

        instance_state = response['InstanceStatuses'][0]['InstanceState']['Name']
        instance_status = response['InstanceStatuses'][0]['InstanceStatus']['Status']

        return \
            f'Server state is {instance_state} with status {instance_status}', \
            instance_state, \
            instance_status, \
            response

    @staticmethod
    def start():
        ec2.start_instances(
            InstanceIds=[INSTANCE_ID]
        )

    @staticmethod
    def stop():
        ec2.stop_instances(
            InstanceIds=[INSTANCE_ID]
        )
