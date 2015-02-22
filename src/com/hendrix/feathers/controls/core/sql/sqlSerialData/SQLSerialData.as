package com.hendrix.feathers.controls.core.sql.sqlSerialData
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class SQLSerialData
	{
		private var _dbName: 		String				= null;
		private var _dbPath: 		File					= null;
		
		private var _mapTables:	Dictionary  	= null;
		
		private var	_version:		uint					=	0;

		public function SQLSerialData($dbPath:File, dbName: String)
		{
			_dbName 		= dbName;

			_dbPath			=	$dbPath;
			
			_mapTables	=	new Dictionary();
		}
		
		public function addTable(tableName:String):SQLSerialData
		{
			if(_mapTables[tableName] !== undefined)
				return this;
			
			var ssdt: SQLSerialDataTable  = new SQLSerialDataTable(_dbPath, _dbName, tableName);
			
			_mapTables[tableName] = ssdt;
			
			return this;
		}
		
		public function getTable(tableName: String):SQLSerialDataTable
		{
			return (_mapTables[tableName] === undefined) ? null : _mapTables[tableName];
		}

		public function get dbName():String
		{
			return _dbName;
		}

		public function get dbPath():File
		{
			return _dbPath;
		}

	}
}