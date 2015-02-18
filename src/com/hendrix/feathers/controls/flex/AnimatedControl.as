package com.hendrix.feathers.controls.flex
{       
  
  import starling.animation.Transitions;
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.events.Event;
  
  /**
   * animated control 
   * @author Tomer Shalev
   * 
   */
  public class AnimatedControl extends FlexComp
  { 
    public static var ANCHOR_TOP:           String          = "ANCHOR_TOP";
    public static var ANCHOR_BOTTOM:        String          = "ANCHOR_BOTTOM";
    
    protected var _animating:               Boolean;
    protected var _open:                    Boolean;
    protected var _animateWhenAddedToStage: Boolean;
    
    /**
     * animate y destination 
     */
    public var animateToY:                  Number          = NaN;
    /**
     * animate y start 
     */
    public var animateFromY:                Number          = NaN;
    /**
     * animate x start 
     */
    public var animateToX:                  Number          = NaN;
    /**
     * animate x start 
     */
    public var animateFromX:                Number          = NaN;
    
    public var anchorPosition:              String          = ANCHOR_TOP;
    
    /**
     * open animation time in seconds 
     */
    public var animateOpenPopUpTime:        Number          = 0.7;
    /**
     * close animation time in seconds 
     */
    public var animateClosePopUpTime:       Number          = 0.5;
    
    public var fitHeight:                   Number;
    
    /**
     * callback for close complete 
     */
    public var onClosed:                    Function        = null;
    /**
     * callback for open complete 
     */
    public var onOpened:                    Function        = null;
    
    private var _tween:                     Tween           = null;
    
    public function AnimatedControl($animateWhenAddedToStage:Boolean)
    {
      super();
      
      _animateWhenAddedToStage  = $animateWhenAddedToStage;
      
      _open                     = false;
      
      visible                   = true;
      
      _tween                    = new Tween(this, 0.5);
    }
    
    /**
     * toggle open/close 
     */
    public function toggle():void
    {
      if(_open)
        animateClosePopUp(true);
      else
        animatePopUp();
    }
    
    /**
     * animate open 
     */
    public function animatePopUp():void
    {
      visible                     = true;
      Starling.juggler.removeTweens(this);
      
      _tween.reset(this, animateOpenPopUpTime, Transitions.EASE_OUT);
      _animating                  = true;
      
      //validate();
      
      var finalAnimateToY:Number  = isNaN(animateToY) ? y : animateToY;
      var finalAnimateToX:Number  = isNaN(animateToX) ? x : animateToX;
      
      if(anchorPosition == ANCHOR_BOTTOM) {
        finalAnimateToY -= fitHeight; 
      }
      
      _tween.moveTo(finalAnimateToX, finalAnimateToY);
      _tween.delay                = 0.0;
      _tween.onComplete           = onAniComplete;
      
      Starling.juggler.add(_tween);
    }
    
    /**
     * animate close 
     */
    public function animateClosePopUp($callBackAtComplete:Boolean = true):void
    {
      Starling.juggler.removeTweens(this);
      
      if(_tween == null)
        return;
      
      _tween.reset(this, animateClosePopUpTime, Transitions.LINEAR);
      _animating                    = true;
      
      var finalAnimateFromY:Number  = isNaN(animateFromY) ? y : animateFromY;
      var finalAnimateFromX:Number  = isNaN(animateFromX) ? x : animateFromX;
      
      _tween.moveTo(finalAnimateFromX, finalAnimateFromY);
      _tween.onComplete             = onPopUpClosed;
      
      var args: Array               = new Array();
      args.push($callBackAtComplete);
      
      _tween.onCompleteArgs         = args;
      
      Starling.juggler.add(_tween);
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _tween = null;
      
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    /**
     * is open 
     */
    public function get open():       Boolean { return _open;       }
    /**
     * is animating 
     */
    public function get animating():  Boolean { return _animating;  }
    
    private function onAddedToStage(event:Event):void
    {
      removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
      
      if(_animateWhenAddedToStage)
        animatePopUp();
    }
    
    protected function onAniComplete():void
    {
      _animating                  = false;
      _open                       = true;
      
      if(onOpened is Function)
        onOpened();
    }
    
    protected function onPopUpClosed($callBackAtComplete:Boolean  = true):void
    {
      //visible                     = false;
      
      Starling.juggler.removeTweens(this);
      
      _open                       = false;
      _animating                  = false;
      
      if($callBackAtComplete == false)
        return;
      
      if(onClosed is Function)
        onClosed();
    }
    
  }
  
}