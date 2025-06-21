from flask import Flask

# Create a Flask web application instance
app = Flask(__name__)

# Define a route for the root URL '/'
@app.route('/')
def hello_world():
    # Return a simple greeting
    response_date = '2025-06-21 10:51:24' # This is your hardcoded date from the file
    print(f"Flask app serving 'Hello, World from Docker!' with date: {response_date}", flush=True) # ADD 'flush=True' HERE
    return f'Hello, World from Docker! date: {response_date}' # Modify this to use the variable


# Run the Flask application if this script is executed directly
if __name__ == '__main__':
    # '0.0.0.0' makes the server accessible from any IP address
    # 'port=80' specifies the port the server will listen on
    app.run(host='0.0.0.0', port=80)