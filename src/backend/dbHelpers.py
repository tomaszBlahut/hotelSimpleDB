import json
import psycopg2
from datetime import date, datetime

from psycopg2.extras import RealDictCursor
from decimal import Decimal

error = {'error': False, 'errorMessage': ''}


def default(obj):
	if isinstance(obj, Decimal):
		return str(obj)
	if isinstance(obj, date):
		return obj.isoformat()
	with open("debug.txt", "a") as myfile:
		nowDt = datetime.now()
		myfile.write(nowDt.isoformat() + ": " + "Object of type '"+ type(obj).__name__ +"' is not JSON serializable" + "\n")
	raise TypeError("Object of type '%s' is not JSON serializable" % type(obj).__name__)

def executeQuery(query):
	try:
		conn = psycopg2.connect("dbname='dbname' user='user' host='localhost' password='password'")
	except:
		error['error'] = True
		error['errorMessage'] = "Unable to connect to db"
		return json.dumps(error)

	with open("debug.txt", "a") as myfile:
		nowDt = datetime.now()
		myfile.write(nowDt.isoformat() + ": " + query + "\n")
	cur = conn.cursor(cursor_factory=RealDictCursor)
	conn.autocommit = True
	cur.execute(query)
	return json.dumps(cur.fetchall(), default=default)
