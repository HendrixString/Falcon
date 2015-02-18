package com.hendrix.feathers.controls.utils
{
  public class MathUtils
  {
    static public function deg2Rad(deg:Number):Number
    {
      return (Math.PI/180)*deg;
    }
    
    static public function rad2Deg(rad:Number):Number
    {
      return (180/Math.PI)*rad;
    }
  }
}