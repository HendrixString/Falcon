package com.hendrix.feathers.controls.flex
{
  
  /**
   * Date picker dialog 
   * @author Tomer Shalev
   */
  public class DatePickerDialog extends Dialog
  {
    private var _date_picker: DatePicker = null;
        
    /**
     * Date picker dialog 
     * @author Tomer Shalev
     */
    public function DatePickerDialog()
    {
      super();    
      
      _date_picker                  = new DatePicker();
    }
    
    /**
     * set the date for this dialog, otherwise current date will be used 
     * 
     * @param date the date
     */
    public function set date(date:Date):void
    {
      _date_picker.date = date;
    }
    
    public function get date_picker(): DatePicker
    {
      return _date_picker;
    }
        
    override public function dispose():void
    {
      super.dispose();
      
      _date_picker = null;
    }
    
    override protected function initialize():void
    {      
      _date_picker.verticalCenter   = 0;
      _date_picker.percentHeight    = 50;
      _date_picker.percentWidth     = 100;
      
      dialogContent                 = _date_picker;
      
      super.initialize();
    }
    
  }
  
}