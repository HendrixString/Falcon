package com.hendrix.feathers.controls.widgets
{
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.Image;
  import starling.textures.Texture;
  import starling.textures.TextureSmoothing;
  
  /**
   * a rotating image, appropriate for a loader
   * @author Tomer Shalev
   * 
   */
  public class SimpleLoader extends Image
  {
    private var _tween:           Tween   = null;
    
    /**
     * the height of the original texture 
     */
    private var _heightOriginal:  Number;
    /**
     * the width of the original texture 
     */
    private var _widthOriginal:   Number;
    
    private var _resizedOnce:     Boolean = false;
    
    /**
     * @param texture the texture of the loader
     */
    public function SimpleLoader(texture:Texture)
    {
      super(texture);
      
      visible             = false;
      
      super.pivotX        = width / 2;
      super.pivotY        = height / 2;
      
      _heightOriginal     = height;
      _widthOriginal      = width;
      
      _tween              = new Tween(this, 2);
      _tween.repeatCount  = 0;
      
      this.smoothing      = TextureSmoothing.BILINEAR;
    }
    
    /**
     * start animation 
     */
    public function animateLoading():void
    {
      if(isAnimating)
        return;
      
      visible             = true;
      
      _tween.reset(this, 0.5);
      
      _tween.repeatCount  = 0;
      
      _tween.animate("rotation", rotation + Math.PI*2);
      
      Starling.juggler.add(_tween);
    }
    
    /**
     * stop animation 
     */
    public function animateStop():void
    {
      visible   = false;
      
      Starling.juggler.remove(_tween);
      
      rotation  = 0;
    }
    
    /**
     * @return state pf animation
     */
    public function get isAnimating():Boolean
    {
      return Starling.juggler.contains(_tween);
    }
    
    override public function set pivotX(value:Number):void
    {
    }
    
    override public function set pivotY(value:Number):void
    {
    }
    
    override public function set width(value:Number):void
    {
      _widthOriginal  = value;
      
      super.width     = value;
    }
    
    override public function set height(value:Number):void
    {
      _heightOriginal = value;
      
      super.height    = value;
    }
    
    public function get heightOriginal():Number
    {
      return _heightOriginal;
    }
    
    public function get widthOriginal():Number
    {
      return _widthOriginal;
    }
    
  }
  
}