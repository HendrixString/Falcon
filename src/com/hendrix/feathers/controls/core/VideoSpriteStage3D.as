package com.hendrix.feathers.controls.core
{
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.StageVideoAvailabilityEvent;
  import flash.events.StageVideoEvent;
  import flash.geom.Rectangle;
  import flash.media.StageVideo;
  import flash.media.StageVideoAvailability;
  import flash.media.Video;
  import flash.net.NetConnection;
  import flash.net.NetStream;
  
  public class VideoSpriteStage3D extends Sprite
  {
    private var _stageVideoAvailable: Boolean     = false;
    private var _sv:                  StageVideo  = null;
    private var _ns:                  NetStream   = null;
    private var _videoWidth:          Number      = 0;
    private var _videoHeight:         Number      = 0;
    
    public function VideoSpriteStage3D()
    {
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    protected function onAddedToStage(event:Event):void
    {
      removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
      stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, stageVideo_onAvailable);
      
    }
    
    public function playVideo(url:String = ""):void
    {
      url = "https://fbcdn-video-a.akamaihd.net/hvideo-ak-ash2/v/1032135_10201255829810977_784139296_n.mp4?oh=15295039070134e15b176accb0a6e3dd&oe=52937FC4&__gda__=1385489540_8850c14ab018118bb5e070347dc843b0";
      _ns.play(url);
      
    }
    
    public function onMetaData(e:Object):void
    {
    }
    
    public function onXMPData(e:Object):void
    {
    }
    
    public function get videoWidth():               Number  { return _videoWidth;   }
    public function set videoWidth(value:Number):   void
    {
      _videoWidth   = value;
    }
    
    public function get videoHeight():              Number  { return _videoHeight;  }
    public function set videoHeight(value:Number):  void
    {
      _videoHeight  = value;
    }
    
    private function stageVideo_onAvailable(e:StageVideoAvailabilityEvent):void
    {
      _stageVideoAvailable = (e.availability == StageVideoAvailability.AVAILABLE);
      initVideo();
    }
    
    private function initVideo():void
    {
      var nc: NetConnection = new NetConnection();
      nc.connect(null);
      
      _ns                   = new NetStream(nc);
      
      _ns.client            = this;
      
      if(_stageVideoAvailable)  {
        _sv                 = stage.stageVideos[0];
        _sv.addEventListener(StageVideoEvent.RENDER_STATE, stageVideo_onRender);
        _sv.attachNetStream(_ns);
        trace('available');
      }
      else  {
        var vid:  Video     = new Video(_videoWidth, _videoHeight);
        addChild(vid);
        vid.attachNetStream(_ns);
        trace('not');
      }
      
      playVideo();
    }
    
    private function stageVideo_onRender(e:StageVideoEvent):void
    {
      var ar: Number    = stage.stageWidth / _sv.videoWidth;
      var vp: Rectangle = new Rectangle(0, 0, stage.stageWidth, _sv.videoHeight * ar);
      vp.x              = (stage.stageWidth - vp.width) * 0.5;
      vp.y              = (stage.stageHeight - vp.height) * 0.5;
      
      _sv.viewPort      = vp;
      
      trace("stageVideo_onRender");
    }
    
  }
  
}