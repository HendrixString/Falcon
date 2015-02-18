package com.hendrix.feathers.controls.flex
{
  
  import flash.geom.Point;
  import flash.geom.Rectangle;
  
  import cmodule.shine.isinf;
  import cmodule.shine.isnan;
  
  import feathers.core.IFeathersControl;
  
  import starling.animation.Transitions;
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.DisplayObject;
  import starling.events.Touch;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;
  
  /**
   * a simple wrapper of a FeatherControl to make it zoomable/movable, rotatable.
   * simply extend any new class with this class to get an interactive sprite.
   * @author Tomer Shalev and Starling code snippets from the forum
   */
  public class ZoomContainer extends FlexComp
  {    
    private var _newScaleX:                 Number          = 1;
    private var _newScaleY:                 Number          = 1;
    private var _minScaling:                  Number          = 0;
    private var _maxScaling:                  Number          = Number.MAX_VALUE;
    private var _initialFit:                  Boolean         = false;
    
    private var _zoomTarget:                  DisplayObject   = null;
    
    private var _flagControlChildDimensions:  Boolean         = true;
    
    private var _tweenZoom:                   Tween           = null;
    
    public  var onDrag:                       Function        = null;
    public  var onStoppedDrag:                Function        = null;
    public  var onPinchZoom:                  Function        = null;
    
    /**
     * a simple wrapper of a FeatherControl to make it zoomable/movable, rotatable.
     * simply extend any new class with this class to get an interactive sprite.
     * @author Tomer Shalev and Starling code snippets from the forum
     */
    public function ZoomContainer()
    {
      super();
      
      addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    /**
     * zoom with tweening to into a sub-rectangle area of your Zoom target 
     * @param rect the rectangle to zoom into
     * @param relax how close to the rectangle a number in the domain [0, 1]
     */
    public function zoomToRect(rect:Rectangle, relax:Number = 0.45):void
    {
      _tweenZoom        = _tweenZoom ? _tweenZoom.reset(_zoomTarget, 0.3, Transitions.EASE_IN_BACK) : new Tween(_zoomTarget, 0.3, Transitions.EASE_IN);
      
      Starling.juggler.remove(_tweenZoom);
      
      var arW:  Number  = (relax*width) / (rect.width*1);
      var toX:  Number  = (width -  rect.width*arW )*0.5 - rect.x*arW + _zoomTarget.pivotX*arW;
      var toY:  Number  = (height - rect.height*arW )*0.5 - rect.y*arW + _zoomTarget.pivotY*arW;
      
      _tweenZoom.scaleTo(arW);
      _tweenZoom.moveTo(toX, toY);
      
      Starling.juggler.add(_tweenZoom);
    }
    
    public function get newScaleY():                              Number { return _newScaleY; }
    public function get newScaleX():                              Number
    {
      return _newScaleX;
    }
    
    public function get zoomTarget():                               DisplayObject { return _zoomTarget; }
    public function set zoomTarget(value:DisplayObject):            void
    {
      if(_zoomTarget) {
        _zoomTarget.removeFromParent(true);
        _zoomTarget = null;
      }
      
      _zoomTarget   = value;
      
      if(_zoomTarget == null)
        return;
      
      x             = 0;
      y             = 0;
      scaleX        = 1;
      scaleY        = 1;
      pivotX        = 0;
      pivotY        = 0;
      addChildAt(_zoomTarget, 0);
    }
    
    public function get flagControlChildDimensions():               Boolean { return _flagControlChildDimensions; }
    public function set flagControlChildDimensions(value:Boolean):  void
    {
      _flagControlChildDimensions = value;
    }
    
    public function get initialFit():                               Boolean { return _initialFit; }
    public function set initialFit(value:Boolean):                  void
    {
      _initialFit = value;
    }
    
    public override function dispose():void
    {
      super.dispose();
      
      if(_zoomTarget) {
        _zoomTarget.removeFromParent(true);
        _zoomTarget = null;
      }
    }
    
    protected override function initialize():void
    {
      super.initialize();
    }
    
    protected override function draw():void
    {
      super.draw();
      
      var alignInvalid: Boolean = isInvalid(INVALIDATION_FLAG_ALIGN);
      
      if(_zoomTarget) {
        if(_flagControlChildDimensions) {
          _zoomTarget.width     = width;
        }
      }
      
      if(_initialFit) {
        if(_zoomTarget is IFeathersControl)
          (_zoomTarget as IFeathersControl).validate();
        
        var arW:  Number        = width   / _zoomTarget.width;
        var arH:  Number        = height  / _zoomTarget.height;
        var ar:   Number        = Math.max(arW, arH);
        
        if(width && height && ar && !isinf(ar)) {
          trace("** " + arW + "x" + arH)
          _zoomTarget.scaleX    = _zoomTarget.scaleY  = ar;
          _initialFit           = false;
        }
      }
      
      if(alignInvalid)
        applyAlignment();
    }
    
    private function onTouch(event:TouchEvent):void
    {
      if(_zoomTarget == null)
        return;
      
      var touches:    Vector.<Touch> = event.getTouches(_zoomTarget, TouchPhase.MOVED);
      var hasStopped: Boolean        = event.getTouches(_zoomTarget, TouchPhase.ENDED).length;
      
      if(hasStopped) {
        trace("has stopped");
        if(onStoppedDrag is Function)
          onStoppedDrag();
      }
      
      if (touches.length == 1)
      {
        // one finger touching -> move
        var delta:  Point            = touches[0].getMovement(_zoomTarget);
        
        _zoomTarget.x               += delta.x*_zoomTarget.scaleX;
        _zoomTarget.y               += delta.y*_zoomTarget.scaleX;
        
        //trace("delta " + delta)
        
        if(onDrag is Function)
          if(delta.x || delta.y)
            onDrag();
      }            
      else if (touches.length >= 2)
      {
        // two fingers touching -> rotate and scale
        var touchA:         Touch   = touches[0];
        var touchB:         Touch   = touches[1];
        
        var currentPosA:    Point   = touchA.getLocation(parent);
        var previousPosA:   Point   = touchA.getPreviousLocation(parent);
        var currentPosB:    Point   = touchB.getLocation(parent);
        var previousPosB:   Point   = touchB.getPreviousLocation(parent);
        
        var currentVector:  Point   = currentPosA.subtract(currentPosB);
        var previousVector: Point   = previousPosA.subtract(previousPosB);
        
        var currentAngle:   Number  = Math.atan2(currentVector.y, currentVector.x);
        var previousAngle:  Number  = Math.atan2(previousVector.y, previousVector.x);
        var deltaAngle:     Number  = currentAngle - previousAngle;
        
        // update pivot point based on previous center
        var previousLocalA: Point   = touchA.getPreviousLocation(_zoomTarget);
        var previousLocalB: Point   = touchB.getPreviousLocation(_zoomTarget);
        
        var pivX:Number = (previousLocalA.x + previousLocalB.x) * 0.5;
        var pivY:Number = (previousLocalA.y + previousLocalB.y) * 0.5;
        _zoomTarget.pivotX          = (previousLocalA.x + previousLocalB.x) * 0.5;
        _zoomTarget.pivotY          = (previousLocalA.y + previousLocalB.y) * 0.5;
        
        // update location based on the current center
        _zoomTarget.x               = (currentPosA.x + currentPosB.x) * 0.5;
        _zoomTarget.y               = (currentPosA.y + currentPosB.y) * 0.5;
        
        // rotate
        //rotation += deltaAngle;
        
        // scale
        var sizeDiff: Number        = currentVector.length / previousVector.length;
        
        _newScaleX                = Math.min(Math.max(_zoomTarget.scaleX * sizeDiff, _minScaling), _maxScaling);
        _newScaleY                = Math.min(Math.max(_zoomTarget.scaleY * sizeDiff, _minScaling), _maxScaling);
        
        _zoomTarget.scaleX          = _newScaleX;
        _zoomTarget.scaleY          = _newScaleY;
        
        if(onPinchZoom is Function)
          onPinchZoom();
      }
      
      var touch:  Touch             = event.getTouch(this, TouchPhase.ENDED);
      
      //if (touch && touch.tapCount == 2)
      //parent.addChild(this); // bring self to front
      
      // enable this code to see when you're hovering over the object
      // touch = event.getTouch(this, TouchPhase.HOVER);            
      // alpha = touch ? 0.8 : 1.0;
    }
    
  }
  
}