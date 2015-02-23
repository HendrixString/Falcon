package com.hendrix.feathers.controls.flex.labelList
{
  import com.hendrix.feathers.controls.CompsFactory;
  import com.hendrix.feathers.controls.flex.FlexLabel;
  import com.hendrix.feathers.controls.flex.ItemRendererBase;
  
  import flash.text.TextFormat;
  
  import flashx.textLayout.formats.TextAlign;
  
  public class Item extends ItemRendererBase
  {
    private var _lbl_value:FlexLabel = null;
    
    public function Item()
    {
      super();
    }
    
    override public function dispose():void
    {
      super.dispose();
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      var tf_value: TextFormat    = new TextFormat("arial11", 3, 0x3C3C3C);
      
      _lbl_value                  = CompsFactory.newLabel("", tf_value, false, true, TextAlign.CENTER, true) as FlexLabel;
      
      _lbl_value.percentHeight    = 40;
      _lbl_value.horizontalCenter = 0;
      _lbl_value.verticalCenter   = 0;
      
      addChild(_lbl_value);
    }
    
    override protected function draw():void
    {
      super.draw();
    }   
    
    override public function set data(value:Object):void
    {
      super.data = value;
      
      _lbl_value.text = String(_data);
    }       
    
  }
  
}