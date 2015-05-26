package com.hendrix.feathers.controls
{
  import com.hendrix.collection.SetData.Set;
  import com.hendrix.collection.idCollection.IdCollection;
  import com.hendrix.feathers.controls.flex.FlexButton;
  import com.hendrix.feathers.controls.flex.FlexLabel;
  import com.hendrix.gfxManager.GfxManager;
  import com.hendrix.gfxManager.core.interfaces.IIdTexture;
  import com.hendrix.starling.text.bidiTextField.BidiTextField;
  
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.geom.Rectangle;
  import flash.text.TextFormat;
  
  import feathers.controls.Button;
  import feathers.controls.Label;
  import feathers.controls.ToggleButton;
  import feathers.display.Scale9Image;
  import feathers.textures.Scale9Textures;
  
  import flashx.textLayout.formats.TextAlign;
  
  import starling.display.DisplayObject;
  import starling.display.Image;
  import starling.display.Quad;
  import starling.events.Event;
  import starling.textures.Texture;
  
  /**
   * a helper factory like class for common controls like label, button, image, texture etc.. 
   * 
   */
  public class CompsFactory
  {
    /**
     * a helper factory like class for common controls like label, button, image, texture etc.. 
     * 
     */
    public function CompsFactory()
    {
      // placed here in order to load the TextFieldLibarary
      var btf:BidiTextField;
      var coll:IdCollection;
      var col2:Set;
    }
    
    /**
     * generate texture from multiple options
     * @param $bmp <code>String</code> url(GFX Manager URL), <code>Class</code>, <code>BitmapData</code>, <code>Texture</code>
     */
    static public function newTexture($bmp: Object = null, $generateMipMaps:Boolean = false, $optimizeForRenderToTexture:Boolean=false, $scale:Number=1): Texture
    {
      var tex:  Texture         = null;
      
      if($bmp is String) {
        var idTex:  IIdTexture  = GfxManager.instance.getTexture($bmp as String); 
        tex                     = idTex ? idTex.tex : null;
      }
      else if($bmp is Class)
        tex                     = starling.textures.Texture.fromBitmap(new $bmp as Bitmap, $generateMipMaps, $optimizeForRenderToTexture, $scale);
      else if($bmp is BitmapData)
        tex                     = starling.textures.Texture.fromBitmapData($bmp as BitmapData, $generateMipMaps, $optimizeForRenderToTexture, $scale);
      else if($bmp is Texture)
        tex                     = $bmp as Texture;
      else if($bmp == null)
        tex                     = GfxManager.empty;
      else
        throw new Error("setupImage() - pass a BitmapAsset class or a BitmapData object!");
      
      return tex;
    }
    
    static public function realizeObject($obj:Object):DisplayObject
    {
      if($obj is DisplayObject)
        return $obj as DisplayObject;
      else 
        return newImage($obj);
      
      return null;
    }
    
    /**
     * generate a <code>Button</code> or <code>FlexButton</code>
     * @param $downSkin <code>Quad</code>, <code>DisplayObject</code>, color integer, <code>String</code>(GFX Manager URL)
     * @param $upSkin <code>Quad</code>, <code>DisplayObject</code>, color integer, <code>String</code>(GFX Manager URL)
     * @param $handler event listener
     * @param $textFormat a <code>TextFormat</code> for font
     * @param $label text
     * @param $isToggle is toggle
     * @param $icon <code>Texture</code>, <code>Image</code> or <code>String</code>(GFX Manager URL)
     * @param $flexButon is a <code>FlexButton</code> ?
     * @param $hAlign horizontal align
     * @param embedFonts is using embedded fonts ?
     * @return <code>Button</code> or <code>FlexButton</code>
     * 
     */
    static public function newButton($downSkin:Object = null, $upSkin:Object = null, $handler:Function = null,
                                     $textFormat:* = null, $label:String  = null,  $isToggle:Boolean = false, 
                                     $icon:Object = null, $flexButon:Boolean = false, $hAlign:String = Button.HORIZONTAL_ALIGN_RIGHT, embedFonts:Boolean = false): ToggleButton
    {
      var button: ToggleButton                    = $flexButon ? new FlexButton() : new ToggleButton();
      
      if($upSkin is Quad)
        button.upSkin = $upSkin as DisplayObject;
      else if($upSkin is uint)
        button.upSkin                             = new Quad(1, 1, uint($upSkin));
      else if($upSkin is String)
        button.upSkin                             = newImage($upSkin);
      else if($upSkin is DisplayObject)
        button.upSkin                             = $upSkin as DisplayObject;
      
      button.defaultSkin                          = button.upSkin;
      
      if($downSkin is Quad)
        button.downSkin                           = $downSkin as DisplayObject;
      else if($downSkin is uint)
        button.downSkin                           = new Quad(1, 1, uint($downSkin));
      else if($downSkin is String)
        button.downSkin                             = newImage($downSkin);
      else if($downSkin is DisplayObject)
        button.downSkin                             = $downSkin as DisplayObject;

      if($isToggle) {
        button.isToggle                           = $isToggle;
        
        button.selectedUpSkin                     = button.downSkin;
        button.selectedDownSkin                   = button.upSkin;
        button.selectedHoverSkin                  = button.downSkin;        
      }
      
      if($textFormat is TextFormat)
        button.defaultLabelProperties.textFormat  = $textFormat;
      else if($textFormat is Function)
        button.labelFactory                       = $textFormat;
      
      button.defaultLabelProperties.embedFonts    = embedFonts;
      
      button.horizontalAlign                      = $hAlign;
      
      if($icon) {
        button.defaultIcon                        = newImage($icon);
        button.iconPosition                       = Button.ICON_POSITION_RIGHT;
      }
      
      if ($label)
        button.label                              = $label;
      
      if ($handler)
        button.addEventListener(Event.TRIGGERED, $handler);
      
      return button;
    }
    
    /**
     * generate a scale 9 image 
     * @param $bmp <code>String</code> url(GFX Manager URL), <code>Class</code>, <code>BitmapData</code>, <code>Texture</code>
     * @param $rect the patch rectangle
     */
    static public function newScale9Image($bmp: Object, $rect:Rectangle):Scale9Image
    {
      var textures: Scale9Textures  = new Scale9Textures(newTexture($bmp), $rect);
      var img:      Scale9Image     = new Scale9Image(textures);
      
      return img;
    }
    
    /**
     * generate Image from multiple options 
     * @param $bmp <code>String</code> url(GFX Manager URL), <code>Class</code>, <code>BitmapData</code>, <code>Texture</code>
     * @return 
     * 
     */
    static public function newImage($bmp: Object = null): Image
    {
      var tex:  Texture = null;
      
      if($bmp is String) { 
        tex             = GfxManager.instance.getTexture($bmp as String).tex;
      }
      else if($bmp is Image)
        return $bmp as Image
      else
        tex             = newTexture($bmp); 
      
      return new Image(tex);
    }
    
    /**
     * generate a <code>Label</code> or <code>FlexLabel</code>
     * @param $txt text
     * @param $tf a textFormat
     * @param $wordWrap
     * @param $embedFonts is using embedded fonts ?
     * @param $align align of text according to <code>TextAlign</code>
     * @param $flexLabel is a <code>FlexLabel</code> ?
     * @return <code>Label</code> or <code>FlexLabel</code>
     */
    static public function newLabel($txt:String = "", $tf:Object = null, $wordWrap:Boolean  = false, $embedFonts:Boolean  = false, $align:String = TextAlign.RIGHT, $flexLabel:Boolean = false):  Label
    {
      var lbl:  Label                               = $flexLabel ? new FlexLabel() : new Label();

      lbl.text                                      = $txt;
      
      if ($tf) { 
        lbl.textRendererProperties.textFormat       = $tf;
        lbl.textRendererProperties.textFormat.align = $align;
      }
      
      lbl.textRendererProperties.wordWrap           = $wordWrap;
      lbl.textRendererProperties.embedFonts         = $embedFonts;
      //lbl.textRendererProperties.align        = TextFormatAlign.CENTER;
      
      return lbl;
    }
    
  }
  
}