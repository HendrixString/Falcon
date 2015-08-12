package com.hendrix.feathers.controls.flex
{
  import flash.geom.Point;
  
  import starling.display.DisplayObject;
  import starling.events.Event;
  import starling.events.Touch;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;

  /**
   * a draggable <code>HitButton</code> with the following features
   * <lu>
   *    <li/>this component is <code>HitButton</code> and draggable.
   *    <li/>register <code>DisplayObject</code>s to detect when this object was dropped on them.
   *    <li/>listen to <code>DROP, DROPPED_ON, DRAG</code> events.
   * 
   * 
   * @author Tomer Shalev
   * 
   * @see HitButton
   */
  public class DragHitButton extends HitButton
  {
    /**
     * Event for Dropping the this button 
     */
    public static const DROP:       String = "drop";
    [Event(name="drop", type="starling.events.Event")]
    
    /**
     * Event for Dropping this button on one of the registered DisplayObject.
     */
    public static const DROPPED_ON: String = "droppedOn";
    [Event(name="droppedOn", type="starling.events.Event")]
    
    /**
     * Event for Dragging this button.
     */
    public static const DRAG:       String = "drag";
    [Event(name="drag", type="starling.events.Event")]
    
    /**
     * a helper <code>Point</code> 
     */
    private var _point_helper:        Point     = null;
    private var _isDragged:           Boolean   = false;
    
    private var _expected_flag:       Boolean   = false;
    
    private var callback_onComplete:  Function  = null;
    private var point_aux:            Point     = new Point();
    
    private var _pOriginal_x:         Number    = NaN;
    private var _pOriginal_y:         Number    = NaN;
    /**
     * registered vector of <code>DisplayObject</code> to detect dropping on. 
     */
    private var _dop_dropped:   Vector.<DisplayObject>  = null;
      
    public function DragHitButton()
    {
      super();
      
      _dop_dropped = new Vector.<DisplayObject>();
    }
    
    override public function set x(value:Number):void
    {
      if(isNaN(_pOriginal_x))
        _pOriginal_x = value;
      
      super.x = value;
    }
    
    override public function set y(value:Number):void
    {
      if(isNaN(_pOriginal_y))
        _pOriginal_y = value;

      super.y = value;
    }
    
    public function reset():void
    {
      if(!isNaN(_pOriginal_x))
        x = _pOriginal_x;
      if(!isNaN(_pOriginal_y))
        y = _pOriginal_y;
    }
    
    /**
     * is dragged
     *  
     * @return <code>true/false</code>
     * 
     */
    public function get isDragged():Boolean
    {
      return _isDragged;
    }
    
    /**
     * add <code>DisplayObject</code> to detect this object was dropped on.
     *  
     * @param dop a <code>DisplayObject</code>
     * 
     */
    public function registerDisplayObject(dop: DisplayObject):void
    {
      _dop_dropped.push(dop);
    }

    override protected function feathersControl_addedToStageHandler(event:Event):void
    {
      super.feathersControl_addedToStageHandler(event);
      
      _point_helper = _point_helper ? _point_helper : new Point();
      
      addEventListener(TouchEvent.TOUCH, touchHandler);
    }
    
    override protected function feathersControl_removedFromStageHandler(event:Event):void
    {
      super.feathersControl_removedFromStageHandler(event);
      
      removeEventListener(TouchEvent.TOUCH, touchHandler);
    }

    private function touchHandler(event: TouchEvent = null):void
    {
      if(event == null)
        return;
      
      var touch:    Touch     = event.getTouch(stage);
      
      touch.getLocation(stage, _point_helper);
      
      var target:   HitButton = event.target as HitButton;
      
      if(touch.phase == TouchPhase.MOVED) {
        target.x              = _point_helper.x - target.width/2;
        target.y              = _point_helper.y - target.height/2;

        if(hasEventListener(DRAG))
          dispatchEventWith(DRAG, false, _point_helper);

        _isDragged            = true;
      }
      else if(touch.phase == TouchPhase.ENDED) {
        if(_isDragged) {
          if(hasEventListener(DROP))
            dispatchEventWith(DROP, false, _point_helper);
          
          if(hasEventListener(DROPPED_ON)) {
            for (var ix: int = 0; ix < _dop_dropped.length; ix++) 
            {
              if(_dop_dropped[ix].getBounds(stage).containsPoint(_point_helper))
                dispatchEventWith(DROPPED_ON, false, {dropped: target, dropped_on: _dop_dropped[ix], pos:_point_helper});
            }
          }

          _isDragged          = false;
        }
      }
      else {
      }
      
    }    

  }
  
}