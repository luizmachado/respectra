from flask_socketio import SocketIO 

_socketio = None

def init_socketio(app):
    global _socketio
    if _socketio is None:
        _socketio = SocketIO(app)
    return _socketio

def get_socketio():
    return _socketio
