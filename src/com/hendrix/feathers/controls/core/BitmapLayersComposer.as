package com.hendrix.feathers.controls.core
{ 
  import com.hendrix.feathers.controls.core.imageStreamer.content.BitmapLoader;
  import com.hendrix.processManager.ProcessManager;
  
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.display.StageQuality;
  import flash.events.Event;
  import flash.events.TimerEvent;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.system.ImageDecodingPolicy;
  import flash.utils.Timer;
  
  /**
   * a Flash Display Object composer of layers, Flex Style with a dataprovider<br>
   * can be used easily as a SplashScreen
   * <p><b>Example:</b><br>
   * <code>
   *      this.dataProvier = Vector.Object([<br>
   *      {id:"1",  src: URL or Class or Bitmap/BitmapData, percentWidth: 100, percentHeight: 100, scaleMode: MrSplashScreen.SCALEMODE_STRECTH,     bottom: NaN,  top:NaN, left:NaN ,right:NaN, horizontalCenter:0,   verticalCenter:0},<br>
   *      {id:"2",  src: URL or Class or Bitmap/BitmapData, percentWidth: 60,   percentHeight: 100, scaleMode: MrSplashScreen.SCALEMODE_LETTERBOX,  bottom: NaN,  top:NaN, left:NaN ,right:NaN, horizontalCenter:0,   verticalCenter:-40},<br>
   *      {id:"3",  src: URL or Class or Bitmap/BitmapData, percentWidth: 100, percentHeight: 100, scaleMode: MrSplashScreen.SCALEMODE_LETTERBOX,   bottom: 0,    top:NaN, left:NaN ,right:NaN, horizontalCenter:NaN, verticalCenter:NaN}<br>
   *      ]);</code><br>
   * <b>Notes:</b>
   * <ul>
   * <li> use <code>this.delayBeforeRemove</code> to specify a delay after <code>this.remove()</code> has been invoked.
   * <li> use <code>this.start()</code> to add to parent.
   * <li> use <code>this.remove()</code> to completely remove and dispose.
   * </ul>
   * <b>TODO:</b>
   * <ul>
   * <li> dynamic update of bitmaps
   * <li> SCALEMODE_ZOOM
   * <li> maybe support animations, and general display objects
   * </ul>
   * @author Tomer Shalev
   */
  public class BitmapLayersComposer extends Sprite
  {
    static public const SCALEMODE_STRECTH:    String                  = "SCALEMODE_STRECTH";
    static public const SCALEMODE_LETTERBOX:  String                  = "SCALEMODE_LETTERBOX";
    
    private var _parent:                      DisplayObjectContainer  = null;
    
    private var _timerDelay:                  Timer                   = null;
    
    private var _bmLayers:                    Vector.<Bitmap>         = null;
    private var _bmSources:                   Vector.<Bitmap>         = null;
    
    private var _dataProvider:                Vector.<Object>         = null;
    /**
     * the use of a download manager is mostly to monitor when al downloads finish
     * so the layers ordering will be correct, since downloads are async. 
     */
    private var _dm:                          ProcessManager          = null;
    
    private var _delayBeforeRemove:           uint                    = 1000;
    
    private var _frameRect:                   Rectangle               = null;
    private var _latestCapture:               BitmapData              = null;
    
    private var _hasLoaded:                   Boolean                 = false;
    private var _disposeOnRemove:             Boolean                 = true;
    
    /**
     * a Flash Display Object composer of layers, Flex Style with a dataprovider<br>
     * can be used easily as a SplashScreen
     * <p><b>Example:</b><br>
     * <code>
     *      this.dataProvier = Vector.Object([<br>
     *      {id:"1",  src: URL or Class or Bitmap/BitmapData, percentWidth: 100, percentHeight: 100, scaleMode: MrSplashScreen.SCALEMODE_STRECTH,     bottom: NaN,  top:NaN, left:NaN ,right:NaN, horizontalCenter:0,   verticalCenter:0},<br>
     *      {id:"2",  src: URL or Class or Bitmap/BitmapData, percentWidth: 60,   percentHeight: 100, scaleMode: MrSplashScreen.SCALEMODE_LETTERBOX,  bottom: NaN,  top:NaN, left:NaN ,right:NaN, horizontalCenter:0,   verticalCenter:-40},<br>
     *      {id:"3",  src: URL or Class or Bitmap/BitmapData, percentWidth: 100, percentHeight: 100, scaleMode: MrSplashScreen.SCALEMODE_LETTERBOX,   bottom: 0,    top:NaN, left:NaN ,right:NaN, horizontalCenter:NaN, verticalCenter:NaN}<br>
     *      ]);</code><br>
     * <b>Notes:</b>
     * <ul>
     * <li> use <code>this.delayBeforeRemove</code> to specify a delay after <code>this.remove()</code> has been invoked.
     * <li> use <code>this.start()</code> to add to parent.
     * <li> use <code>this.remove()</code> to completely remove and dispose.
     * </ul>
     * <b>TODO:</b>
     * <ul>
     * <li> dynamic update of bitmaps
     * <li> SCALEMODE_ZOOM
     * <li> maybe support animations, and general display objects
     * </ul>
     */
    public function BitmapLayersComposer($parent: DisplayObjectContainer = null)
    {
      super();
      
      _parent     = $parent;
      
      _bmLayers   = new Vector.<Bitmap>();
      _bmSources  = new Vector.<Bitmap>();
      
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    public function get disposeOnRemove():Boolean { return _disposeOnRemove; }
    public function set disposeOnRemove(value:Boolean):void
    {
      _disposeOnRemove = value;
    }

    /**
     * remove from display list 
     * and dispose
     * 
     */
    public function remove():void
    {
      if(_delayBeforeRemove == 0) {
        onTimerComplete();
        return;
      }
      
      _timerDelay = new Timer(_delayBeforeRemove, 1);
      
      _timerDelay.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
      _timerDelay.start();
    }
    
    /**
     * remove from display list 
     * and dispose
     * 
     */
    public function removeNoDispose():void
    {
      if(_parent)
        _parent.removeChild(this);
    }
    
    /**
     * dispose all 
     */
    public function dispose():void
    {
      var count:  uint  = _bmLayers.length;
      
      for(var ix:uint = 0; ix < count; ix++)
      {
        _bmLayers[ix].bitmapData.dispose();
        _bmLayers[ix]   = null;
      }
      
      _dm.dispose();
      
      _bmLayers.length  = 0;
      
      _bmLayers         = null;
      
      _bmSources.length = 0;
      
      _bmSources        = null;
      
      _dm               = null;
      
      if(_latestCapture) {
        _latestCapture.dispose()
        _latestCapture  = null;
      }
    }
    
    public function get dataProvider():                       Vector.<Object> { return _dataProvider; }
    public function set dataProvider(value:Vector.<Object>):  void
    {
      _dataProvider = value;
    }
    
    /**
     * delay in ms before after this.remove() has been invoked 
     */
    public function get delayBeforeRemove():                  uint            { return _delayBeforeRemove;  }
    public function set delayBeforeRemove(value:uint):        void
    {
      _delayBeforeRemove = value;
    }
    
    public function capture($rect: Rectangle = null): BitmapData
    {
      _frameRect          = _frameRect ? _frameRect : new Rectangle();
      
      if($rect) {
        _frameRect.width  = $rect.width;
        _frameRect.height = $rect.height;
      }
      else if(stage) {
        _frameRect.width  = stage.fullScreenWidth;
        _frameRect.height = stage.fullScreenHeight;
      }
      
      loadSources();
      
      var bm: BitmapData  = new BitmapData(_frameRect.width, _frameRect.height);
      
      bm.drawWithQuality(this, null, null, null, null, true, StageQuality.BEST);
      
      _latestCapture      = bm;
      
      return bm;
    }
    
    /**
     * add to the parent and start loading 
     */
    public function start():void
    {
      _parent.addChild(this);
    }
        
    protected function onAddedToStage(event:Event):void
    {
      _frameRect          = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
      
      if(_parent && _parent.width && _parent.height) {
        _frameRect.width  = _parent.width;
        _frameRect.height = _parent.height;
      }
      
      if(!_hasLoaded)
        loadSources();
    }   
    
    protected function onTimerComplete(event:TimerEvent = null):void
    {
      if(_timerDelay)
        _timerDelay.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
      
      if(_parent)
        _parent.removeChild(this);
      
      if(_disposeOnRemove)
        dispose();
      
      //_parent.stage.setAspectRatio(StageAspectRatio.ANY);
    }
    
    private function loadSources():void
    {
      _dm                             = new ProcessManager(false, true);
      // this will make sure download is in a chain order, so the layers ordering is kept the same.
      _dm.numProcessesAtOnce          = 1;
      _dm.onComplete                  = dm_onComplete;
      
      var numElements:  uint          = _dataProvider.length;
      var bl:           BitmapLoader  = null;
      
      var dSrc:         Object        = null;
      
      for(var ix:uint = 0; ix < numElements; ix++)
      {
        dSrc                          = _dataProvider[ix].src;
        
        if(dSrc is Bitmap) 
          _bmSources[ix]              = dSrc as Bitmap;
        else if(dSrc is BitmapData) 
          _bmSources[ix]              = new Bitmap(dSrc as BitmapData);
        else if(dSrc is Class)
          _bmSources[ix]              = new _dataProvider[ix].src() as Bitmap;        
        else if(dSrc is String) 
        {
          bl                          = new BitmapLoader(ImageDecodingPolicy.ON_DEMAND);
          bl.id                       = _dataProvider[ix].id;
          bl.src                      = _dataProvider[ix].src as String;
          _dm.enqueue(bl);
        }
      }
      
      if(_dm.numProcesses() > 0)
        _dm.start();
      else
        dm_onComplete(null);
    }
    
    private function dm_onComplete(obj:Object):void
    {
      var bitmaps:      Object.<BitmapLoader> = _dm.getFinishedProcesses();
      
      var numElements:  uint                  = bitmaps.length;
      var anumElements: uint                  = _bmSources.length;
      
      for(var ix:uint = anumElements; ix < numElements; ix++)
      {
        _bmSources[ix]                        = new Bitmap(bitmaps[ix].bmp);
      }

      layout();
      
      _hasLoaded = true;
    }
    
    private function layout(id:String = null):void
    {
      var w:            Number      = _frameRect.width;
      var h:            Number      = _frameRect.height;
      
      var numElements:  uint        = _dataProvider.length;
      
      var scaleMode:        String;
      var percentWidth:     uint;
      var percentHeight:    uint;
      var horizontalCenter: Number;
      var verticalCenter:   Number;
      var bottom:           Number;
      var top:              Number;
      var left:             Number;
      var right:            Number;
      var data:             Object  = null;
      
      for(var ix:uint = 0; ix < numElements; ix++)
      {
        data                        = _dataProvider[ix];
        
        scaleMode                   = data.scaleMode                ? data.scaleMode      : SCALEMODE_STRECTH; 
        percentWidth                = data.percentWidth             ? data.percentWidth   : 100;
        percentHeight               = data.percentHeight            ? data.percentHeight  : 100;
        horizontalCenter            = isNaN(data.horizontalCenter)  ? NaN                 : data.horizontalCenter;
        verticalCenter              = isNaN(data.verticalCenter)    ? NaN                 : data.verticalCenter;
        bottom                      = isNaN(data.bottom)            ? NaN                 : data.bottom;
        top                         = isNaN(data.top)               ? NaN                 : data.top;
        left                        = isNaN(data.left)              ? NaN                 : data.left;
        right                       = isNaN(data.right)             ? NaN                 : data.right;
        
        _bmLayers[ix]               = scaledImage(_bmSources[ix].bitmapData, scaleMode, w*percentWidth/100, h*percentHeight/100);
        
        if(!isNaN(horizontalCenter))
          _bmLayers[ix].x           = horizontalCenter + (w - _bmLayers[ix].width)*0.5;
        
        if(!isNaN(verticalCenter))
          _bmLayers[ix].y           = verticalCenter + (h - _bmLayers[ix].height)*0.5;
        
        if(!isNaN(bottom))
          _bmLayers[ix].y           = h - (_bmLayers[ix].height + bottom);
        
        if(!isNaN(top))
          _bmLayers[ix].y           = top;
        
        if(!isNaN(right))
          _bmLayers[ix].x           = w - (_bmLayers[ix].width + right);
        
        if(!isNaN(left))
          _bmLayers[ix].y           = left;
        
        addChild(_bmLayers[ix]);
      }
    }
    
    private function scaledImage($bdSource: BitmapData, $scaleMode:String = "SCALEMODE_LETTERBOX", $width:Number = Number.POSITIVE_INFINITY, $height:Number = Number.POSITIVE_INFINITY): Bitmap
    {
      if ($bdSource == null)
        return null;
      
      var bd:       BitmapData  = null;
      var mat:      Matrix      = new Matrix();
      
      //clipping
      var oWidth:   Number      = ($width == Number.POSITIVE_INFINITY)  ? parent.stage.fullScreenWidth  : $width;
      var oHeight:  Number      = ($height == Number.POSITIVE_INFINITY) ? parent.stage.fullScreenHeight : $height;
      
      var arW:      Number      =  oWidth   / $bdSource.width;
      var arH:      Number      =  oHeight  / $bdSource.height;
      
      var ar:       Number      = Math.min(arH, arW);
      
      if($scaleMode == SCALEMODE_STRECTH)
      {
        bd                      = new BitmapData(int($bdSource.width*arW), int($bdSource.height*arH), true, 0x0);
        mat.scale(arW, arH);
      }
      else if($scaleMode == SCALEMODE_LETTERBOX)
      {
        bd                      = new BitmapData(int($bdSource.width*ar), int($bdSource.height*ar), true, 0x0);
        mat.scale(ar, ar);
      }
      
      bd.drawWithQuality($bdSource, mat, null, null, null, true, StageQuality.BEST); 
      
      var bm:       Bitmap      = new Bitmap(bd);
      
      $bdSource.dispose();
      
      return bm;
    }
    
  }
  
}