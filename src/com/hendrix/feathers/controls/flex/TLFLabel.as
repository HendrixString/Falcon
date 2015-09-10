package com.hendrix.feathers.controls.flex
{
  import flash.display.BitmapData;
  import flash.display.DisplayObject;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.text.engine.ElementFormat;
  import flash.text.engine.FontDescription;
  import flash.text.engine.FontLookup;
  import flash.text.engine.RenderingMode;
  import flash.text.engine.TextBlock;
  import flash.text.engine.TextElement;
  import flash.text.engine.TextLine;
  
  import flashx.textLayout.conversion.TextConverter;
  import flashx.textLayout.elements.TextFlow;
  import flashx.textLayout.factory.TextFlowTextLineFactory;
  import flashx.textLayout.factory.TruncationOptions;
  import flashx.textLayout.formats.BlockProgression;
  import flashx.textLayout.formats.Direction;
  import flashx.textLayout.formats.TextAlign;
  import flashx.textLayout.formats.TextLayoutFormat;
  
  import starling.core.RenderSupport;
  import starling.display.Image;
  import starling.textures.Texture;
  import starling.textures.TextureSmoothing;
  
  /**
   * <p>
   * a TLF label, supports RTL languages. promotes memory reusage and very optimal. borrows some
   * source code from TLFSprite, but this is generally more performence (in place memory and 0 depth from it's container)</p>
   * 
   * <p><b>Notes:</b></p>
   * 
   * <li>use <code>this.textLayoutFormat</code> to assign layout and fonts.</li>
   * 
   * @author Tomer Shalev
   */
  public class TLFLabel extends Image
  {
    private var _text:                String                                = null;
    private var _textLayoutFormat:    TextLayoutFormat                      = null;
    
    private var _bmText:              BitmapData                            = null;
    
    private var _textFlow:            TextFlow                              = null;
    private var _TextLineFactory:     TextFlowTextLineFactory               = null;
    private var _TruncationOptions:   TruncationOptions                     = null;
    private var _CompositionBounds:   Rectangle                             = null;
    private var _maxBounds:           Rectangle                             = null;
    private var _helperMatrix:        Matrix                                = null;
    
    private var _isInvalid:           Boolean                               = true;
    private var _autoResizeHeight:    Boolean                               = false;
    private var _autoResizeWidth:     Boolean                               = false;
    
    private var _actualContentBounds: Rectangle                             = null;
    
    private var _backgroundColor:     uint                                  = 0x00ffffff;
    private var _sf:                  Number                                = 1;
    
    private var _tex:                 Texture                               = null;
    
    /**
     * a very very lite TLF label, supports RTL languages. promotes memory reusage and very optimal(in place memory and 0 depth from it's container).
     * u can use both TLF or FTE. control optimization with the drawing canvas dimensions, then setting width and height will scale
     * the canvas on GPU, so it is very optimal in that sence of level of control. a very lite component, use it when performance is
     * critical as in a part of a List's Itemrenderer. otherwise, Feathers have a new BlockTextRenderer that uses FTE (less quality than TLF)
     * <br><b>Notes:</b>
     * <li>use <code>this.width</code> to change composition bounds dynamically and also to scale.</li>
     * <li>use <code>this.textLayoutFormat</code> to assign layout and fonts.</li>
     * <li>use <code>this.autoResizeHeight/Width</code> to make the component bounds to resize itself to fit the text</li>
     * <li>specify <code>maxCanvasWidth/Height</code> in constructor to control the canvas dims on which we draw text. later, use this.width/height
     *  to scale that canvas on GPU. this gives a good level of control for memory consumption.
     * </li>
     * 
     * <br><b>Best usage example:</b>
     * 
     * <listing version="3.0">
     * _lbl = new TLFLabel(512, 512)
     * _lbl.autoResizeHeight = true;
     * _lbl.width = width
     * 
     * </listing
     * 
     * <br><b>TODO:</b>
     * <li>make it implement IFlexComp</li>
     * <li>make font size resize automatically to bounds like in FlexLabel</li>
     * 
     * @param maxCanvasWidth the canvas width on which TLF will draw text
     * @param maxCanvasHeight the canvas height on which TLF will draw text
     * 
     */
    public function TLFLabel(maxCanvasWidth:uint = 256, maxCanvasHeight:uint = 256)
    {
      _TextLineFactory      = new TextFlowTextLineFactory();
      _TruncationOptions    = new TruncationOptions();
      _maxBounds            = new Rectangle( 0, 0, maxCanvasWidth, maxCanvasHeight);
      _CompositionBounds    = new Rectangle( 0, 0, _maxBounds.width, _maxBounds.height);
      _helperMatrix         = new Matrix();
      
      _actualContentBounds  = new Rectangle();
      
      _bmText               = new BitmapData(_CompositionBounds.width, _CompositionBounds.height,true);
      
      //_TextLineFactory.truncationOptions          = _TruncationOptions;
      
      _tex                  = Texture.fromBitmapData(_bmText, false);
      
      super(_tex);
      
      this.smoothing        = TextureSmoothing.BILINEAR;
      //blendMode           = BlendMode.NONE;
    }
    
    override public function render(support:RenderSupport, parentAlpha:Number):void
    {       
      if(_isInvalid) {
        
        _tex.root.uploadBitmapData(renderTextTLF());
        
        var h:  Number  = _sf * (_autoResizeHeight  ? _actualContentBounds.height : _CompositionBounds.height) / texture.height;
        var xx: Number  = _sf * (_autoResizeWidth   ? _actualContentBounds.x : 0)   / texture.width;
        var w:  Number  = _sf * (_autoResizeWidth   ? (xx + (_actualContentBounds.width)  / texture.width) : _CompositionBounds.width / texture.width);
        var yy: Number  = 0;
        
        this.setTexCoordsTo(0,  xx,   yy);
        this.setTexCoordsTo(1,  w,    yy);
        this.setTexCoordsTo(2,  xx,   h);
        this.setTexCoordsTo(3,  w,    h);
      }
      
      super.render(support, parentAlpha);
      
      _isInvalid        = false;
    }
    
    /**
     * use it if autoresize is enabled and you wanr to check the measurements before it renders.
     * 
     */
    public function measure():void
    {
      var tlfFormat:  TextLayoutFormat            = _textLayoutFormat ? _textLayoutFormat : defaultTextLayoutFormat();
      
      _textFlow                                   = TextConverter.importToFlow(_text ? _text : "", TextConverter.PLAIN_TEXT_FORMAT);
      
      _TextLineFactory.compositionBounds          = _CompositionBounds;
      
      _textFlow.hostFormat                        = tlfFormat;
      
      _TextLineFactory.createTextLines( measureAux, _textFlow);
      
      _actualContentBounds                        = _TextLineFactory.getContentBounds();
      
      if(_autoResizeHeight)
        super.height                              =  _actualContentBounds.height;
      
      if(_autoResizeWidth)
        super.width                               =  _actualContentBounds.width;
    }
    
    private function measureAux(lineOrShape:flash.display.DisplayObject = null):void  {}
    
    override public function dispose():void
    {
      super.dispose();
      
      if(_bmText) {
        _bmText.dispose();
        _bmText                   = null;
      }
      
      if(texture) {
        texture.root.dispose();
        texture.dispose();
      }     
      
      _helperMatrix               = null;
      _CompositionBounds          = null;
      _TruncationOptions          = null;
      _TextLineFactory            = null;
      _textFlow                   = null;
      _textLayoutFormat           = null;
    }
    
    public function renderTextTLF():  BitmapData
    {
      var tlfFormat:  TextLayoutFormat            = _textLayoutFormat ? _textLayoutFormat : defaultTextLayoutFormat();
      
      _textFlow                                   = TextConverter.importToFlow(_text ? _text : "", TextConverter.PLAIN_TEXT_FORMAT);
      
      _TextLineFactory.compositionBounds          = _CompositionBounds;
      
      _textFlow.hostFormat                        = tlfFormat;
      
      _bmText.fillRect(_bmText.rect, _backgroundColor);
      
      _TextLineFactory.createTextLines(generatedTextLineOrShape, _textFlow);
      
      _actualContentBounds                        = _TextLineFactory.getContentBounds();
      
      if(_autoResizeHeight)
        super.height                              =  _actualContentBounds.height;
      
      if(_autoResizeWidth)
        super.width                               =  _actualContentBounds.width;
      
      return _bmText;
    }
    
    private function generatedTextLineOrShape(lineOrShape:flash.display.DisplayObject): void  
    { 
      _helperMatrix.setTo(_sf, 0, 0, _sf, lineOrShape.x*_sf, lineOrShape.y*_sf);
      _bmText.draw(lineOrShape, _helperMatrix,null,null,null,false);
      
    }
    
    /**
     * FTE alternative, better on memory but no trunctaation
     */
    private var fd1:          FontDescription;
    private var format:       ElementFormat;
    private var textElement:  TextElement;
    private var textBlock:    TextBlock;
    
    private function initFTE():void
    {
      fd1                 = new FontDescription();
      
      fd1.fontName        =  _textLayoutFormat.fontFamily;
      fd1.fontLookup      = FontLookup.EMBEDDED_CFF;
      fd1.renderingMode   = RenderingMode.CFF;
      format              = new ElementFormat(fd1);
      format.fontSize     = _textLayoutFormat.fontSize;
      
      textElement         = new TextElement(null, format);
      
      textBlock           = new TextBlock();
      
      textBlock.bidiLevel = 1;
      textBlock.content   = textElement;
    }
    
    public function renderTextFTE():BitmapData
    {     
      textElement.text                      = _text;
      
      _bmText.fillRect(_bmText.rect, _backgroundColor);
      
      var prevLine: TextLine;
      var tl:       TextLine  = textBlock.createTextLine(prevLine, _CompositionBounds.width);
      
      while (tl != null) 
      {
        tl.y                  = prevLine ? prevLine.y+tl.height : tl.ascent;
        
        if(tl == null)
          continue;
        
        _helperMatrix.setTo(_sf, 0, 0, _sf,  (_CompositionBounds.width - tl.width)*_sf, tl.y*_sf);
        _bmText.draw(tl, _helperMatrix);
        
        prevLine              = tl; 
        
        tl = textBlock.createTextLine(prevLine, _CompositionBounds.width);
        
      }
      
      textBlock.releaseLineCreationData();
      
      if(prevLine)
        _actualContentBounds.height = (prevLine.y + prevLine.height)*1;//
      
      if(_autoResizeHeight)
        super.height                              =  _actualContentBounds.height;
      
      //if(_autoResizeWidth)
      //  super.width                               =  _actualContentBounds.width;
      
      return _bmText;
    }
    
    
    private function defaultTextLayoutFormat():TextLayoutFormat
    {
      var tlFormat: TextLayoutFormat  = new TextLayoutFormat();
      
      tlFormat.color                  = 0xffffff;
      tlFormat.fontSize               = 25;
      tlFormat.blockProgression       = BlockProgression.TB;
      tlFormat.fontFamily             = "arial";
      tlFormat.textAlign              = TextAlign.RIGHT;
      tlFormat.paragraphSpaceBefore   = tlFormat.paragraphSpaceAfter = 2;
      tlFormat.paddingBottom          = tlFormat.paddingTop = tlFormat.paddingLeft = tlFormat.paddingRight = 5;
      tlFormat.direction              = Direction.RTL;
      
      return tlFormat;
    }
    
    override public function set width(value:Number):void
    {
      if(_autoResizeWidth)
        return;
      
      if(value == super.width)
        return;
      
      if(value > _maxBounds.width) {
        // todo implememnt dynamic
        //throw new Error("max bounds are: " + _maxBounds.width);
      }
      super.width               = value;
      //if(_optimizeMode == false)
      
      _CompositionBounds.width  = value;
      _sf = Math.min(_bmText.width / _CompositionBounds.width, 1) ;
      
      _isInvalid                = true;
    }
    
    override public function set height(value:Number):void
    {
      if(_autoResizeHeight)
        return;
      
      if(value == super.height)
        return;
      
      if(value > _maxBounds.height) {
        // todo implememnt dynamic
        //throw new Error("max bounds are: " + _maxBounds.height);
      }
      super.height              = value;
      //if(_optimizeMode == false)
      _CompositionBounds.height = value;
      
      _isInvalid                = true;
    }
    
    public function get text():                                   String            { return _text;                 }
    public function set text(value:String):                       void
    {
      if(_text == value)
        return;
      trace(super.height);
      _text       = value;
      _isInvalid  = true;
    }
    
    public function get textLayoutFormat():                       TextLayoutFormat  { return _textLayoutFormat;     }
    public function set textLayoutFormat(value:TextLayoutFormat): void
    {
      _textLayoutFormat = value;
      initFTE();
      _isInvalid        = true;
    }
    
    public function get autoResizeHeight():                       Boolean           { return _autoResizeHeight;     }
    public function set autoResizeHeight(value:Boolean):          void
    {
      _autoResizeHeight = value;
      _isInvalid        = true;
    }
    
    public function get autoResizeWidth():                        Boolean           { return _autoResizeWidth;      }
    public function set autoResizeWidth(value:Boolean):           void
    {
      _autoResizeWidth = value;
      _isInvalid        = true;
    }
    
    public function get actualContentBounds():                    Rectangle         { return _actualContentBounds   }
    
    public function get backgroundColor():                        uint              { return _backgroundColor;      }
    public function set backgroundColor(value:uint):              void              { _backgroundColor = value;     }
    
  }
  
}