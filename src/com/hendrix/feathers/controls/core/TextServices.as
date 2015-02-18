package com.hendrix.feathers.controls.core
{
  import flash.display.BitmapData;
  import flash.display.DisplayObject;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.text.engine.ElementFormat;
  import flash.text.engine.FontDescription;
  import flash.text.engine.TextBlock;
  import flash.text.engine.TextElement;
  import flash.text.engine.TextLine;
  
  import flashx.textLayout.conversion.TextConverter;
  import flashx.textLayout.elements.TextFlow;
  import flashx.textLayout.factory.TextFlowTextLineFactory;
  import flashx.textLayout.factory.TruncationOptions;
  import flashx.textLayout.formats.BlockProgression;
  import flashx.textLayout.formats.TextAlign;
  import flashx.textLayout.formats.TextLayoutFormat;
  
  /**
   * a class for TLF text services
   * @author Tomer Shalev
   */
  public class TextServices
  {
    private var _tlFormat:          TextLayoutFormat;
    
    private var _textFlow:          TextFlow;
    private var sTextLinesOrShapes: Vector.<flash.display.DisplayObject>;
    private var sTextLineFactory:   TextFlowTextLineFactory;
    private var mTruncationOptions: TruncationOptions;
    private var mCompositionBounds: Rectangle;
    private var sHelperMatrix:      Matrix;
    
    private static var _instance:TextServices = null;
    
    public function TextServices()
    {
      if(_instance  !=  null)
        throw new Error("MrTextServices is singleton!");
      
      _instance             = this;
      
      /**
       */
      
      sTextLineFactory      = new TextFlowTextLineFactory();
      sTextLinesOrShapes    = new <flash.display.DisplayObject>[];
      mTruncationOptions    = new TruncationOptions();
      mCompositionBounds    = new Rectangle( 0, 0, 2048, 2048);
      sHelperMatrix         = new Matrix();
    }
    
    public static function get instance():TextServices
    {
      if(_instance == null)
        _instance = new TextServices();
      return _instance;
    }
    
    /**
     * renders text with <code>TLF</code> and return <code>BitmapData</code>. use it for <b>RTL</b> languages.
     * @param $text the text
     * @param $tlfFormat the format and layout properties of the text
     * @param $width the width of the text
     * @param $maxHeight maximum height
     * @param $inPlaceTLF only one instance of <code>TLFTextField</code> and reuse it each time or not.
     * @return a <code>bitmapdata</code> of the text
     */
    public function renderTextCore($text:String = null, $tlfFormat:TextLayoutFormat = null, $bd:BitmapData = null,
                                   $width:uint = 50, $maxHeight:uint = uint.MAX_VALUE, $inPlaceTLF:Boolean = true): BitmapData
    {
      var tlfFormat:  TextLayoutFormat    = $tlfFormat ? $tlfFormat : (_tlFormat ? _tlFormat : defaultTextLayoutFormat());
      var myTextFlow: TextFlow            = null;
      var bd:         BitmapData          = null;
      
      mCompositionBounds.width            = $width;
      mCompositionBounds.height           = $maxHeight;
      
      _textFlow                           = TextConverter.importToFlow($text ? $text : "", TextConverter.PLAIN_TEXT_FORMAT);
      
      if (!_textFlow) return null;
      
      sTextLinesOrShapes.length           = 0;
      
      sTextLineFactory.compositionBounds  = mCompositionBounds;
      sTextLineFactory.truncationOptions  = mTruncationOptions;
      
      _textFlow.hostFormat                = tlfFormat;
      sTextLineFactory.createTextLines( generatedTextLineOrShape, _textFlow);
      
      var contentBounds:Rectangle         = sTextLineFactory.getContentBounds();
      
      var textWidth:Number                = $width;//Math.min(1024, contentBounds.width*scale);
      var textHeight:Number               = $maxHeight;//Math.min(1024, contentBounds.height*scale);
      
      var bitmapData:BitmapData           = $bd ? $bd : new BitmapData(textWidth, textHeight, true, 0x0);
      
      // draw each text line or shape into bitmap
      var lineOrShape:flash.display.DisplayObject;
      
      for (var i:int = 0; i < sTextLinesOrShapes.length; ++i) 
      {
        lineOrShape                       = sTextLinesOrShapes[i];
        
        sHelperMatrix.setTo(1, 0, 0, 1, (lineOrShape.x - 0)*1, (lineOrShape.y - 0)*1);
        
        bitmapData.draw(lineOrShape, sHelperMatrix);
      }
      
      sTextLinesOrShapes.length           = 0;
      
      return bitmapData;
    }
    
    private function generatedTextLineOrShape( lineOrShape:flash.display.DisplayObject ):void
    {
      sTextLinesOrShapes.push(lineOrShape);
    }
    
    private function defaultTextLayoutFormat():TextLayoutFormat
    {
      var tlFormat: TextLayoutFormat  = new TextLayoutFormat();
      
      tlFormat.color                  = 0x3c3c3c;
      tlFormat.fontSize               = 17;
      tlFormat.blockProgression       = BlockProgression.TB;
      tlFormat.fontFamily             = "arial";
      tlFormat.textAlign              = TextAlign.RIGHT;
      tlFormat.paragraphSpaceBefore   = tlFormat.paragraphSpaceAfter = 2;
      tlFormat.paddingBottom          = tlFormat.paddingTop = tlFormat.paddingLeft = tlFormat.paddingRight = 5;
      
      return tlFormat;
    }
    
    /**
     * old technique without TLF
     */
    public static function renderTextOLD($text:String = null, $width:uint = 50, $maxHeight:uint = 300):BitmapData
    {
      var fd1:FontDescription     = new FontDescription();
      
      var tlv:Vector.<TextLine>   = new Vector.<TextLine>();
      
      var test:String             = "test";
      
      fd1.fontName                = "Arial";
      
      var format:ElementFormat    = new ElementFormat(fd1);
      format.fontSize             = 25;
      
      var textElement:TextElement = new TextElement(test, format);
      
      var textBlock:TextBlock     = new TextBlock();
      
      textBlock.bidiLevel         = 1;
      textBlock.content           = textElement;
      
      var prevLine:TextLine;
      
      var tl:TextLine             = textBlock.createTextLine(prevLine, $width);
      
      while (tl != null) {
        tl.y                      = prevLine ? prevLine.y+tl.height : tl.ascent;
        prevLine                  = tl; 
        tl                        = textBlock.createTextLine(prevLine, $width);
        
        tlv.push(tl);
      }
      
      var height:uint             = prevLine.y + prevLine.height;
      
      
      var bd:BitmapData           = new BitmapData($width, Math.min(height, $maxHeight), true, 0x0);
      var mat:Matrix              = new Matrix();
      
      for(var ix:uint = 0; ix < tlv.length; ix++) {
        if(tlv[ix] == null)
          continue;
        
        mat.setTo(1, 0, 0, 1,  (tlv[ix].x)*1, (tlv[ix].y )*1);
        bd.draw(tlv[ix], mat);
      }
      
      return bd;      
    }
    
    public function get tlFormat():TextLayoutFormat { return _tlFormat; }
    public function set tlFormat(value:TextLayoutFormat):void { _tlFormat = value;  }
    
  }
  
}