package com.hendrix.feathers.controls.flex
{
  
  import com.hendrix.feathers.controls.CompsFactory;
  import com.hendrix.feathers.controls.flex.labelList.LabelList;
  
  import flash.text.TextFormat;
  
  import feathers.data.ListCollection;
  import feathers.events.FeathersEventType;
  import feathers.layout.VerticalLayout;
  
  import starling.display.Quad;
  import starling.events.Event;
  
  /**
   * a Date Picker component, inspired by the Native Android version (pre Lolipop)<br>
   * interface methods:
   * <li><code>getSelectedDay()
   * <li>getSelectedMonth()
   * <li>getSelectedYear()
   * <li>getSelectedDate()</code>
   * @author Tomer Shalev
   */
  public class TimePicker extends FlexComp
  {    
    private var _list_hours:    LabelList = null;
    private var _list_minutes:  LabelList = null;
    private var _hGrp:          HGroup    = null;
    
    private var _date:          Date      = null;
    
    /**
     * a Date Picker component, inspired by the Native Android version (pre Lolipop)<br>
     * interface methods:
     * <li><code>getSelectedDay()
     * <li>getSelectedMonth()
     * <li>getSelectedYear()
     * <li>getSelectedDate()</code>
     * @author Tomer Shalev
     */
    public function TimePicker()
    {
      super();
      
      super.percentHeight           = 25;
      super.percentWidth            = 100;      
    }
    
    /**
     * selected hour [0..23] 
     */
    public function getSelectedHour():uint
    {
      return Math.max(0, _list_hours.selectedIndex);
    }
    /**
     * selected minutes [0..59] 
     */
    public function getSelectedMinutes():uint
    {
      return Math.max(0, _list_minutes.selectedIndex);
    }
    /**
     * selected Date 
     */
    public function getSelectedDate():Date
    {
      _date.hours     = getSelectedHour();
      _date.minutes   = getSelectedMinutes();
      
      return _date;
    }
    
    /**
     * @inheritDoc 
     */
    override public function dispose():void
    {
      super.dispose();
      
      _list_hours = null;
    }
    
    /**
     * disable dimensions manipulations
     */
    /*
    override public function set percentHeight(value:Number):void {}
    override public function set percentWidth(value:Number):void {}
    override public function set height(value:Number):void { }
    override public function set width(value:Number):void {}
    */
    
    override protected function initialize():void
    {
      super.initialize();
      
      _date                                 = new Date();
      
      var tf_value: TextFormat              = new TextFormat(null, 3, 0x00A6E3);
      tf_value.align                        = "center";

      var lbl:  FlexLabel                   = new FlexLabel();
      
      lbl.percentHeight                     = 26;
      lbl.text                              = ":";
      lbl.autoSizeFont                      = true;
      lbl.textRendererProperties.textFormat = tf_value;
      lbl.fontPercentHeight                 = 1;
      
      _list_hours                           = new LabelList();
      _list_hours.percentHeight             = 100;
      _list_hours.percentWidth              = 25;
      _list_hours.dataProvider              = compileHoursDataProvider();
      _list_hours.selectedIndex             = 1;
      _list_hours.addEventListener(FeathersEventType.CREATION_COMPLETE, listHours_onCreationComplete);
      
      _list_minutes                         = new LabelList();
      _list_minutes.percentHeight           = 100;
      _list_minutes.percentWidth            = 25;
      _list_minutes.dataProvider            = compileMinutesDataProvider();
      _list_minutes.selectedIndex           = 1;
      _list_minutes.addEventListener(FeathersEventType.CREATION_COMPLETE, listMinutes_onCreationComplete);

      _hGrp                                 = new HGroup();
      _hGrp.percentWidth                    = 100;
      _hGrp.percentHeight                   = 100;
      _hGrp.gapPercentWidth                 = 5;
      _hGrp.verticalCenter                  = 0;
      _hGrp.horizontalCenter                = 0;
      _hGrp.verticalAlign                   = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
      _hGrp.relativeCalcObject              = this;
      
      _hGrp.addChild(_list_hours);
      _hGrp.addChild(lbl);
      _hGrp.addChild(_list_minutes);
      
      _hGrp.backgroundSkin                  = new Quad(1, 1, 0xffffff);
      
      addChild(_hGrp);      
    }
    
    override protected function draw():void
    {
      super.draw(); 
    }
        
    private function listHours_onCreationComplete(event:Event):void
    {
      _list_hours.scrollToItemWithIndex(_date.hours, 0.1);
    }
    
    private function listMinutes_onCreationComplete(event:Event):void
    {
      _list_minutes.scrollToItemWithIndex(_date.minutes + 1, 0.1);
    }
    
    private function compileHoursDataProvider():ListCollection
    {
      var arr:  Array = new Array();  
      
      for (var ix:int = 1; ix < 24; ix++) 
      {
        arr.push(pad(ix));
      }
            
      return new ListCollection(arr);
    }
        
    private function compileMinutesDataProvider():ListCollection
    {
      var arr:  Array = new Array();  
      
      for (var ix:int = 0; ix < 60; ix++) 
      {
        arr.push(pad(ix));
      }
      
      return new ListCollection(arr);
    } 
    
    private function pad(num:Number):String
    {
      return num < 10 ? "0" + num : String(num);
    }
    
  }
  
}