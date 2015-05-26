package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.utils.SColors;
  
  import flash.text.TextFormat;
  
  /**
   * Date picker dialog 

   * a Dialog control <br>
   * 
     * a Dialog control <br>
     * <li>use <code>this.textOK, this.textCANCEL, this.textHEADLINE</code> to alter the text.
     * <li>use <code>this.textCANCEL</code> to put a DisplayObject as the content of the dialog.
     * <li>use <code>this.tf_buttons, tf_headline</code> to control textFormat of buttons and headline respectively.
     * <li>use <code>this.onAction</code> callback to listen to OK/CANCEL, callback will return ACTION_OK/ACTION_CANCEL respectively.
     * <li>use <code>this.show()/close()</code> to show/close the dialog.
   * 
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
      
      textOK                        = "ok";
      textCANCEL                    = "cancel";
      textHEADLINE                  = "Date";
      
      tf_buttons                    = new TextFormat("arial", null, SColors.BLUE_LIGHT);
      tf_headline                   = new TextFormat("arial", null, SColors.BLUE_LIGHT);
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