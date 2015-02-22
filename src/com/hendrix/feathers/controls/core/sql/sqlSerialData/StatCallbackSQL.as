package com.hendrix.feathers.controls.core.sql.sqlSerialData
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.net.Responder;

	/**
	 * A bridge wrapper around SQLStatement for making executions with callbacks that return deserialized objects
	 * form the database instead the regular SQLResult
	 * @author Tomer Shalev
	 * 
	 */
	public class StatCallbackSQL
	{
		private var _callback:					Function 			= null;
		private var _flagResInVector:		Boolean 			= false;
		private var _stat:							SQLStatement 	= null;
		
		public function StatCallbackSQL($stat:SQLStatement, $callback:Function = null, $flagResInVector:Boolean = false)
		{
			_callback 				= $callback;
			_flagResInVector	=	$flagResInVector;
			_stat							=	$stat;
		}
		
		public function run():Array
		{
			if(_callback is Function) {
				_stat.execute(-1, new Responder(onSuccess));
				return null;
			}

			_stat.execute(-1, null);
			
			return SQLUtils.sqlToObject(_stat.getResult());	
		}
		
		protected function onSuccess(res:SQLResult):void
		{
			if(_callback is Function)
				_callback(SQLUtils.sqlToObject(res));
		}
			
	}
	
}