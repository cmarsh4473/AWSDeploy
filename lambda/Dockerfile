FROM public.ecr.aws/lambda/python:3.11

# Copy function code
COPY app.py ${LAMBDA_TASK_ROOT}/

# Set the CMD to your handler (filename.function)
CMD ["app.lambda_handler"]
