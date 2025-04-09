# Use an official Python image
FROM python:3.11

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt ./

# Install dependencies
RUN pip install -r requirements.txt

# Copy rest of files
COPY main.py ./

# Expose the port
EXPOSE 8000

# Run the FastAPI app with Uvicorn
CMD ["python3", "main.py"]

