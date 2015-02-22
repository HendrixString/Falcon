package com.hendrix.feathers.controls.flex.datePicker
{
  import com.hendrix.feathers.controls.flex.FlexComp;
  import com.hendrix.feathers.controls.flex.HGroup;
  import com.hendrix.feathers.controls.utils.SCalendarInfo;
  
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
  public class DatePicker extends FlexComp
  {
    /**
     * years to diaplay in list before current year 
     */
    static private const COUNT_YEARS_BEFORE:  uint = 5;
    /**
     * years to diaplay in list after current year 
     */
    static private const COUNT_YEARS_AFTER:   uint = 25;
    
    private var _list_months: LabelList = null;
    private var _list_days:   LabelList = null;
    private var _list_years:  LabelList = null;
    private var _hGrp:        HGroup    = null;
    
    private var _date:        Date      = null;
    private var qud:Quad;
    
    /**
     * a Date Picker component, inspired by the Native Android version (pre Lolipop)<br>
     * interface methods:
     * <li><code>getSelectedDay()
     * <li>getSelectedMonth()
     * <li>getSelectedYear()
     * <li>getSelectedDate()</code>
     * @author Tomer Shalev
     */
    public function DatePicker()
    {
      super();
      
      super.percentHeight           = 25;
      super.percentWidth            = 100;
      
    }
    
    /**
     * selected day [1..31] 
     */
    public function getSelectedDay():uint
    {
      return Math.max(0, _list_days.selectedIndex);
    }
    /**
     * selected month [0..11] 
     */
    public function getSelectedMonth():uint
    {
      return Math.min(Math.max(0, _list_months.selectedIndex - 1), 11);
    }
    /**
     * selected year
     */
    public function getSelectedYear():uint
    {
      return _list_years.selectedItem as uint;
    }   
    /**
     * selected Date 
     */
    public function getSelectedDate():Date
    {
      _date.date      = getSelectedDay();
      _date.month     = getSelectedMonth();
      _date.fullYear  = getSelectedYear();
      
      return _date;
    }
    
    /**
     * @inheritDoc 
     */
    override public function dispose():void
    {
      super.dispose();
      
      _list_months = null;
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
      
      _date                         = new Date();
      
      _list_months                  = new LabelList();
      _list_months.percentHeight    = 100;
      _list_months.percentWidth     = 25;
      _list_months.dataProvider     = compileMonthsDataProvider();
      _list_months.selectedIndex    = 1;
      _list_months.onSelectedIndex  = list_months_onSelectedIndex;
      
      _list_years                   = new LabelList();
      _list_years.percentHeight     = 100;
      _list_years.percentWidth      = 25;
      _list_years.dataProvider      = compileYearsDataProvider();
      _list_years.addEventListener(FeathersEventType.CREATION_COMPLETE, listYears_onCreationComplete);
      
      _list_days                    = new LabelList();
      _list_days.percentHeight      = 100;
      _list_days.percentWidth       = 25;
      _list_days.dataProvider       = compileDaysDataProvider();
      _list_days.selectedIndex      = 1;
      
      _hGrp                         = new HGroup();
      _hGrp.percentWidth            = 100;
      _hGrp.percentHeight           = 100;
      //_hGrp.gap       = 55;
      _hGrp.gapPercentWidth         = 5;
      _hGrp.verticalCenter          = 0;
      _hGrp.horizontalCenter        = 0;
      _hGrp.verticalAlign           = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
      _hGrp.relativeCalcObject      = this;
      
      _hGrp.addChild(_list_months);
      _hGrp.addChild(_list_days);
      _hGrp.addChild(_list_years);
      
      _hGrp.backgroundSkin          = new Quad(1, 1, 0xffffff);
      
      addChild(_hGrp);
      
    }
    
    override protected function draw():void
    {
      super.draw(); 
    }
    
    private function list_months_onSelectedIndex(index: uint):void
    {
      var selected_month: uint  = getSelectedMonth();
      var selected_year:  uint  = getSelectedYear();      
      var days_in_month:  uint  = SCalendarInfo.daysInMonth(selected_month, selected_year);
      var current_count:  uint  = _list_days.dataProvider.length - 2;
      
      if(current_count > days_in_month) {
        for (var ix:int = 0; ix < current_count - days_in_month; ix++) 
        {
          _list_days.dataProvider.removeItemAt(current_count - ix - 0);
        }
      }
      else if(current_count < days_in_month){
        for (var jx:int = 0; jx < days_in_month - current_count ; jx++) 
        {
          _list_days.dataProvider.addItemAt(current_count + jx + 1, _list_days.dataProvider.length - 1);
        }
        
      }
      
    }
    
    private function listYears_onCreationComplete(event:Event):void
    {
      _list_years.scrollToItemWithIndex(COUNT_YEARS_BEFORE + 1, 0.1);
    }
    
    private function compileMonthsDataProvider():ListCollection
    {
      var arr_data: Array = SCalendarInfo.compileDaysArray_English();         
      
      return new ListCollection(arr_data);
    }
    
    private function compileYearsDataProvider():ListCollection
    {
      var date_current_year:  uint  = new Date().fullYear;
      var date_to_year:       uint  = date_current_year + COUNT_YEARS_AFTER;
      var arr:                Array = new Array();  
      
      for (var ix:int = date_current_year - COUNT_YEARS_BEFORE; ix < date_to_year; ix++) 
      {
        arr.push(ix);
      }
      
      return new ListCollection(arr);
    }
    
    private function compileDaysDataProvider():ListCollection
    {
      var selected_month: uint  = getSelectedMonth();
      var selected_year:  uint  = getSelectedYear();
      
      var days_in_month:  uint  = SCalendarInfo.daysInMonth(selected_month, selected_year);
      
      var arr:            Array = new Array();
      
      for (var ix:int = 0; ix < days_in_month; ix++) 
      {
        arr.push(ix + 1);
      }
      
      return new ListCollection(arr);
    } 
    
  }
  
}