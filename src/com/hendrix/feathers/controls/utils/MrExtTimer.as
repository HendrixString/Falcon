package com.hendrix.feathers.controls.utils
{
  import flash.utils.Timer;
  
  public class MrExtTimer extends Timer
  {
    public var message: String;
    
    public function MrExtTimer(delay:Number, repeatCount:int=0)
    {
      super(delay, repeatCount);
    }
    
  }
  
}