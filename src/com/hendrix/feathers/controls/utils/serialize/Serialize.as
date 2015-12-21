package com.hendrix.feathers.controls.utils.serialize
{
	import flash.net.registerClassAlias;
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
      return Base64.encodeByteArray(objectToByteArray(obj));
    }
    
    static public function objectToByteArray(obj:Object, $ba: ByteArray = null):ByteArray
    {
      var ba: ByteArray = $ba ? $ba : new ByteArray();
      
      ba.position 	    = 0;
      
      ba.writeObject(obj);
      
      return ba;
    }
    
		static public function stringToObject(data:String):Object
		{
			var ba:	ByteArray = Base64.decodeToByteArray(data);
			ba.position 			= 0;
			return ba.readObject();
		}
	}
}