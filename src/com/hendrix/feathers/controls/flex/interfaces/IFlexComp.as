package com.hendrix.feathers.controls.flex.interfaces
{
  import com.hendrix.collection.common.interfaces.IData;
  
  import starling.display.DisplayObject;
  
  /**
   * the basic Interface for FlexComp responsive component
   * 
   * @author Tomer Shalev
   */
  public interface IFlexComp extends IId, IData
  {
    /**
     * the width percentage of the control based on it's parent( or relativeCalcWidthParent) 
     */
    function get percentWidth():                                Number;
    function set percentWidth(value:Number):                    void;
    
    /**
     * the height percentage of the control based on it's parent( or relativeCalcHeightParent) 
     */
    function get percentHeight():                               Number;
    function set percentHeight(value:Number):                   void;
    
    /**
     * the top margin in exact pixels
     * @see topPercentHeight()
     */
    function get top():                                         Number;
    function set top(value:Number):                             void;
    
    /**
     * the bottom margin in exact pixels
     * @see bottomPercentHeight()
     */
    function get bottom():                                      Number;
    function set bottom(value:Number):                          void;
    
    /**
     * the left margin in exact pixels
     * @see leftPercentWidth()
     */
    function get left():                                        Number
    function set left(value:Number):                            void;
    
    /**
     * the right margin in exact pixels
     * @see rightPercentWidth()
     */
    function get right():                                       Number;
    function set right(value:Number):                           void;
    
    /**
     * you can change the parent on which percentage based layout
     * calculations are based.
     */
    function get relativeCalcWidthParent():                     DisplayObject;  
    function set relativeCalcWidthParent(value:DisplayObject):  void;
    
    /**
     * you can change the parent on which percentage based layout
     * calculations are based.
     */
    function get relativeCalcHeightParent():                    DisplayObject;  
    function set relativeCalcHeightParent(value:DisplayObject): void;
    
    /**
     * how far is the control from being centered horizontally
     */
    function get horizontalCenter():                            Number;
    function set horizontalCenter(value:Number):                void;
    
    /**
     * how far is the control from being centered vertically
     */
    function get verticalCenter():                              Number;
    function set verticalCenter(value:Number):                  void;
    
    /**
     * the top margin based on percentages of parent height 
     */
    function get topPercentHeight():                            Number;
    function set topPercentHeight(value:Number):                void;
    
    /**
     * the bottom margin based on percentages of parent height 
     */
    function get bottomPercentHeight():                         Number;
    function set bottomPercentHeight(value:Number):             void;
    
    /**
     * the left margin based on percentages of parent width 
     */
    function get leftPercentWidth():                            Number;
    function set leftPercentWidth(value:Number):                void;
    
    /**
     * the right margin based on percentages of parent width 
     */
    function get rightPercentWidth():                           Number;
    function set rightPercentWidth(value:Number):               void;
    
    /**
     * layout property for children layout horizontal alignment
     */
    function get horizontalAlign():                             String;
    function set horizontalAlign(value:String):                 void;
    
    /**
     * layout property for children layout vertical alignment
     */
    function get verticalAlign():                               String;
    function set verticalAlign(value:String):                   void;
    
    /**
     * should the control be sensitive to his parent changes
     */
    function get isSensitiveToParent():                         Boolean;
    function setSensitiveToParent(count:uint):                  void;
    
    /**
     * layout actions
     */
    
    /**
     * apply horizontal/vertical alignment if they were set. typically
     * this has to happen after CREATION_COMPLETE was dispatched 
     */   
    function applyAlignment():                                  void;
    /**
     * apply layout according to the flex properties
     */   
    function layoutFlex():                                      void;
  }
}