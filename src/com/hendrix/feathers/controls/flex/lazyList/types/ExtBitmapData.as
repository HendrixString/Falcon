package com.hendrix.feathers.controls.flex.lazyList.types
{
  import com.hendrix.collection.cache.core.interfaces.IIdDisposable;
  
  import flash.display.BitmapData;
  
  public class ExtBitmapData extends BitmapData implements IIdDisposable
  {
    private var _id: String = null;
    
    public function ExtBitmapData(width:int, height:int, transparent:Boolean=true, fillColor:uint=4.294967295E9)
    {
      super(width, height, transparent, fillColor);
    }
    
    public function get id():             String  { return _id;   }
    public function set id(value:String): void    { _id = value;  }
  }
}