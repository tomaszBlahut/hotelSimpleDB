import json
from dbHelpers import executeQuery

def roomInfo(jsonParams):
	return executeQuery("select * from project1.roomInfo;")

def getRoomCategories(jsonParams):
	return executeQuery("select * from project1.roomCategory;")

def getExtras(jsonParams):
	return executeQuery("select * from project1.extras;");
