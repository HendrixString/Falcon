package com.hendrix.feathers.controls.core.sql.sqlSerialData
{	
	import com.hendrix.feathers.controls.utils.serialize.Serialize;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	public class SQLSerialDataTable
	{
		// Database Name
		private var _DATABASE_NAME:				String;
		
		// Contacts table name
		private var _TABLE_NAME:					String;
		
		// Contacts Table Columns names
    protected static const KEY_ID:		String 					= "id";
    protected static const KEY_DATA:	String 					= "data";

		protected var _connection:				SQLConnection		=	null;
		
		private var _dbName:						String 					= null;
		private var _dbPath:						File 						= null;

		public function SQLSerialDataTable($dbPath:File, dbName:String, tableName:String)
		{
			_DATABASE_NAME 			= dbName; 
			_TABLE_NAME 				= tableName;
			_dbPath							=	$dbPath;

			openDatabase();
		}
		
		public function close():void
		{
			_connection.close();
		}

		public function openDatabase():void
		{
			//var dbFile:	File 	= File.documentsDirectory.resolvePath("test");
			
			//dbFile.createDirectory();

			//dbFile 						= File.documentsDirectory.resolvePath("test/" + DATABASE_NAME);
			
			_dbPath.createDirectory();
			
			//_dbPath =  File.documentsDirectory.resolvePath("dbtest/" + DATABASE_NAME);;//_dbresolvePath(DATABASE_NAME + ".db");
			var f:File = new File( _dbPath.resolvePath(DATABASE_NAME + ".db").nativePath );
			
			_dbPath.createDirectory();

			_connection 			= new SQLConnection();

			_connection.open(f, SQLMode.CREATE);
			
			createOrGetTable();
		}
		
		public function createOrGetTable(event:SQLEvent = null):void
		{
			if(_connection.connected == false)
				return;
			
			var stat:SQLStatement = new SQLStatement();
			
			stat.sqlConnection = _connection;
			stat.text = "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " (" + KEY_ID + " TEXT PRIMARY KEY, " + KEY_DATA + " TEXT)";
			
			stat.execute(-1, null);//new Responder(selectItems));
			stat.getResult();
		}
		
		/**
		 * Select latest data with limit
		 * @param limit the max amount of latest objects
		 * @param callback a callback
		 * @return Array result, or null and Array into callback
		 */
		public function getAllData(limit:uint, callback:Function = null):Array
		{
			if(_connection.connected == false)
				return null;
			
			var stat:	SQLStatement 	= new SQLStatement();
			
			stat.sqlConnection 			= _connection;
			stat.text = "SELECT * FROM " + TABLE_NAME + " ORDER BY " + KEY_ID + " DESC" + " LIMIT " + limit;
			
			// todo add pool of StatCallbackSQL
			var statcb:	StatCallbackSQL = new StatCallbackSQL(stat, callback);
			
			return statcb.run();
		}
		
		/**
		 * Select data from a window of identifiers. useful when ids are timestamps.
		 * requires QA.
     * 
		 * @param idFrom starting id
		 * @param idTo last id
		 * @param callback a callback
     * 
		 * @return Array result, or null and Array into callback
		 */
		public function getDataBetween(idFrom:String, idTo:String, callback:Function = null):Array
		{
			if(_connection.connected == false)
				return null;
			
			var stat:	SQLStatement 	= new SQLStatement();
			
			stat.sqlConnection 					= _connection;
			stat.text = "SELECT id, data FROM " + TABLE_NAME + " WHERE id BETWEEN @idFrom AND @idTo ORDER BY " + KEY_ID + " DESC";
			stat.parameters["@idFrom"] 	= idFrom;
			stat.parameters["@idTo"] 		= idTo;

			// todo add pool of StatCallbackSQL
			var statcb:	StatCallbackSQL = new StatCallbackSQL(stat, callback);
			
			return statcb.run();
		}
		
		/**
		 * Select data by it's ID
		 * @param id the id of the data
		 * @return the data
		 */
		public function getData(id:String):Object
		{
			if(_connection.connected == false)
				return null;
			
			var stat: SQLStatement 	= new SQLStatement();
			
			stat.sqlConnection 			= _connection;
			
			stat.text = 'SELECT id, data FROM ' + TABLE_NAME + ' WHERE id=@id';
			stat.parameters["@id"] = id;
			
			stat.execute(-1, null);
			
			var arrRes:	Array 			= SQLUtils.sqlToObject(stat.getResult()); 
			
			var res:		Object 			= (arrRes && arrRes[0]) ? arrRes[0].data : null;
			
			return res;
		}
		
		/**
		 * add new data, or update an older one with the correct conflict algorithm
		 * @param id the id of the data
		 * @param data the data
		 */
		public function addData(id: String, data:Object):void
		{
			if(_connection.connected == false)
				return ;
			
			var stat:	SQLStatement 		= new SQLStatement();
			
			stat.sqlConnection 				= _connection;
			stat.text = "INSERT OR REPLACE INTO " + TABLE_NAME + " (id, data) VALUES (@id, @data)";
			stat.parameters["@id"] 		= id;
			stat.parameters["@data"] 	= Serialize.objectToString(data);
			stat.execute(-1, null);
		}

		/**
		 * update an already existing data by ID
		 * @param id the id of the data
		 * @param data the updated data
		 * @return the number of rows affected
		 */
		public function updateData(id:String, data:Object):void
		{
			if(_connection.connected == false)
				return ;
			
			var stat:	SQLStatement 		= new SQLStatement();
			
			stat.sqlConnection 				= _connection;
			stat.text = "UPDATE " + TABLE_NAME + " SET data=@data WHERE id=@id";// + id;//itemList.selectedItem.data.id;
			stat.parameters["@data"] 	= Serialize.objectToString(data);
			stat.parameters["@id"] 		= id;
			stat.execute(-1, null);
		}

		/**
		 * delete data by ID
		 * @param id the id of the data
		 */
		public function deleteData(id:String):void
		{
			if(_connection.connected == false)
				return;
			
			var stat:	SQLStatement 	= new SQLStatement();
			
			stat.sqlConnection 			= _connection;
			stat.text 							= "DELETE FROM " + TABLE_NAME + " WHERE id=@id";
			stat.parameters["@id"] 	= id;
			
			stat.execute(-1, null);
		}

		public function get DATABASE_NAME():String
		{
			return _DATABASE_NAME;
		}

		public function get TABLE_NAME():String
		{
			return _TABLE_NAME;
		}


		/*
		public function createNewRecord(id:String, data:String):void
		{
			if(_connection.connected == false)
				return ;
			
			var stat:SQLStatement = new SQLStatement();
			stat.sqlConnection = _connection;
			stat.text = "INSERT INTO user (id, data) VALUES (@id, @data)";
			stat.parameters["@id"] = id;
			stat.parameters["@data"] = data;
			stat.execute(-1, null);//new Responder(selectItems));
		}
		
		
		public function updateRecord(id:String, data:String):void
		{
			if(_connection.connected == false)
				return ;
			
			var stat:SQLStatement = new SQLStatement();
			stat.sqlConnection = _connection;
			stat.text = "UPDATE user SET data=@data WHERE id=@id";// + id;//itemList.selectedItem.data.id;
			stat.parameters["@data"] = data;
			stat.parameters["@id"] = id;
			stat.execute(-1, null);//new Responder(selectItems));
		}
		
		public function updateOrCreateRecord(id:String, data:String):void
		{
			if(_connection.connected == false)
				return ;
			
			var stat:SQLStatement = new SQLStatement();
			stat.sqlConnection = _connection;
			stat.text = "SELECT id FROM user WHERE id=@id";
			stat.parameters["@id"] = id;
			stat.execute(-1, null);//new Responder(selectItems));
			var result:SQLResult = stat.getResult();
			stat.clearParameters();
			
			if(!result.data || result.data.length==0) {
				createNewRecord(id, data);
			}
			else {
				updateRecord(id, data);
			}
			
		}
		*/
	}
}