package com.hendrix.feathers.controls.flex.mainWindow.ext.hamMainWindow
{
  import com.hendrix.feathers.controls.flex.AnimatedControl;
  import com.hendrix.feathers.controls.flex.mainWindow.interfaces.IMainWindow;
  import com.hendrix.feathers.controls.core.ExtScreenNavigator;
  
  import feathers.events.FeathersEventType;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  import starling.events.Touch;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;
  
  /**
   * a Hamburger window<br>
   * <b>Notes</b>
   * <li>use <code>sideMenu</code> for adding a side menu, sizing will be automatic according to the ham animation</li>
   * <li>use <code>hamProperties</code> to inject properties for the animation</li>
   * <br><b>TODO:</b> add support for LEFT TO RIGHT
   * @author Tomer Shalev
   */
  public class HamMainWindow extends AnimatedControl implements IMainWindow
  {
    public static const INVALIDATION_FLAG_HAM_PROPERTIES: String                  = "HAM_PROPERTIES";
    
    protected var _navigator:                             ExtScreenNavigator        = null;
    
    private var _hamProperties:                           HamProperties           = null;
    
    private var _drawer:                                  DisplayObject           = null;
    
    private var _overlay:                                 Quad                    = null;
    
    public function HamMainWindow()
    {     
      super(false);
      
      _hamProperties                        = new HamProperties();
      
      _hamProperties.animateOpenPopUpTime   = 0.5; 
      _hamProperties.animateClosePopUpTime  = 0.5;
      _hamProperties.animateToXPercent      = 0;
      _hamProperties.animateFromXPercent    = 0;
      
      this.onClosed                         = onHamClosed;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _navigator    = null;
      
      if(_drawer) {
        _drawer.removeFromParent(true);
        _drawer     = null;
      }
    }
    
    /**
     * animates the hamburger side to side 
     */
    public function animateHamburger():void
    {
      commitChanges();
      
      if(this.open) {
        _overlay.removeEventListener(TouchEvent.TOUCH, overlay_onTouched);
        this.animateClosePopUp();
        
        removeChild(_overlay);
      }
      else {
        if(_drawer)
          _drawer.visible = true;
        animatePopUp();
        
        _overlay.addEventListener(TouchEvent.TOUCH, overlay_onTouched);
        
        addChild(_overlay);
        
        _overlay.width    = width;
        _overlay.height   = height;
      }
    }
    
    public function get navigator():ExtScreenNavigator  { return _navigator;  }
    
    public function navigator_onTransitionComplete(event:Event):void
    {
      trace(_navigator.activeScreen);
    }
    public function navigator_onTransitionStart(event:Event):void
    {
      trace("transition starts: " + _navigator.activeScreen);
    }
    
    /**
     * <p>set Ham properties with the following keys: <br>
     * <ul>
     * <li><code>hamProperties.animateOpenPopUpTime</code></li> - duration of opening animation
     * <li><code>hamProperties.animateClosePopUpTime</code></li> - duration of closing animation
     * <li><code>hamProperties.animateToXPercent</code></li> - open state x coordinate relative
     * <li><code>hamProperties.animateFromXPercent</code></li> - closed state x coordinate, usually 0
     * </ul>
     * </p> 
     * @param value key/value object
     * 
     */
    public function get hamProperties():            HamProperties { return _hamProperties;  }
    
    /**
     * use this to add a side menu for the Hamburger window 
     */
    public function get drawer():                     DisplayObject { return _drawer; }
    public function set drawer(value:DisplayObject):  void
    {
      if(_drawer)
        parent.removeChild(_drawer);
      _drawer         = value;
      //_sideMenu.visible = false;
      //parent.addChildAt(_sideMenu, 0);
    }
    
    override protected function initialize():void
    {
      _navigator  = new ExtScreenNavigator();
      
      _navigator.addEventListener(FeathersEventType.TRANSITION_COMPLETE,  navigator_onTransitionComplete);
      _navigator.addEventListener(FeathersEventType.TRANSITION_START,     navigator_onTransitionStart);
      
      addChildAt(_navigator, 0);
      
      _navigator.removeAllScreens();
      
      _overlay  = new Quad(1, 1, 0x00000000);
      _overlay.alpha  = 0.0;
    }
    
    /**
     * by default navigator takes up all screen, you probably want to override it becasue main window can have
     * a static action bar and tab bar etc...
     */
    override protected function draw():void
    {
      
      if(_drawer) {
        if(_drawer && _drawer.parent == null)
          parent.addChildAt(_drawer, 0);
        _drawer.width               = Math.abs(_hamProperties.animateToXPercent - _hamProperties.animateFromXPercent) * width;
        _drawer.height              = height;
        _drawer.x                   = width - _drawer.width;
        
        if(open)
          _drawer.visible           = true;
        else
          _drawer.visible           = false;        
        
      }
      
    }
    
    private function onHamClosed():void
    {
      if(_drawer)
        _drawer.visible = false;
    }
    
    private function overlay_onTouched(event:TouchEvent):void
    {
      trace();
      var touches:Vector.<Touch> = event.getTouches(_overlay, TouchPhase.BEGAN);
      
      if(touches && touches.length) {
        if(_animating == false)
          animateHamburger();
      }
      
    }
    
    private function commitChanges():void
    {
      animateOpenPopUpTime  = _hamProperties.animateOpenPopUpTime; 
      animateClosePopUpTime = _hamProperties.animateClosePopUpTime;
      animateToX            = _hamProperties.animateToXPercent*width;
      animateFromX          = _hamProperties.animateFromXPercent*width;
    }
    
  }
  
}