package com.hendrix.feathers.controls.flex
{
  
  /**
   * Time picker dialog 
   * @author Tomer Shalev
   */
  public class TimePickerDialog extends Dialog
  {
    private var _time_picker: TimePicker = null;
    
    /**
     * Time picker dialog 
     * @author Tomer Shalev
     */
    public function TimePickerDialog()
    {
      super();  
      
      _time_picker                  = new TimePicker();
    }
    
    /**
     * set the date for this dialog, otherwise current date will be used 
     * 
     * @param date the date
     */
    public function set date(date:Date):void
    {
      _time_picker.date = date;
    }

    public function get time_picker(): TimePicker
    {
      return _time_picker;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _time_picker = null;
    }
    
    override protected function initialize():void
    {
      
      _time_picker.verticalCenter   = 0;
      _time_picker.percentHeight    = 50;
      _time_picker.percentWidth     = 100;
      
      dialogContent                 = _time_picker;
      
      super.initialize();
    }
    
  }
  
}