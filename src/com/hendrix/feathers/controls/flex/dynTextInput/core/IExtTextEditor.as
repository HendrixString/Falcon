package com.hendrix.feathers.controls.flex.dynTextInput.core
{
  import flash.display.BitmapData;
  import flash.text.TextField;
  
  public interface IExtTextEditor
  {
    function get measureTextField():TextField;
    function getSnapShotBitmapData():BitmapData;
  }
}