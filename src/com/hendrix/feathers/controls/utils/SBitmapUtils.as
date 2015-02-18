package com.hendrix.feathers.controls.utils
{
  import flash.display.BitmapData;
  import flash.display.StageQuality;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  
  /**
   * Helper class for bitmap manipulation
   * @author Tomer Shalev
   * 
   */
  public class SBitmapUtils
  {
    static public const SCALEMODE_STRECTH:                String        = "SCALEMODE_STRECTH";
    static public const SCALEMODE_LETTERBOX:              String        = "SCALEMODE_LETTERBOX";
    static public const SCALEMODE_ZOOM:                   String        = "SCALEMODE_ZOOM";
    static public const SCALEMODE_NONE:                   String        = "SCALEMODE_NONE";
    
    public function SBitmapUtils()
    {
    }
    
    /**
     * 
     * @param bmSrc the source bitmap
     * @param rectDest rectangle, you need to pass at least width or height or both. For example, specify only width to scale, and height will be calc dynamically
     * @param scaleMode <code>SCALEMODE_STRECTH, SCALEMODE_LETTERBOX, SCALEMODE_ZOOM, SCALEMODE_NONE</code>
     * @param fitBitmapResult effective cropping of dead pixels, applied only when <code>SBitmapUtils.SCALEMODE_LETTERBOX</code> is used
     * @param scaleConditionally scale only if <code>rectDest < bmSrc.rect</code>, i.e <code>rectDest</code> is contained inside <code>bmSrc.rect</code>
     * @return resulting bitmap
     * 
     * <p><b>TODO:</b><br>
     * - add translation for zoom, center images<br>
     * - requires QA (i didnt have time)
     * 
     */
    static public function resizeBitmap(bmSrc:BitmapData, rectDest:Rectangle, scaleMode:String = SBitmapUtils.SCALEMODE_LETTERBOX, 
                                        fitBitmapResult:Boolean = false, scaleConditionally:Boolean = false):BitmapData
    {
      var mat:                    Matrix      = new Matrix();
      var bmResult:               BitmapData  = null;
      
      var wOrig:                  uint        = bmSrc.width;
      var hOrig:                  uint        = bmSrc.height;
      
      var wScaleTo:               uint        = rectDest.width;
      var hScaleTo:               uint        = rectDest.height;
      
      if(wScaleTo==0 && hScaleTo==0)
        throw new Error("resizeBitmap: need at least $scaleTo.width or $scaleTo.height");
      
      var arW:                    Number      = (wScaleTo != 0) ? wScaleTo / wOrig : NaN;
      var arH:                    Number      = (hScaleTo != 0) ? hScaleTo / hOrig : NaN;
      
      arW                                     = isNaN(arW) ? arH: arW;
      arH                                     = isNaN(arH) ? arW: arH;
      
      var arMin:                  Number      = Math.min(arW, arH);
      var arMax:                  Number      = Math.max(arW, arH);
      
      wScaleTo                                = (wScaleTo != 0) ? wScaleTo : wOrig*arW;
      hScaleTo                                = (hScaleTo != 0) ? hScaleTo : hOrig*arH;
      
      if(scaleConditionally) {
        var isScaleConditionally: Boolean     = (wScaleTo >= bmSrc.width) && (hScaleTo >= bmSrc.height);
        if(isScaleConditionally)
          return bmSrc.clone();
      }
      
      bmResult                                = new BitmapData(wScaleTo, hScaleTo, false);
      
      switch(scaleMode)
      {
        case SCALEMODE_STRECTH:
        {
          mat.identity();
          mat.scale(arW, arH);
          bmResult.drawWithQuality(bmSrc, mat,  null, null, null, true, StageQuality.BEST); 
          
          break;
        }
        case SCALEMODE_LETTERBOX:
        {
          if(fitBitmapResult) {
            if(bmResult)
              bmResult.dispose();
            wScaleTo                          = wOrig * arMin;
            hScaleTo                          = hOrig * arMin;
            bmResult                          = new BitmapData(wScaleTo, hScaleTo, false);
          }
          
          mat.identity();
          mat.scale(arMin, arMin);
          bmResult.drawWithQuality(bmSrc, mat,  null, null, null, true, StageQuality.BEST); 
          
          break;
        }
        case SCALEMODE_ZOOM:
        {
          mat.identity();
          mat.scale(arMax, arMax);
          bmResult.drawWithQuality(bmSrc, mat,  null, null, null, true, StageQuality.BEST); 
          
          break;
        }
        case SCALEMODE_NONE:
        {
          mat.identity();
          bmResult.drawWithQuality(bmSrc, mat,  null, null, null, true, StageQuality.BEST); 
          
          
          break;
        }
          
      }
      
      return bmResult;
    }
    
    /**
     * rotate a bitmap 
     * @param bmSrc the source bitmap
     * @param degree rotation degrees {-90, 0, 90, 180, 270}
     */
    static public function rotateBitmapData( bmSrc:BitmapData, degree:int = 0 ) :BitmapData
    {
      var bmp_result:   BitmapData;
      var mat:          Matrix = new Matrix();
      
      mat.rotate(degree * (Math.PI / 180));
      
      switch(degree)
      {
        case 90:
        {
          bmp_result          = new BitmapData( bmSrc.height, bmSrc.width, true );
          mat.translate( bmSrc.height, 0 );
          break;
        }
        case -90:
        {
          bmp_result          = new BitmapData( bmSrc.height, bmSrc.width, true );
          mat.translate( 0, bmSrc.width );
          break;
        }
        case 270:
        {
          bmp_result          = new BitmapData( bmSrc.height, bmSrc.width, true );
          mat.translate( 0, bmSrc.width );
          break;
        }
        case 180:
        {
          bmp_result          = new BitmapData( bmSrc.width, bmSrc.height, true );
          mat.translate( bmSrc.width, bmSrc.height );
          break;
        }
        case 0:
        {
          bmp_result          = new BitmapData( bmSrc.width, bmSrc.height, true );
          break;
        }
          
        default:
        {
          break;
        }
      }
      
      bmp_result.draw( bmSrc, mat, null, null, null, true )
      
      return bmp_result;
    }
    
  }
  
}