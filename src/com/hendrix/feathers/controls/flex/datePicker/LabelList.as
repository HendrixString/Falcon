package com.hendrix.feathers.controls.flex.datePicker
{   
  import com.hendrix.feathers.controls.flex.FlexQuad;
  import com.hendrix.feathers.controls.flex.SnapList;
  
  import feathers.controls.List;
  import feathers.controls.renderers.IListItemRenderer;
  import feathers.data.ListCollection;
  import feathers.layout.HorizontalLayout;
  import feathers.layout.VerticalLayout;
  
  public class LabelList extends SnapList
  {
    private var _quad_top:          FlexQuad  = null;
    private var _quad_bottom:       FlexQuad  = null;
    
    /**
     * the percent height of an item renderer 
     */
    private var _itemPercentHeight: uint      = 35;
    
    public function LabelList()
    {
      super();
    }
    
    public function get itemPercentHeight():uint { return _itemPercentHeight;}
    public function set itemPercentHeight(value:uint):void
    {
      _itemPercentHeight = value;
    }
    
    override public function set dataProvider(value:ListCollection):void
    {
      value.addItemAt(" ", 0);
      value.addItem(" ");
      
      super.dataProvider = value; 
    }
    
    override public function dispose():void
    {
      super.dispose();
    }
    
    override protected function draw():void
    {
      super.draw();
      
      var item_height:  Number  = height * (_itemPercentHeight / 100);
      var pos:          Number  = (height - item_height) * 0.5;
      
      _quad_top.y               = pos - _quad_top.height;
      _quad_bottom.y            = pos + item_height;
      
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      var vLayout:  VerticalLayout          = new VerticalLayout();
      
      vLayout.useVirtualLayout              = false;
      vLayout.manageVisibility              = true;
      vLayout.hasVariableItemDimensions     = true;
      vLayout.horizontalAlign               = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
      vLayout.useVirtualLayout              = true;
      
      clipContent                           = true;
      
      horizontalScrollPolicy                = List.SCROLL_POLICY_OFF;
      verticalScrollPolicy                  = List.SCROLL_POLICY_ON;
      layout                                = vLayout;      
      
      itemRendererFactory                   = factory;
      
      _quad_bottom                          = new FlexQuad(0x00A6E3);
      _quad_top                             = new FlexQuad(0x00A6E3);
      
      _quad_bottom.percentWidth             = 100;
      _quad_bottom.height                   = 2;
      _quad_top.percentWidth                = 100;
      _quad_top.height                      = 2;
      
      addChild(_quad_bottom);
      addChild(_quad_top);
    }
    
    private function factory():IListItemRenderer
    {
      var item: Item                = new Item();
      
      item.percentWidth             = 100;
      item.percentHeight            = _itemPercentHeight;
      item.relativeCalcHeightParent = item.relativeCalcWidthParent = this; 
      
      return item;
    }
    
  }
  
}