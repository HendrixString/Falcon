package com.hendrix.feathers.controls.flex.magnifyList
{
  import com.hendrix.feathers.controls.flex.SnapList;
  
  import feathers.controls.List;
  import feathers.controls.renderers.IListItemRenderer;
  import feathers.controls.supportClasses.ListDataViewPort;
  import feathers.core.FeathersControl;
  import feathers.data.ListCollection;
  import feathers.events.FeathersEventType;
  import feathers.layout.HorizontalLayout;
  
  import starling.events.Event;
  
  /**
   * an item magnifying list.
   * 
   * @author Tomer Shalev
   * 
   */
  public class MagnifyList extends SnapList
  {
    protected var _currentMagnifiedItemIndex: int                 = -1;
    
    private var _itemClassType:               Class;
    private var _itemAspectRatio:             Number              = 2; 
    private var _itemPercentHeight:           Number              = 0.75; 
    
    private var _flagOnce:                    Boolean             = false;
    
    public function MagnifyList()
    {
      super();
      
      addEventListener(FeathersEventType.INITIALIZE, initialize_onComplete);
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _listDataViewport = null;
    }
    
    public function get currentMagnifiedItemIndex():int
    {
      return _currentMagnifiedItemIndex;
    }
    
    public function get itemClassType():Class { return _itemClassType;  }
    public function set itemClassType(value:Class):void
    {
      _itemClassType = value;
    }
    
    public function get itemAspectRatio():Number  { return _itemAspectRatio;  }
    public function set itemAspectRatio(value:Number):void
    {
      _itemAspectRatio = value;
    }
    
    public function get itemPercentHeight():Number  { return _itemPercentHeight;  }
    public function set itemPercentHeight(value:Number):void
    {
      _itemPercentHeight = value;
    }
    
    public function reset():void
    {
      if(_listDataViewport == null)
        return;
      
      var nirs:                 uint            = _listDataViewport.numChildren;
      
      if(nirs == 0)
        return;
      
      var ir:                   ItemRendererMagnify = null;
      
      for(var ix:uint = 0; ix < nirs; ix++) {
        ir                                      = _listDataViewport.getChildAt(ix) as ItemRendererMagnify;
        ir.reset();
      }
      
    }
    
    override public function set dataProvider(value:ListCollection):void
    {
      super.dataProvider = value;
      reset();
    }
    
    override protected function listFeed_scrollStartHandler(event:Event):void
    {
      super.listFeed_scrollStartHandler(event);
      
      addEventListener(Event.SCROLL, listFeed_scrollHandler);
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      var hLayout:  HorizontalLayout        = new HorizontalLayout();
      
      hLayout.useVirtualLayout              = false;
      hLayout.manageVisibility              = true;
      hLayout.hasVariableItemDimensions     = true;
      hLayout.horizontalAlign               = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
      
      clipContent                           = true;
      
      horizontalScrollPolicy                = List.SCROLL_POLICY_ON;
      verticalScrollPolicy                  = List.SCROLL_POLICY_OFF;
      layout                                = hLayout;
      
      itemRendererFactory                   = factory;      
    }
    
    override protected function draw():void
    {
      
      var hLayout: HorizontalLayout = layout as HorizontalLayout;
      hLayout.paddingLeft   = hLayout.paddingRight  = (width - height*_itemPercentHeight*_itemAspectRatio)*0.52;//layout.gap*2;
      
      super.draw();
      
      if(!_flagOnce) {
        scrollToItemWithIndex(0);
        _flagOnce = true;
      }
    }
    
    private function initialize_onComplete(event:Event):void
    {
      removeEventListener(FeathersEventType.INITIALIZE, initialize_onComplete);
      
      _listDataViewport = getChildAt(0) as ListDataViewPort;
      
      if(!(_listDataViewport is ListDataViewPort))
        throw new Error("Error!!");
    }
    
    private function listFeed_scrollHandler(event:Event):void
    {
      var ir:   FeathersControl         = null;
      var sf:   Number                  = 1;
      var nirs: uint                    = _listDataViewport.numChildren;
      
      for(var ix:uint = 0; ix < nirs; ix++) {
        ir                              = _listDataViewport.getChildAt(ix) as FeathersControl;
        
        sf                              = calculateScaleFactorOfItem(ir);
        
        ir.height                       = height*sf;//, ir.minHeight);
      }
      
      
      var prevClosestItemIndex: int     = _currentClosestItemIndex;
      var cid:                  Number  = computeClosestItemDistance();
      
      _currentMagnifiedItemIndex        = _currentClosestItemIndex;
      
      if(_currentClosestItemIndex != prevClosestItemIndex)  {
        stopScrolling()
        super.scrollToClosestItem();
      }
      
    }
    
    private function calculateScaleFactorOfItem(ir:FeathersControl):Number
    {     
      var hsp:        Number          = horizontalScrollPosition;
      var window:     Number          = width;
      
      var cPoint:     Number          = hsp + window*0.5;
      
      var irCPoint:   Number          = ir.x + ir.width * 0.5;
      
      var normalized: Number          = Math.abs(irCPoint - cPoint) * (1 / (window * 1.5));
      
      var factor:     Number          = 1 - Math.min(normalized, 1);
      
      return factor;
    }
    
    private function factory():IListItemRenderer
    {
      var item: ItemRendererMagnify = new ItemRendererMagnify() as ItemRendererMagnify;
      
      item.itemClassType  = _itemClassType;
      item.ar = _itemAspectRatio;
      item.percentHeight  = _itemPercentHeight;
      
      return item;
    }
    
  }
  
}