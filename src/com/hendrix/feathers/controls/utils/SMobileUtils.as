package com.hendrix.feathers.controls.utils
{
  import flash.display.Stage;
  import flash.display.StageAspectRatio;
  import flash.system.Capabilities;
  
  public class SMobileUtils
  {
    /**
     * detect the IOS version 
     */
    static public function detectiOSversion():int
    {
      var os:         String  = Capabilities.os;
      
      var iosString:  String  = "iPhone OS ";
      
      var index:      int     = os.indexOf(iosString); //iPhone OS 6.1.3
      
      if(index == -1)
        return -1;
      
      index                   =  index + iosString.length;
      
      return int(os.charAt(index));
    }
    /**
     * is OS == IOS? 
     */   
    static public function get isIOS():Boolean
    {
      var isApple:  Boolean =  Capabilities.manufacturer.match(/(iOS)|(Macintosh)/) ? true : false;
      
      return isApple;
    }
    
    static public function resolveAspectRatio(stage:Stage):String
    {
      if(stage.stageWidth < stage.stageHeight)
        return StageAspectRatio.PORTRAIT;
      else
        return StageAspectRatio.LANDSCAPE;
    }
    
  }
  
}