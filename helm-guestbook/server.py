from flask import Flask

# Create a Flask web application instance
app = Flask(__name__)

# Define a route for the root URL '/'
@app.route('/')
def hello_world():
    # Return a simple greeting
    return 'Hello, World from Docker 03!'

# Run the Flask application if this script is executed directly
if __name__ == '__main__':
    # '0.0.0.0' makes the server accessible from any IP address
    # 'port=80' specifies the port the server will listen on
    app.run(host='0.0.0.0', port=80)

