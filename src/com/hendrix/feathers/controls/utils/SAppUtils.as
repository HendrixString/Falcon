package com.hendrix.feathers.controls.utils
{
  import flash.desktop.NativeApplication;

  public class SAppUtils
  {
    public function SAppUtils()
    {
    }
    
    /**
     * 
     * @return the app version number as string 
     * 
     */
    static public function getAppVersion():String
    {
      var appXML:XML =  NativeApplication.nativeApplication.applicationDescriptor;
      
      var ns:Namespace = appXML.namespace();
      
      return new String(appXML.ns::versionNumber);    
    }
    
  }
  
}