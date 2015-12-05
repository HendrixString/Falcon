package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.utils.SColors;
  
  import flash.text.TextFormat;
  
  /**
   * <p>Time picker dialog</p> 
   * 
   * <p><b>guide</b></p>
   * 
   * <li>use <code>this.textOK, this.textCANCEL, this.textHEADLINE</code> to alter the text.
   * <li>use <code>this.textCANCEL</code> to put a DisplayObject as the content of the dialog.
   * <li>use <code>this.tf_buttons, tf_headline</code> to control textFormat of buttons and headline respectively.
   * <li>use <code>this.onAction</code> callback to listen to OK/CANCEL, callback will return ACTION_OK/ACTION_CANCEL respectively.
   * <li>use <code>this.show()/close()</code> to show/close the dialog.
   * 
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
      
      textOK                        = "ok";
      textCANCEL                    = "cancel";
      textHEADLINE                  = "Time";

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