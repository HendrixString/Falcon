package com.hendrix.feathers.controls.flex
{
  
  import flash.media.Sound;
  import flash.utils.getQualifiedClassName;
  
  import starling.core.Starling;
  import starling.display.DisplayObject;
  import starling.display.MovieClip;
  import starling.events.Event;
  import starling.events.Touch;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;
  
  /**
   * a <code>Button</code> with a <code>MovieClip</code> skin.
   * 
   * <lu>
   *    <li/>you can listen to <code>MovieClipButton.ANIMATION_FINISHED</code> event.
   * 
   * @author Tomer Shalev
   * 
   */
  public class MovieClipButton extends FlexButton
  {
    /**
     * Event for Dropping the this button 
     */
    public static const ANIMATION_FINISHED: String = "ANIMATION_FINISHED";
    [Event(name="ANIMATION_FINISHED", type="starling.events.Event")]

    private var _mc_skin:       MovieClip = null;
    private var _up_skin:       FlexImage = null;
    private var _sound:         Sound     = null;
    
    public function MovieClipButton(mc: MovieClip, sound:Sound = null)
    {
      super();
      
      _mc_skin = mc;
      _sound   = sound;
    }
    
    override protected function feathersControl_addedToStageHandler(event:Event):void
    {
      super.feathersControl_addedToStageHandler(event);
            
      addEventListener(TouchEvent.TOUCH, touchHandler);
    }
    
    override protected function feathersControl_removedFromStageHandler(event:Event):void
    {
      super.feathersControl_removedFromStageHandler(event);
      
      Starling.juggler.remove(_mc_skin);

      removeEventListener(TouchEvent.TOUCH, touchHandler);
      _mc_skin.removeEventListener(Event.COMPLETE, mc_onComplete);        
    }

    override protected function initialize():void
    {
      super.initialize();

      if(_sound != null)
        _mc_skin.setFrameSound(0, _sound);
      
      super.downSkin          = _mc_skin;
      
      _up_skin                = new FlexImage();
      _up_skin.scaleMode      = FlexImage.SCALEMODE_STRECTH;
      _up_skin.source         = _mc_skin.getFrameTexture(0);  
      
      super.defaultSkin       = _up_skin;
      
      _mc_skin.addEventListener(Event.COMPLETE, mc_onComplete);
      
      _mc_skin.stop();

      Starling.juggler.add(_mc_skin);
    }       
    
    private function btnPlay_onTriggered(event:Event):void
    {
      _mc_skin.play();
    }
    
    private function btnStop_onTriggered(event:Event):void
    {
      _mc_skin.stop();
    }
    
    override protected function draw():void
    {
      super.draw();      
    }
    
    override public function dispose():void
    {
      super.dispose();
    }    

    override public function set defaultSkin(value:DisplayObject):void
    {
      throw new Error("Not Supported for " + getQualifiedClassName(this));
    }    
    override public function set downSkin(value:DisplayObject):void
    {
      throw new Error("Not Supported for " + getQualifiedClassName(this));
    }    
    override public function set upSkin(value:DisplayObject):void
    {
      throw new Error("Not Supported for " + getQualifiedClassName(this));
    }
    
    private function touchHandler(event: TouchEvent = null):void
    {
      if(event == null)
        return;
      
      var touch:    Touch     = event.getTouch(stage);
      
      if(touch==null)
        return;
      
      if(touch.phase == TouchPhase.BEGAN) {
        _mc_skin.currentFrame = 0;
        _mc_skin.loop = false;
        _mc_skin.play();   
        trace("begin playing");
      }
      else if(touch.phase == TouchPhase.ENDED) {
        _mc_skin.stop();
        trace("stopped playing");
      }
      
    }
    
    private function mc_onComplete(event: Event):void
    {
      trace("MovieClipButton.mc_onComplete");
      _mc_skin.stop();
      
      dispatchEventWith(ANIMATION_FINISHED);   
    }
    
  }
  
}