package com.hendrix.feathers.controls.flex.mainWindow
{
  import com.hendrix.feathers.controls.core.ExtScreenNavigator;
  import com.hendrix.feathers.controls.flex.mainWindow.interfaces.IMainWindow;
  import com.hendrix.feathers.controls.flex.FlexComp;
  
  import feathers.events.FeathersEventType;
  
  import starling.events.Event;
  
  /**
   * base class for a Feather appication main Window container with navigator.
   * extends this for more layouts. for example with action bar and a tab bar.
   * @author Tomer Shalev
   */
  public class MainWindow extends FlexComp implements IMainWindow
  {
    protected var _navigator:             ExtScreenNavigator                          = null;
    
    public function MainWindow()
    {
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _navigator = null;
    }
    
    /**
     * override this to listen to transition events 
     * @param event
     */
    public function navigator_onTransitionComplete(event: Event): void
    {
      trace(_navigator.activeScreen);
    }
    
    /**
     * override this to listen to transition events 
     * @param event
     */
    public function navigator_onTransitionStart(event: Event): void
    {
      trace(_navigator.activeScreen);
    }
    
    /**
     * @inheritDoc
     */
    public function get navigator():ExtScreenNavigator
    {
      return _navigator;
    }
    
    override protected function initialize():void
    {
      _navigator  = new ExtScreenNavigator();
      
      _navigator.addEventListener(FeathersEventType.TRANSITION_COMPLETE, navigator_onTransitionComplete);
      _navigator.addEventListener(FeathersEventType.TRANSITION_START, navigator_onTransitionStart);
      
      addChildAt(_navigator, 0);
      
      _navigator.removeAllScreens(); 
    }
    
    /**
     * by default navigator takes up all screen
     */
    override protected function draw():void
    {
      _navigator.width  = width;
      _navigator.height = height;
    }
    
  }
}