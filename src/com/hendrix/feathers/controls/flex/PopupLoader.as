package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.widgets.SimpleLoader;
  
  import flash.text.TextFormat;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  import starling.textures.Texture;
  
  /**
   * a generic popup with singleline label, and possibly an animation with dark background 
   * <li>use <code>this.close()</code> to close the popup
   * <li>use <code>this.textureLoadingAnimation</code> to set the Texture of the loading rotating animation 
   * <li>use <code>this.backgroundSkin</code> to set the skin of the background
   * <li>use <code>this.text</code> to set the text of the label 
   * <li>use <code>this.textFormat</code> to set the textFormat of the label 
   * @author Tomer Shalev
   */
  public class PopupLoader extends FlexComp
  {
    /**
     * the Texture of the loading rotating animation 
     */
    private var _textureLoadingAnimation: Texture       = null;
    private var _sl:                      SimpleLoader  = null;
    
    /**
     * the skin of the background 
     */
    private var _backgroundSkin:          DisplayObject = null;
    
    /**
     * set the text of the label 
     */
    private var _text:                    String        = null;
    /**
     * set the textFormat of the label 
     */
    private var _textFormat:              TextFormat    = null;
    private var _lblMessage:              FlexLabel     = null;
    
    private var _quadDark:                Quad          = null;
    
    /**
     * a generic popup with singleline label, and possibly an animation with dark background 
     * <li>use <code>this.close()</code> to close the popup
     * <li>use <code>this.textureLoadingAnimation</code> to set the Texture of the loading rotating animation 
     * <li>use <code>this.backgroundSkin</code> to set the skin of the background
     * <li>use <code>this.text</code> to set the text of the label 
     * <li>use <code>this.textFormat</code> to set the textFormat of the label 
     * @author Tomer Shalev
     */
    public function PopupLoader()
    {
      super();
    }
    
    public function close(dispose:Boolean = false):void
    {
      if(_quadDark)
        _quadDark.removeFromParent(dispose);
      
      if(_sl)
        _sl.animateStop();
      
      this.removeFromParent(dispose);
    }
    
    /**
     * the Texture of the loading rotating animation 
     */
    public function get textureLoadingAnimation():              Texture       { return _textureLoadingAnimation;  }
    public function set textureLoadingAnimation(value:Texture): void
    {
      _textureLoadingAnimation = value;
    }
    
    /**
     * the skin of the background 
     */
    override public function get backgroundSkin():                       DisplayObject { return _backgroundSkin; }
    override public function set backgroundSkin(value:DisplayObject):    void
    {
      _backgroundSkin = value;
    }
    
    /**
     * set the textFormat of the label 
     */
    public function get textFormat():                           TextFormat    { return _textFormat; }
    public function set textFormat(value:TextFormat):           void
    {
      _textFormat = value;
    }
    
    /**
     * set the text of the label 
     */
    public function get text():                                 String        { return _text; }
    public function set text(value:String):                     void
    {
      _text = value;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      if(_textureLoadingAnimation) {
        _textureLoadingAnimation.dispose();
        _textureLoadingAnimation.base.dispose();
      }
      
      _textureLoadingAnimation  = null;
      _sl                       = null;
      _textFormat               = null;
      _lblMessage               = null;
      
      if(_quadDark)
        _quadDark.removeFromParent(true);
      
      _quadDark                 = null;
    }
    
    override protected function feathersControl_addedToStageHandler(event:Event):void
    {
      super.feathersControl_addedToStageHandler(event);
      
      if(!isInitialized)
        return;
      
      parent.addChild(_quadDark);
      parent.swapChildren(this,_quadDark);
      
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      horizontalCenter                              = 0;
      verticalCenter                                = 0;
      
      if(_textureLoadingAnimation)
        _sl                                           = new SimpleLoader(_textureLoadingAnimation);
      
      _lblMessage                                   = new FlexLabel();
      _lblMessage.textRendererProperties.textFormat = _textFormat;
      _lblMessage.textRendererProperties.embedFonts = true;
      
      _quadDark                                     = new Quad(1, 1, 0x00);
      _quadDark.alpha                               = 0.4;
      
      parent.addChild(_quadDark);
      parent.swapChildren(this, _quadDark);
      
      addChild(_backgroundSkin);
      
      if(_sl)
        addChild(_sl);
      
      addChild(_lblMessage);
    }
    
    override protected function draw():void
    {
      super.draw();
      
      var sizeInvalid:Boolean       = isInvalid(INVALIDATION_FLAG_SIZE);
      
      if(sizeInvalid == false)
        return;
      
      var w:  Number                = width;
      var h:  Number                = height;
      
      //
      
      _quadDark.width               = parent.width;
      _quadDark.height              = parent.height;
      
      _backgroundSkin.width         = w;
      _backgroundSkin.height        = h;
      
      
      if(_sl) {
        _sl.height                    = h*0.65;
        _sl.width                     = _sl.height;
        _sl.x                         = w - (_sl.width*0.75);
        _sl.y                         = (h) * 0.5;
      }
      
      _lblMessage.text                = _text;
      _lblMessage.percentHeight       = 35;
      _lblMessage.horizontalCenter    = 0;
      _lblMessage.verticalCenter      = 0;
      
      if(_sl)
        _sl.animateLoading();
    }
    
  }
  
}