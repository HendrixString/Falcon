package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.CompsFactory;
  import com.hendrix.feathers.controls.core.imageStreamer.content.BitmapLoader;
  
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.Image;
  import starling.display.Quad;
  import starling.textures.ConcreteTexture;
  import starling.textures.Texture;
  import starling.textures.TextureSmoothing;
  
  /**
   * <p>a Flex comp Image container</p>
   * 
   * <ul>
   *  <li>set <code>scaleMode</code> to <code>SCALEMODE_STRECTH, SCALEMODE_LETTERBOX, SCALEMODE_ZOOM, SCALEMODE_NONE</code></li>
   *  <li>set <code>_forceDisposeConcreteTexture</code> to control disposal of concrete textures</li>
   *  <li>set <code>source</code> to MrGfxManager package paths ala "packA::map", or disk path "../assets/a.png"</li>
   *  </ul>
   * 
   * @author Tomer Shalev
   */
  public class FlexImage extends FlexComp
  {
    static public var SCALEMODE_STRECTH:                String        = "SCALEMODE_STRECTH";
    static public var SCALEMODE_LETTERBOX:              String        = "SCALEMODE_LETTERBOX";
    static public var SCALEMODE_ZOOM:                   String        = "SCALEMODE_ZOOM";
    static public var SCALEMODE_NONE:                   String        = "SCALEMODE_NONE";
    
    static protected const INVALIDATION_FLAG_SCALEMODE: String        = "INVALIDATION_SCALEMODE";
    
    private var _img:                                   Image         = null;
    private var _source:                                Object        = null;
    private var _scaleMode:                             String        = SCALEMODE_LETTERBOX;
    private var _tex:                                   Texture       = null;
    private var _bl:                                    BitmapLoader  = null;
    
    private var _tweenFade:                             Tween         = null;
    
    private var _forceDisposeConcreteTexture:           Boolean       = false;
    private var _flagFadeInLoadedImage:                 Boolean       = false;
    
    private var _flagDebugMode:                         Boolean       = false;
    private var _quad_debug:                            Quad;
    
    /**
     * <p>a Flex comp Image container</p>
     * <ul>
     * <li>set <code>scaleMode</code> to <code>SCALEMODE_STRECTH, SCALEMODE_LETTERBOX, SCALEMODE_ZOOM, SCALEMODE_NONE</code></li>
     * <li>set <code>_forceDisposeConcreteTexture</code> to control disposal of concrete textures</li>
     * <li>set <code>source</code> to MrGfxManager package paths ala "packA::map", or disk path "../assets/a.png"</li>
     * </ul>
     * </p> 
     * @author Tomer Shalev
     */
    public function FlexImage()
    {
      super();
    }
    
    /**
     * 
     * @return the original texture width 
     */
    public function get textureWidth():uint {
      return _tex.width;
    }
    
    /**
     * 
     * @return the original texture height 
     */
    public function get textureHeight():uint {
      return _tex.height;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _source       = null;
      _img          = null;
      _scaleMode    = null;
      
      if(_bl) {
        _bl.dispose();
        _bl         = null;
      }
      
      if((_tex is ConcreteTexture) && (_forceDisposeConcreteTexture || _bl)) {
        _tex.dispose();
        _tex.base.dispose();
        _tex        = null;
      }
      
    }
    
    /**
     * set debug mode of the comp. setting to <code>true</code> will show the background as black. 
     * 
     */
    public function get flagDebugMode():Boolean { return _flagDebugMode; }
    public function set flagDebugMode(value:Boolean):void
    {
      _flagDebugMode        = value;

      _quad_debug           = (_quad_debug == null) ? new Quad(width, height, 0x00) : _quad_debug;

      addChildAt(_quad_debug, 0);

      if(isInitialized) {       
        _quad_debug.width   = width;        
        _quad_debug.height  = height;
      }
      
    }

    /**
     * source can be anything<br>
     * <code>Texture, bitmap class, bitmapdata, bitmap, GfxPackage path, local path</code> 
     */
    public function get source():Object { return _source; }
    public function set source(value:Object):void
    {
      _source   = value;
      
      if(_bl)
        _bl.disposeBitmap();
      
      if(_forceDisposeConcreteTexture && _tex) {
        _tex.dispose();
        _tex.root.dispose();
      }
      
      _tex      = CompsFactory.newTexture(_source);
      
      if(_tex) {
        commitTexture();
        return;
      }
      
      if((_tex == null) && (value is String))
      {
        _bl     = _bl ? _bl : new BitmapLoader();
        _bl.src = String(value);
        _bl.process(bl_onComplete);
      }
      
    }
    
    public function get scaleMode():String  { return _scaleMode;  }
    public function set scaleMode(value:String):void
    {
      _scaleMode = value;
      invalidate(INVALIDATION_FLAG_SCALEMODE);
    }
    
    public function get forceDisposeConcreteTexture():Boolean { return _forceDisposeConcreteTexture;  }
    public function set forceDisposeConcreteTexture(value:Boolean):void
    {
      _forceDisposeConcreteTexture = value;
    }
    
    public function get flagFadeInLoadedImage():Boolean { return _flagFadeInLoadedImage;  }
    public function set flagFadeInLoadedImage(value:Boolean):void
    {
      _flagFadeInLoadedImage = value;
      
    }
    
    override protected function initialize():void
    {
      super.initialize();      
    }
    
    override protected function draw():void
    {
      super.draw();
      
      var sizeInvalid:      Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var scaleModeInvalid: Boolean = isInvalid(INVALIDATION_FLAG_SCALEMODE);
      var alignInvalid:     Boolean = isInvalid(INVALIDATION_FLAG_ALIGN);
      
      if(scaleModeInvalid || sizeInvalid)
        applyScaleMode();
      
      if(alignInvalid || sizeInvalid)
        applyAlignment();
      
      if(_quad_debug) {
        _quad_debug.width           = width;
        _quad_debug.height          = height;
      }
      
    }
    
    private function applyScaleMode():void
    {
      if(_img == null)
        return;
      
      _img.smoothing                        = TextureSmoothing.BILINEAR;
      
      var imgW: Number;
      var imgH: Number;
      var ar:   Number;
      var arW:  Number;
      var arH:  Number;
      
      switch(_scaleMode)
      {
        case SCALEMODE_STRECTH:
        {
          imgH                              = height;
          imgW                              = width;
          break;
        }
        case SCALEMODE_LETTERBOX:
        {
          arW                               = width / _img.texture.width;
          arH                               = height / _img.texture.height;
          ar                                = Math.min(arW, arH); 
          if(ar == 0)
            ar                              = Math.max(arW, arH);
          imgW                              = _img.texture.width * ar;
          imgH                              = _img.texture.height * ar;
          break;
        }
        case SCALEMODE_ZOOM:
        {
          imgH                              = height;
          imgW                              = width;
          
          var tW:     Number                = _img.texture.width;
          var tH:     Number                = _img.texture.height;
          var cX:     Number                = 0;
          var cY:     Number                = 0;
          var cW:     Number                = 1;
          var cH:     Number                = 1;
          
          var containerW: Number            = width;
          var containerH: Number            = height;
          
          arW                               = tW / containerW; 
          arH                               = tH / containerH;
          
          ar                                = Math.min(arW, arH);
          
          var scaledW:  Number              = containerW * ar;
          var scaledH:  Number              = containerH * ar;
          
          var relativeW:  Number            = scaledW / tW;
          var relativeH:  Number            = scaledH / tH;
          
          cW                                = relativeW  ;
          cH                                = relativeH  ;
          cX                                = (1 - cW)*0.5;
          cY                                = (1 - cH)*0.5;
          
          _img.setTexCoordsTo(0,  cX,       cY     );
          _img.setTexCoordsTo(1,  cX + cW,  cY     );
          _img.setTexCoordsTo(2,  cX,       cY + cH);
          _img.setTexCoordsTo(3,  cX + cW,  cY + cH);
          
          break;
        }
        case SCALEMODE_NONE:
        {
          imgW                              = _img.width;
          imgH                              = _img.height;
        }
          
      }
      
      _img.width                            = imgW;
      _img.height                           = imgH;
      
      if(width == 0)
        width                               = imgW;
      
      if(height == 0)
        height                              = imgH;
    }
    
    private function commitTexture():void
    {
      if(_source == null) {
        if(_img) 
          removeChild(_img, true);
        return;
      }
      
      if(_img) {
        _img.texture    = _tex;
      }
      else {
        _img            = new Image(_tex);
        
        if(_flagFadeInLoadedImage) {
          _img.alpha    = 0.0;
          _tweenFade    = new Tween(_img, 0.9);
          _tweenFade.fadeTo(1);
          
          Starling.juggler.add(_tweenFade);
        }
        
      }
      
      addChild(_img);
      
      invalidate(INVALIDATION_FLAG_ALL);
    }
    
    private function bl_onComplete(bl:BitmapLoader = null):void
    {
      _tex = CompsFactory.newTexture(bl.bitmap);
      commitTexture();
    }
    
  }
  
}