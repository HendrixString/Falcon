package com.hendrix.feathers.controls.core.sql.sqlSerialData
{
	import com.hendrix.feathers.controls.utils.serialize.Serialize;
	
	import flash.data.SQLResult;

	public class SQLUtils
	{
		public function SQLUtils()
		{
		}
		
		static public function sqlToObject(res:SQLResult):Array
		{
			if(res==null && res.data==null)
				return null;
			
			var arr:Array = res.data;
			
			var countArr:uint = arr.length;
			
			for (var ix:int = 0; ix < countArr; ix++) 
			{
				arr[ix].data = Serialize.stringToObject(arr[ix].data);
			}
			
			return arr;
		}
	}
}