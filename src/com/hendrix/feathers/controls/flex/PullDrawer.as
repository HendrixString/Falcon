package com.hendrix.feathers.controls.flex
{
  import flash.geom.Rectangle;
  
  import feathers.core.FeathersControl;
  import feathers.core.IFeathersControl;
  import feathers.layout.HorizontalLayout;
  
  import starling.animation.Transitions;
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.DisplayObject;
  
  /**
   * <p>a pull drawer component,<br>
   * i.e: have a control that hides a drawer, and that drawer can be opened, it is oppsite
   * from Feather's Drawers, that's why i had to implement a new one</p>
   * <ul>
   * <li>set <code>this.mainContent, this.drawerContent, this.mainContentBackgroundSkin, this.drawerContentBackgroundSkin</code> to specify contents</li>
   * <li>set <code>contentPercentWidth, drawerContentPercentWidth, horizontalAlign</code> to control layout if contents are not responsive/flex comps</li>
   * <li>use <code>isDrawerOpen</code> to figure out drawer state</li>
   * <li>use <code>this.toggleDrawer()</code> to open/close the drawer</li>
   * </ul>
   * </p> 
   * a common scenario is to have <code>this.mainContent = new Quad(1,1)</code>, a zero height main content
   * @author Tomer Shalev
   */
  public class PullDrawer extends FlexComp
  {
    public static const INVALIDATION_FLAG_MAIN_CONTENT:       String = "INVALIDATION_FLAG_MAIN_CONTENT";
    public static const INVALIDATION_FLAG_DRAWER_CONTENT:     String = "INVALIDATION_FLAG_DRAWER_CONTENT";
    
    // comps
    /**
     * the main content that hides the drawer 
     */
    private var _mainContent:                 DisplayObject = null;
    /**
     * the drawer content 
     */
    private var _drawerContent:               DisplayObject = null;
    
    // layout
    
    /**
     * content percent width in case mainContent is not responsive/flexcomp 
     */
    private var _contentPercentWidth:         Number        = NaN;
    /**
     * drawer percent width in case _drawerContent is not responsive/flexcomp 
     */
    private var _drawerContentPercentWidth:   Number        = NaN;
    /**
     * the horizontal alignment of the content 
     */
    private var _horizontalAlign:             String        = "center";
    /**
     * the vertical alignment of the content 
     */
    private var _verticalAlign:               String        = "center";
    
    private var _mainContentHeight:           Number        = NaN;
    
    // etc..
    private var _tween:                       Tween         = null;
    
    // info
    
    private var _isDrawerOpen:                Boolean       = false;
    private var _isDrawerAnimatingClose:      Boolean       = false;
    private var _isDrawerAnimatingOpen:       Boolean       = false;
    private var _flagDrawnOnce:               Boolean       = false;
    
    // callbacks
    
    /**
     * callback for when drawer action is complete 
     */
    private var _onTween:                     Function      = null;
    
    /**
     * drawer animation time/speed 
     */
    public var DRAWER_ANIMATION_TIMING:       Number        = 0.33;
    
    /**
     * <p>a pull drawer component,<br>
     * i.e: have a control that hides a drawer, and that drawer can be opened, it is oppsite
     * from Feather's Drawers, that's why i had to implement a new one</p>
     * <ul>
     * <li>set <code>this.mainContent, this.drawerContent, this.mainContentBackgroundSkin, this.drawerContentBackgroundSkin</code> to specify contents</li>
     * <li>set <code>contentPercentWidth, drawerContentPercentWidth, horizontalAlign</code> to control layout if contents are not responsive/flex comps</li>
     * <li>use <code>isDrawerOpen</code> to figure out drawer state</li>
     * <li>use <code>this.toggleDrawer()</code> to open/close the drawer</li>
     * </ul>
     * </p> 
     * a common scenario is to have <code>this.mainContent = new Quad(1,1)</code>, a zero height main content
     * @author Tomer Shalev
     */
    public function PullDrawer()
    {
      super();
      
      _tween  = new Tween(this, 1);
    }
    
    /**
     *  toggle drawer open or close 
     */
    public function toggleDrawer():void
    {
      if(_drawerContent is IFeathersControl) {
        if((_drawerContent as FeathersControl).isInvalid())
          (_drawerContent as FeathersControl).validate();
      }
      
      if(_drawerContent == null)
        return;
      
      Starling.juggler.remove(_tween);
      
      _tween.reset(_drawerContent, DRAWER_ANIMATION_TIMING, Transitions.EASE_OUT);
      
      var cond:   Boolean           = (_isDrawerOpen || _isDrawerAnimatingOpen); 
      var dirUp:  Boolean           = (_isDrawerOpen || (_isDrawerAnimatingOpen == true)); 
      
      if(_isDrawerOpen && (_isDrawerAnimatingClose))
        dirUp                       = false;
      
      switch( dirUp )
      {
        case false:
        {
          _tween.moveTo(_drawerContent.x, _mainContentHeight);
          _tween.onComplete         = function():void {
            _isDrawerOpen           = true
            _isDrawerAnimatingOpen  = false;
            _isDrawerAnimatingClose = false;
          };
          _tween.onUpdate           = function():void {
            height                  = Math.max(_drawerContent.y + _drawerContent.height, _mainContentHeight);
            if(parent is IFeathersControl){
              (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
              (parent as IFeathersControl).validate();
            }
          };
          
          _drawerContent.visible    = true;
          
          clipRect.x                = _mainContent.x;
          clipRect.y                = _mainContent.y;
          clipRect.width            = _mainContent.width;
          clipRect.height           = _mainContentHeight + _drawerContent.height;
          
          _isDrawerAnimatingOpen    = true;
          _isDrawerAnimatingClose   = false;
          
          break;
        }
        case true:
        {
          _tween.moveTo(_drawerContent.x, 0 + _mainContentHeight  - _drawerContent.height); 
          _tween.onComplete         = function():void {
            _isDrawerAnimatingOpen  = false;
            _isDrawerAnimatingClose = false;
            _drawerContent.visible  = false;
            _isDrawerOpen           = false
          };
          _tween.onUpdate           = function():void {
            height                  = Math.max(_drawerContent.y + _drawerContent.height, _mainContentHeight);
            
            if(parent is IFeathersControl){
              (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
              (parent as IFeathersControl).validate();
            }
          };
          
          _isDrawerAnimatingOpen    = false;
          _isDrawerAnimatingClose   = true;
          
          break;
        }
      }
      
      Starling.juggler.add(_tween);
    }
    
    // comps
    
    /**
     * the main content 
     */
    public function get mainContent():                                        DisplayObject { return _mainContent;  }
    public function set mainContent(value:DisplayObject):                     void
    {
      _mainContent = value;
    }
    
    /**
     * the drawer content
     */
    public function get drawerContent():                                      DisplayObject { return _drawerContent;  }
    public function set drawerContent(value:DisplayObject):                   void
    {
      _drawerContent = value;
      
      invalidate(INVALIDATION_FLAG_DRAWER_CONTENT);
      
      if(isInitialized) {
        addChildAt(_drawerContent, 0);
      }
    }
    
    // layout
    
    /**
     *  percent width of the content relative to the component width 
     */
    public function get contentPercentWidth():                      Number        { return _contentPercentWidth;  }
    public function set contentPercentWidth(value:Number):          void
    {
      _contentPercentWidth    = value;
      
      if(_contentPercentWidth > 1)
        _contentPercentWidth = _contentPercentWidth / 100;
    }
    
    /**
     *  percent width of the drawer content relative to the component width 
     */
    public function get drawerContentPercentWidth():                Number        { return _drawerContentPercentWidth;  }
    public function set drawerContentPercentWidth(value:Number):    void
    {
      _drawerContentPercentWidth    = value;
      
      if(_drawerContentPercentWidth > 1)
        _drawerContentPercentWidth  = _drawerContentPercentWidth / 100;
    }
    
    /**
     * listener for the tweening onUpdate event, useful for notifying parent and syblings of this component
     * to relayout themselves when the size of this comp changes. 
     */
    public function get onTween():                                  Function      { return _onTween;  }
    public function set onTween(value:Function):                    void
    {
      _onTween = value;
    }
    
    /**
     * indicates the drawer state
     */
    public function get isDrawerOpen():                             Boolean       { return _isDrawerOpen; }
    public function set isDrawerOpen(value:Boolean):void {
      _isDrawerOpen = value;
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      addChild(_mainContent);
      
      if(_drawerContent)
        addChildAt(_drawerContent, 0);
    }
    
    override protected function draw():void
    {
      super.draw();
      
      if(_flagDrawnOnce == false)
      {
        layout();
        //_flagDrawnOnce  = true;
      }
      
    }
    
    private function layout():void
    {
      trace("drawer")
      
      if(_drawerContent && !_isDrawerAnimatingClose && !_isDrawerAnimatingOpen && !_isDrawerOpen) {
        _drawerContent.visible                    = false;
      }
      
      _mainContent.width                          = width;
      if(isNaN(_mainContentHeight))
        _mainContentHeight                        = _mainContent.height = height;
      
      if(!_isDrawerAnimatingOpen && !_isDrawerAnimatingClose)
        setSizeInternal(width, _mainContentHeight, false);
      
      if(_horizontalAlign == HorizontalLayout.HORIZONTAL_ALIGN_CENTER) {
        _mainContent.x                            = (width - _mainContent.width) * 0.5;
      }
      
      if(_drawerContent && !isNaN(_drawerContentPercentWidth)) {
        _drawerContent.width                      = width * _drawerContentPercentWidth;
      }
      
      if(_drawerContent is FeathersControl)
        (_drawerContent as FeathersControl).validate();
      
      if(_drawerContent)
        _drawerContent.x                          = _mainContent.x + (_mainContent.width - _drawerContent.width) * 0.5;
      
      if(_drawerContent && !_isDrawerAnimatingOpen && !_isDrawerAnimatingClose)
        _drawerContent.y                          = height - _drawerContent.height;
      
      if(_drawerContent && _isDrawerOpen && !_isDrawerAnimatingClose && !_isDrawerAnimatingOpen) {
        _drawerContent.y                          = _mainContentHeight;
        _drawerContent.visible                    = true;
        
        height = _mainContentHeight + _drawerContent.height;
        if(parent is IFeathersControl){
          (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
          (parent as IFeathersControl).validate();
        }
        
      }
      
      clipRect                                    = clipRect ? clipRect : new Rectangle();
      
      if(!_isDrawerAnimatingOpen && !_isDrawerAnimatingClose)
      {
        clipRect.x                                = _mainContent.x;
        clipRect.y                                = _mainContent.y;
        clipRect.width                            = width;
        clipRect.height                           = height;
      }
      
      var sizeInvalid:    Boolean                 = isInvalid(INVALIDATION_FLAG_SIZE);
      
      if(sizeInvalid) {
        if(parent is IFeathersControl){
          (parent as FeathersControl).invalidate(INVALIDATION_FLAG_LAYOUT);
          (parent as IFeathersControl).validate();
        }
        
      }
      
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      Starling.juggler.remove(_tween);
      
      _mainContent    = null;
      _drawerContent  = null;
      _tween          = null;
    }
    
  }
  
}