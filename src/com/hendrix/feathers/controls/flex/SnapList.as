package com.hendrix.feathers.controls.flex
{
  import feathers.controls.renderers.IListItemRenderer;
  import feathers.controls.supportClasses.ListDataViewPort;
  import feathers.core.FeathersControl;
  import feathers.events.FeathersEventType;
  import feathers.layout.HorizontalLayout;
  import feathers.layout.VerticalLayout;
  
  import starling.events.Event;
  
  /**
   * <p>a snapping list: a list that snaps to its closest item after scrolling animation is complete.</p>
   * 
   * <li>supports both <code>HorizontalLayout</code> and <code>VerticalLayout</code>
   * <li><code>this.onSelectedIndex</code> is the callback for listening to the snapped index
   * <li><code>this.selectedIndex</code> is the index of the snapped index
   * <li>use <code>this.scrollToItemWithIndex</code> to scroll to item with specified index
   *  
   * @author Tomer Shalev
   */
  public class SnapList extends FlexList
  {
    protected var _listDataViewport:          ListDataViewPort    = null;
    protected var _currentClosestItemIndex:   int                 = -1;
    
    /**
     * callback for listening to the snapped index
     */
    public var onSelectedIndex:               Function            = null;
    
    /**
     * a snapping list: a list that snaps to its closest item after scrolling animation is complete.
     * <br>
     * <li>supports both <code>HorizontalLayout</code> and <code>VerticalLayout</code>
     * <li><code>this.onSelectedIndex</code> is the callback for listening to the snapped index
     * <li><code>this.selectedIndex</code> is the index of the snapped index
     * <li>use <code>this.scrollToItemWithIndex</code> to scroll to item with specified index 
     * @author Tomer Shalev
     */
    public function SnapList()
    {
      super();
      
      addEventListener(FeathersEventType.INITIALIZE, initialize_onComplete);
    }
    
    /**
     * scroll to item with specified index 
     */
    public function scrollToItemWithIndex(index:uint, animationDuration:Number = 0.1):void
    {
      if(index < 0)
        return;

      if(_listDataViewport == null || (_listDataViewport.numChildren == 0))
        return;
      
      var ir: FeathersControl = _listDataViewport.getChildAt(0) as FeathersControl;
      
      if(ir == null)
        return;
      
      stopScrolling();
      
      if(isHorizontalLayout())
        scrollToPosition(ir.width*(index - 1), verticalScrollPosition, animationDuration);
      else if(isVerticalLayout())
        scrollToPosition(horizontalScrollPosition, ir.height*(index - 1), animationDuration);
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _listDataViewport = null;
      onSelectedIndex   = null;
    }
    
    override protected function draw():void
    {
      super.draw();
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      addEventListener(FeathersEventType.SCROLL_START, listFeed_scrollStartHandler);
    }
    
    private function initialize_onComplete(event:Event):void
    {
      removeEventListener(FeathersEventType.INITIALIZE, initialize_onComplete);
      
      _listDataViewport = getChildAt(0) as ListDataViewPort;
      
      if(!(_listDataViewport is ListDataViewPort))
        throw new Error("Error!!");
    }
    
    private function computeClosestHorizontalItemDistance():Number
    {
      var hsp:                  Number          = horizontalScrollPosition;
      var window:               Number          = width;
      
      var cPoint:               Number          = hsp + window*0.5;
      
      var nirs:                 uint            = _listDataViewport.numChildren;
      
      var closestItemIndex:     int             = -1;
      var closestItemDistance:  Number          = Number.POSITIVE_INFINITY;
      var ir:                   FeathersControl = null;
      var irCPoint:             Number          = 0;//ir.x + ir.width * 0.5;
      var d:                    Number          = NaN;
      
      for(var ix:uint = 0; ix < nirs; ix++) {
        ir                                      = _listDataViewport.getChildAt(ix) as FeathersControl;
        
        irCPoint                                = ir.x + ir.width * 0.5;
        
        d                                       = Math.abs(irCPoint - cPoint);
        
        if(d < Math.abs(closestItemDistance)){
          closestItemDistance                   = -irCPoint + cPoint;
          closestItemIndex                      = ix;
        } 
        
      }
      
      //trace("closestItemIndex: " + closestItemIndex)
      //trace("closestItemDistance: " + closestItemDistance)
      
      _currentClosestItemIndex                  = closestItemIndex;
      
      var res_scrollTo: Number                  = horizontalScrollPosition - closestItemDistance;
      
      return Math.max(minHorizontalScrollPosition, Math.min(maxHorizontalScrollPosition, res_scrollTo)) ;
    }
    
    private function computeClosestVerticalItemDistance():Number
    {
      var vsp:                  Number          = verticalScrollPosition;
      var window:               Number          = height;
      
      var cPoint:               Number          = vsp + window*0.5;
      
      var nirs:                 uint            = _listDataViewport.numChildren;
      
      var closestItemIndex:     int             = -1;
      var closestItemDistance:  Number          = Number.POSITIVE_INFINITY;
      var ir:                   FeathersControl = null;
      var irCPoint:             Number          = 0;//ir.x + ir.width * 0.5;
      var d:                    Number          = NaN;
      
      for(var ix:uint = 0; ix < nirs; ix++) {
        ir                                      = _listDataViewport.getChildAt(ix) as FeathersControl;
        
        irCPoint                                = ir.y + ir.height * 0.5;
        
        d                                       = Math.abs(irCPoint - cPoint);
        
        if(d < Math.abs(closestItemDistance)){
          closestItemDistance                   = -irCPoint + cPoint;
          closestItemIndex                      = (ir as IListItemRenderer).index;
        } 
        
      }
      
      //trace("closestItemIndex: " + closestItemIndex)
      //trace("closestItemDistance: " + closestItemDistance)
      
      _currentClosestItemIndex                  = closestItemIndex;
      
      var res_scrollTo: Number                  = verticalScrollPosition - closestItemDistance;
      
      return Math.max(minVerticalScrollPosition, Math.min(maxVerticalScrollPosition, res_scrollTo)) ;
    }
    
    protected function computeClosestItemDistance():Number
    {
      if(isHorizontalLayout())
        return computeClosestHorizontalItemDistance();
      else if(isVerticalLayout())
        return computeClosestVerticalItemDistance();
      else
        throw new Error("no layout was specified!!!");      
    }
    
    /**
     * delegate for first time that scroll starts handler 
     */
    protected function listFeed_scrollStartHandler(event:Event):void
    {
      removeEventListener(FeathersEventType.SCROLL_START, listFeed_scrollStartHandler);
      //addEventListener(Event.SCROLL, listFeed_scrollHandler);
      addEventListener(FeathersEventType.SCROLL_COMPLETE, listFeed_scrollCompleteHandler);
    }
    
    private function listFeed_scrollCompleteHandler(event:Event):void
    {
      scrollToClosestItem();
    }
    
    protected function scrollToClosestItem():void
    {
      var scrollTo: Number        = Math.floor(computeClosestItemDistance());
      
      var index_changes:  Boolean = (selectedIndex != _currentClosestItemIndex); 
      
      if(index_changes) {
        selectedIndex					    =	_currentClosestItemIndex;	
        
        if(onSelectedIndex is Function)
          onSelectedIndex(_currentClosestItemIndex);
      }
      
      if(scrollTo == Number.POSITIVE_INFINITY)
        return;
      
      //removeEventListener(FeathersEventType.SCROLL_COMPLETE, listFeed_scrollCompleteHandler);
      
      if(isHorizontalLayout())
        scrollToPosition(scrollTo, verticalScrollPosition, 0.4);
      else if(isVerticalLayout())
        scrollToPosition(horizontalScrollPosition, scrollTo, 0.4);
    }
    
    private function isHorizontalLayout():Boolean  { return layout is HorizontalLayout; }
    private function isVerticalLayout():Boolean 
    {
      return layout is VerticalLayout;
    }
    
  }
  
}