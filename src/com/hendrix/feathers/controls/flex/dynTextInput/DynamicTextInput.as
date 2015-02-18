package com.hendrix.feathers.controls.flex.dynTextInput
{
  import com.hendrix.feathers.controls.flex.dynTextInput.core.ExtStageTextTextEditor;
  import com.hendrix.feathers.controls.flex.dynTextInput.core.ExtTextFieldTextEditor;
  import com.hendrix.feathers.controls.flex.dynTextInput.core.IExtTextEditor;
  import com.hendrix.feathers.controls.core.TextServices;
  import com.hendrix.feathers.controls.utils.SFile;
  
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.JPEGEncoderOptions;
  import flash.display.PNGEncoderOptions;
  import flash.display.StageQuality;
  import flash.filesystem.File;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.system.Capabilities;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import flash.utils.ByteArray;
  
  import feathers.controls.TextInput;
  import feathers.core.ITextEditor;
  import feathers.events.FeathersEventType;
  
  import flashx.textLayout.formats.BlockProgression;
  import flashx.textLayout.formats.Direction;
  import flashx.textLayout.formats.TextAlign;
  import flashx.textLayout.formats.TextLayoutFormat;
  
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.DisplayObject;
  import starling.display.Image;
  import starling.display.Quad;
  import starling.events.Event;
  import starling.textures.Texture;
  
  /**
   * A class for displaying a dynamic text, font size wise inside a fixed <b>Feathers</b> <code>TextInput</code>
   * @param $fontSize font size
   * @param $fontColor font color
   * @param $fontFamily font family
   * @param $textAlign text align
   * @param $textEditorType stageText or textField, right now only "stagetext is supported"
   * @author Tomer Shalev
   */
  public class DynamicTextInput extends TextInput
  {
    private var _origFontSizePercent:         Number;
    private var _origFontColor:               uint;
    private var _origFontFamily:              String;
    private var _origTextAlign:               String;
    private var _origTextEditorType:          String;
    
    private var _origViewPort:                Rectangle;
    
    private var _origNumLines:                uint;
    private var _lastFontSize:                uint;
    
    private var _prevNumLines:                int         = 1;
    
    private var _mrBackgroundSkinImg:         Image       = null;
    private var _mrBackgroundSkinBitmapData:  BitmapData  = null;
    private var _mrBackgroundSkinQuad:        Quad        = null;
    
    private var _tweenQuad:                   Tween       = null;
    
    private var _bmpLogoMark:                 Bitmap      = null;
    
    private var isIphone:                     Boolean;
    
    
    /**
     * A class for displaying a dynamic text, font size wise inside a fixed <b>Feathers</b> <code>TextInput</code>
     * @param $fontSize font size
     * @param $fontColor font color
     * @param $fontFamily font family
     * @param $textAlign text align
     * @param $textEditorType stageText or textField, right now only "stagetext is supported"
     * @author Tomer Shalev
     */
    public function DynamicTextInput($fontSizePercent:Number = 0.8, $fontColor:uint = 0xffffff, $fontFamily:String = "Arial", $textAlign:String = TextFormatAlign.RIGHT, $textEditorType:String = "stageText" )
    {
      super();
      
      _origFontSizePercent    = $fontSizePercent;
      _origFontColor          = $fontColor;
      _origFontFamily         = $fontFamily;
      _origTextAlign          = $textAlign;
      _origTextEditorType     = $textEditorType;
      
      /*
      _origFontFamily         = "arial11";//"FbTipograf-Regular";
      _origTextEditorType     = "textField";
      */
      
      _origViewPort           = new Rectangle();
      
      _mrBackgroundSkinQuad   = new Quad(1,1);
      
      _tweenQuad              = new Tween(_mrBackgroundSkinQuad, 0.8);
      
      maxChars                = 175;
      
      isIphone                = (detectiOSversion() ==  -1) ? false : true;
      
      addEventListener(Event.CHANGE, onTextInputChanged);
    }
    
    /**
     * Gets the snapshot of the text as bitmapdata
     * @return The BitmapData
     */
    protected function getTextSnapshotBitmapData():BitmapData
    {
      return textEditorInst.getSnapShotBitmapData();  
    }
    
    /**
     * Gets the snapshot of the text as bitmapdata
     * @return The BitmapData
     */
    protected function getTextSnapshotBitmapDataTLF($scale:Number = 1):BitmapData
    {
      var tlFormat: TextLayoutFormat  = new TextLayoutFormat();
      
      tlFormat.color                  = _origFontColor;
      tlFormat.fontSize               = textEditorProperties.fontSize*$scale;
      tlFormat.blockProgression       = BlockProgression.TB;
      tlFormat.fontFamily             = "Arial";
      tlFormat.textAlign              = TextAlign.RIGHT;
      tlFormat.direction              = Direction.RTL;
      tlFormat.paragraphSpaceBefore   = tlFormat.paragraphSpaceAfter = 2;
      tlFormat.paddingBottom          = tlFormat.paddingTop = tlFormat.paddingLeft = tlFormat.paddingRight = padding;
      
      return TextServices.instance.renderTextCore(text,tlFormat,null,actualWidth*$scale, height*$scale,true);
    }
    
    /**
     * scale the component (silently if needed) for storage in order to produce better resolutions 
     * @param $scale the scaling factor
     * @param $visible <code>True</code> or <code>False</code>
     */
    public function scaleComponent($scale:Number = 1, $visible:Boolean = true):void
    {
      if($visible == false)
        visible                       = false;
      
      width                          *= $scale;
      height                         *= $scale;
      
      textEditorProperties.fontSize  *= $scale;
      
      validate();
      
      if($visible == true)
        visible                       = true;
    }
    
    /**
     * Get the bitmapdata of the textinput including background
     * @return the bitmapdata of the component
     */
    public function mrGetSnapShotBitmapData($scale:Number = 1): BitmapData
    {
      var bg:                   DisplayObject = backgroundSkin;
      var bd:                   BitmapData    = null;
      var transMat:             Matrix        = new Matrix();
      var arLogoMark:           Number        = 1;
      var scaledLogoMarkWidth:  Number;
      var scaledLogoMarkHeight: Number;
      
      //scaleComponent($scale, false);
      
      // we need to set focus because otherwise stage text won't update
      
      transMat.translate(0, 0);
      
      if(bmpLogoMark)
      {
        arLogoMark                            = actualWidth*$scale / bmpLogoMark.width;
        scaledLogoMarkWidth                   = bmpLogoMark.width  * arLogoMark;
        scaledLogoMarkHeight                  = bmpLogoMark.height * arLogoMark;
      }
      
      var bdHeight: uint                      = bmpLogoMark ? actualHeight*$scale + scaledLogoMarkHeight : actualHeight*$scale;
      var bdWidth:  uint                      = actualWidth*$scale;
      
      // draw background layer
      if(bg is Image) {
        transMat.scale(bdWidth / _mrBackgroundSkinBitmapData.width, (actualHeight*$scale + paddingTop) / _mrBackgroundSkinBitmapData.height);
        bd                                    = new BitmapData(bdWidth, bdHeight);
        bd.drawWithQuality(_mrBackgroundSkinBitmapData, transMat, null, null, null, true, StageQuality.BEST); 
      }
      else if(bg is Quad) 
      {
        bd                                    = new BitmapData(bdWidth, bdHeight, false, (bg as Quad).color);
      }
      
      // draw text layer
      var textbd: BitmapData                  = getTextSnapshotBitmapDataTLF($scale);
      
      transMat.identity();
      
      bd.drawWithQuality(textbd,  transMat, null, null, null, true, StageQuality.BEST); 
      
      textbd.dispose();
      textbd = null;
      
      // draw the logo mark at bottom
      if(bmpLogoMark)
      {
        bmpLogoMark.smoothing                 = true;
        transMat.identity();
        transMat.scale(arLogoMark, arLogoMark);
        transMat.translate(0, bdHeight - scaledLogoMarkHeight);
        bd.drawWithQuality(bmpLogoMark, transMat, null, null, null, true, StageQuality.HIGH_8X8);
      }
      
      //scaleComponent(1/$scale, true);
      
      return bd;
    }
    
    /**
     * Writes a png or jpg snapshot of the component
     * @param $imageName the name of the image to be saved at documents Directory
     * @param $type <code>png</code> or <code>jpg</code>
     * @return <code>True</code> if succeeded writing the file, <code>False</code> otherwise.
     */
    public function mrWriteSnapshotToFile($imageName:String, $type:String = "png", $scale:Number = 1):Boolean
    {
      var succeed:    Boolean       = false;
      var ba:         ByteArray     = null;
      
      ba                            = mrGetSnapshotCompressed($imageName, $type, $scale);
      succeed                       = SFile.writeToFile(File.documentsDirectory.resolvePath("tweeting/" + $imageName + "." + $type), ba);
      
      ba.clear();
      ba                            = null;
      
      return succeed;
    }
    
    /**
     * Writes a png or jpg snapshot of the component
     * @param $imageName the name of the image to be saved at documents Directory
     * @param $type <code>png</code> or <code>jpg</code>
     * @return <code>True</code> if succeeded writing the file, <code>False</code> otherwise.
     */
    public function mrGetSnapshotCompressed($imageName:String, $type:String = "png", $scale:Number = 1):ByteArray
    {
      var ba:         ByteArray     = null;
      var bd:         BitmapData    = null;
      var compressor: Object        = null;
      var rect:       Rectangle     = null;
      
      switch($type)
      {
        case "png":
        {
          compressor                = new PNGEncoderOptions();
          break;
        }
        case "jpg":
        {
          compressor                = new JPEGEncoderOptions(100);
          break;
        }
        default:
        {
          compressor                = new PNGEncoderOptions();
          $type                     = "png";
          break;
        }
      }
      
      rect                          = _origViewPort.clone();
      
      // if we add a logo mark then we need to compensate for the clipping rectangle
      if(bmpLogoMark) {
        var arLogoMark:Number       = actualWidth / bmpLogoMark.width;
        rect.height                += bmpLogoMark.height * arLogoMark;
      }
      
      rect.width                   *= $scale;
      rect.height                  *= $scale;
      
      bd                            = mrGetSnapShotBitmapData($scale);
      ba                            = bd.encode(rect, compressor);
      
      bd.dispose();
      bd                            = null;
      
      return ba;
    }
    
    /**
     * set the background, use this instead of set background
     * @param $source Source can be a uint that represents a color, or source can be a <code>Bitmapdata</code> object
     * representing a future to be Image
     */
    public function mrSetBackground($source: Object):void
    {     
      // dispose background if it is an image
      disposeImages();
      
      // now set a new background
      if($source is uint) {
        _mrBackgroundSkinQuad.color   = uint($source);        
        super.backgroundSkin          = _mrBackgroundSkinQuad;
        _mrBackgroundSkinQuad.alpha   = 0.2;
        
        _tweenQuad.reset(_mrBackgroundSkinQuad, 0.8);
        _tweenQuad.fadeTo(1);
        Starling.juggler.add(_tweenQuad);
      }
      else if($source is BitmapData) {
        if(_mrBackgroundSkinBitmapData) {
          _mrBackgroundSkinBitmapData.dispose();
          _mrBackgroundSkinBitmapData = null;
        }
        
        _mrBackgroundSkinBitmapData   = $source as BitmapData;
        _mrBackgroundSkinImg          = new Image(Texture.fromBitmapData(_mrBackgroundSkinBitmapData));
        super.backgroundSkin          = _mrBackgroundSkinImg;
      }
      
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _mrBackgroundSkinQuad = null;
      
      disposeImages();
    }
    
    /**
     * dispose bitmapdata and texture 
     */
    private function disposeImages():void
    {
      if(_mrBackgroundSkinBitmapData)
        _mrBackgroundSkinBitmapData.dispose();
      
      if(_mrBackgroundSkinImg) {
        _mrBackgroundSkinImg.texture.root.dispose();
        _mrBackgroundSkinImg.texture.dispose();
      }
      
      _mrBackgroundSkinBitmapData = null;
      _mrBackgroundSkinImg        = null;
    }
    
    override protected function initialize():void
    {
      super.initialize();
      
      padding = 10;
      
      addEventListener(FeathersEventType.FOCUS_OUT, input_focusOutHandler);
      
      switch(_origTextEditorType)
      {
        case "stageText":
        {
          textEditorFactory = instStageTextTextEditor;
          break;
        }
        case "textField":
        {
          textEditorFactory = instTextFieldTextEditor;
          break;
        }
          
        default:
        {
          textEditorFactory = instStageTextTextEditor;
          break;
        }
      }
      
    }
    
    private function instStageTextTextEditor():ITextEditor
    {
      var editor: ExtStageTextTextEditor  = new ExtStageTextTextEditor();
      
      editor.multiline                    = true;
      editor.fontSize                     = height*_origFontSizePercent;
      editor.fontFamily                   = _origFontFamily
      editor.color                        = _origFontColor ;
      //editor.textAlign                    = _origTextAlign;
      
      var ver_ios:  int                   = detectiOSversion();
      
      // android seems to need a bidi override of the embedding level, ios does not.
      if(ver_ios == -1)
        editor.textAlign                  = TextFormatAlign.RIGHT;
      
      return editor;
    }
    
    public function detectiOSversion():int
    {
      var os:         String  = Capabilities.os;
      
      var iosString:  String  = "iPhone OS ";
      
      var index:      int     = os.indexOf(iosString); //iPhone OS 6.1.3
      
      if(index == -1)
        return -1;
      
      index                   =  index + iosString.length;
      
      return int(os.charAt(index));
    }
    
    /*
    [Embed(source="FbTipograf-Regular.otf", embedAsCFF="false",mimeType="application/x-font-opentype", fontName="FbTipograf-Regular", fontFamily="FbTipograf-Regular")]
    private static const font15:  Class;
    */
    
    private function instTextFieldTextEditor():ITextEditor
    {
      var editor: ExtTextFieldTextEditor  = new ExtTextFieldTextEditor();
      
      editor.multiline                    = true;
      editor.wordWrap                     = true;
      var tf:     TextFormat              = new TextFormat(_origFontFamily, _origFontSizePercent*height, _origFontColor);
      tf.align                            = _origTextAlign;
      
      editor.textFormat                   = tf;
      editor.embedFonts                   = true;
      
      return editor;
    }
    
    override protected function draw():void
    {
      super.draw();
      
      if(isInvalid(INVALIDATION_FLAG_SIZE)) {
        _origViewPort.width   = width;
        _origViewPort.height  = height;
      }
    }
    
    private function input_focusOutHandler(event:Object = null):void
    {
    }
    
    /**
     * get the text editor for this control, in this case a <code>StageTextTextEditor</code>
     * @return The <code>ITextEditor</code> 
     */
    public function get textEditorInst():IExtTextEditor
    {
      return textEditor as IExtTextEditor;
    }
    
    private function get measureTextField():TextField
    {
      return (textEditor as IExtTextEditor).measureTextField;
    }
    
    /**
     * returns the fontSize, which will make the text fit inside the text editor 
     * @param tf the measure Text field object
     * @param $nextFontSize the font size to start with
     * @param $range the range in which font sizes can be assaigned
     * @return Number
     * 
     */
    private function iterateFont(tf:TextField, $nextFontSize:uint, $range:Point):Number
    {
      if(text == "")
        return 0;
      
      
      var textFormat:TextFormat               = new TextFormat(_origFontFamily, $nextFontSize);
      
      tf.defaultTextFormat                    = textFormat;
      
      tf.text                                 = text;// + ".";
      
      var cfs:        int                     = tf.defaultTextFormat.size as int;
      
      if(cfs != $nextFontSize) {
        throw new Error("flash bug iterateFont(), probably updating of textField textFormat");
      }
      
      trace("cfs: " + cfs);
      trace("tf.textHeight: " + tf.textHeight);
      
      if(Math.abs($range.x - $range.y) <= 1) {
        return $nextFontSize;
      }
      
      /*
      trace("$range.x: " + $range.x);
      trace("$range.y: " + $range.y);
      trace("cfs: " + cfs);
      trace("tf.textHeight: " + tf.textHeight);
      trace("0.75*height: " + 0.75*height);
      */
      
      var fix:Number                        = 0.7;
      
      if(isIphone)
        fix                                 = 0.6;
      
      if((tf.textHeight > fix*(actualHeight - padding*2)) ) { // || (tf.textWidth > 0.95*width)
        // make font smaller
        $range.x                            = $range.x;
        $range.y                            = cfs;
        $nextFontSize                       = $range.x + (cfs - $range.x)/2; 
      }
      else {
        // make font bigger
        $range.x                            = cfs;
        $range.y                            = $range.y;
        $nextFontSize                       = cfs + ($range.y - cfs) / 2; 
      }
      
      return iterateFont(tf, $nextFontSize, $range);
    }
    
    private function onTextInputChanged(ev:Object):void
    {
      var textEditor: IExtTextEditor        = textEditorInst as IExtTextEditor;
      
      var tf:         TextField             = textEditor.measureTextField;
      
      /**
       * 
       */
      
      trace(tf.textHeight)
      var range:  Point                     = new Point(uint(height*0.03), uint(height*_origFontSizePercent));
      
      var rfs:    Number                    = iterateFont(tf, range.y*0.5, range);
      trace("rfs: " + rfs);
      
      switch(_origTextEditorType)
      {
        case "stageText":
        {
          textEditorProperties.fontSize     = 1;
          textEditorProperties.fontSize     = rfs;
          validate();
          break;
        }
        case "textField":
        {
          (textEditor as ExtTextFieldTextEditor).textFormat = new TextFormat(_origFontFamily, rfs);
          validate();
          break;
        }
          
        default:
        {
          break;
        }
      }
      
    }
    
    public function get fontSize():               uint    { return _origFontSizePercent;  }
    public function set fontSize(value:uint):     void
    {
      _origFontSizePercent = value;
      //if(_textEditorProperties)
      //  _textEditorProperties.fontSize = _origFontSizePercent;
    }
    
    public function get fontColor():              uint    { return _origFontColor;  }
    public function set fontColor(value:uint):    void
    {
      _origFontColor = value;
      if(_textEditorProperties)
        _textEditorProperties.color = _origFontColor;
    }
    
    public function get fontFamily():             String  { return _origFontFamily; }
    public function set fontFamily(value:String): void
    {
      _origFontFamily = value;
      if(_textEditorProperties)
        _textEditorProperties.fontFamily = _origFontFamily;
    }
    
    public function get textAlign():              String  { return _origTextAlign;  }
    public function set textAlign(value:String):  void
    {
      _origTextAlign = value;
      //if(_textEditorProperties)
      //  _textEditorProperties.textAlign = _origTextAlign;
    }
    
    override public function set backgroundSkin(value:DisplayObject):void {
      throw new Error("use mrSetBackground(..) instead");
    }
    
    public function get bmpLogoMark():Bitmap  { return _bmpLogoMark;  }
    public function set bmpLogoMark(value:Bitmap):void
    {
      _bmpLogoMark = value;
    }
    
  }
}