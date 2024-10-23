from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

user_data = {}
with open('user_credentials.txt', 'r') as f:
    for line in f:
        username, port, password = line.strip().split(':')
        user_data[username] = {
            "port": port,
            "password": password
        }

allocated_users = {}
allocated_ports = set() 

@app.route('/', methods=['GET'])
def index():
    return render_template('index_utf8.html')

@app.route('/allocate', methods=['POST'])
def allocate():
    student_id = request.form.get('student_id')
    
    if student_id in allocated_users:
        return jsonify(allocated_users[student_id])

    for username, credentials in user_data.items():
        if username not in allocated_users.values() and credentials["port"] not in allocated_ports:
            allocated_users[student_id] = {
                "username": username,
                "port": credentials["port"],
                "password": credentials["password"]
            }
            allocated_ports.add(credentials["port"])
            return jsonify(allocated_users[student_id])

    return jsonify({"error": "No available containers."}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)