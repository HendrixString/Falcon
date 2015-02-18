package com.hendrix.feathers.controls.flex.magnifyList
{
  import com.hendrix.collection.common.interfaces.IData;
  import com.hendrix.feathers.controls.flex.ItemRendererBase;
  
  import feathers.controls.Button;
  import feathers.controls.List;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * a horizontal magnifying list itemrenderer container. we use it because of feathers retardation.
   * updating the width of the items live when scrolling will create huge invalidations to the layout
   * engine resulting in huge bottlenecks.
   * @author Tomer Shalev
   * 
   */
  public class ItemRendererMagnify extends ItemRendererBase
  {
    private var _quadBg:        Quad              = null;
    
    private var _item:          DisplayObject     = null;
    
    private var _itemClassType: Class;
    
    private var _flagSetup:     Boolean           = false;
    
    private var _minHeightComp: Number;
    private var _ar:            Number            = 2;
    private var _percentHeight: Number            = 0.75;
    
    private var _btn:           Button            = null;
    
    public function ItemRendererMagnify()
    {
      super();
    }
    
    override public function set owner(value:List):         void
    {
      super.owner = value;
      
      //owner.addEventListener(Event.SCROLL, listFeed_scrollHandler);
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _quadBg = null;
      _item   = null;
      _btn    = null;
    }
    
    public function reset():void
    {
    }
    
    override public function set data(value:Object):void
    {
      super.data              = value;
      
      if(!(_item is IData))
        throw new Error("item must implement IData interface!!!");
      
      (_item as IData).data   = value;
    }
    
    public function get itemClassType():Class { return _itemClassType; }
    public function set itemClassType(value:Class):void
    {
      _itemClassType = value;
    }
    
    public function get ar():Number { return _ar;}
    public function set ar(value:Number):void
    {
      _ar = value;
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      _quadBg   = new Quad(1,1,0x00ff00);
      
      _item     = new _itemClassType() as DisplayObject;
      
      _btn      = new Button();
      _btn.addEventListener(Event.TRIGGERED, btn_onTriggered);
      
      addChild(_item);
      addChild(_btn);
    }
    
    override protected function draw():void
    {
      var sizeInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var dataInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_DATA);
      
      //if(dataInvalid)
      //_flagSetup = false;
      
      if(_flagSetup == false) {
        layoutSetup();
        _flagSetup              = true;
      }
      
      if(!(sizeInvalid || dataInvalid))
        return;
      
      layoutScale();
    }
    
    private function layoutScale():void
    {
      var h:  Number      = Math.max(height, _minHeightComp);
      var w:  Number      = width;//h*2;//owner.width*0.6;
      
      var sf: Number      = h/_minHeightComp;
      
      _item.height = owner.height*_percentHeight*sf;
      _item.width = width*0.81*sf;
      
      _item.x             = (w  - _item.width)*0.5;
      _item.y             = (owner.height  - _item.height)*0.5;
      
      _btn.x              = _item.x;
      _btn.y              = _item.y;
      _btn.width          = _item.width;
      _btn.height         = _item.height;
    }
    
    private function layoutSetup():void
    {
      var h:  Number      = owner.height*_percentHeight;
      var w:  Number      = h*_ar;//owner.width*0.6;
      
      setSizeInternal(w, height, false);
      
      _minHeightComp      = h;
    }
    
    private function btn_onTriggered(event:Event):void
    {
      dispatchEventWith(Event.TRIGGERED, true, _item);
    }   
    
    private function listFeed_scrollHandler(event:Event):void {}
    
  }
  
}