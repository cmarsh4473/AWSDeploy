def lambda_handler(event, context):
    # Simple JSON response for API Gateway HTTP API
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": '{"message": "Hello from container Lambda!"}'
    }
