package com.hendrix.feathers.controls.flex.mainWindow.interfaces
{
  import com.hendrix.feathers.controls.core.ExtScreenNavigator;
  
  import starling.events.Event;
  
  public interface IMainWindow
  {
    /**
     * get the navigator 
     * @return MrScreenNavigator
     * 
     */
    function get navigator():ExtScreenNavigator;
    
    /**
     * event listener for when a transition is complete 
     * @param event
     * 
     */
    function navigator_onTransitionComplete(event: Event): void;
    
    /**
     * event listener for when a transition is starting 
     * @param event
     * 
     */
    function navigator_onTransitionStart(event: Event): void;
  }
}