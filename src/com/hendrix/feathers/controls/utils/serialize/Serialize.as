package com.hendrix.feathers.controls.utils.serialize
{
	import flash.utils.ByteArray;

	public class Serialize
	{
		static private var _byteArray:ByteArray = new ByteArray();
		
		/**
		 * do not forget to use registerClassAlias() inside the serialized class for any custom type
		 */
		public function Serialize()
		{
		}
		
		static public function byteArrayToString(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		static public function objectToString(obj:Object):String
		{
			_byteArray.position 	= 0;
			_byteArray.length 		= 0;
			_byteArray.writeObject(obj);

			return Base64.encodeByteArray(_byteArray);
		}
		
		static public function stringToObject(data:String):Object
		{
			var ba:	ByteArray = Base64.decodeToByteArray(data);
			ba.position 			= 0;
			return ba.readObject();
		}
	}
}