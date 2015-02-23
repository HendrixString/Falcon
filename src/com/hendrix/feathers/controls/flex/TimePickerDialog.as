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
    }
    
    public function get date_picker(): TimePicker
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
      _time_picker                  = new TimePicker();
      
      _time_picker.verticalCenter   = 0;
      _time_picker.percentHeight    = 50;
      _time_picker.percentWidth     = 100;
      
      dialogContent                 = _time_picker;
      
      super.initialize();
    }
    
  }
  
}