package com.hendrix.feathers.controls.flex
{
  import com.hendrix.feathers.controls.utils.SColors;
  
  import flash.text.TextFormat;

  /**
   * a combined Date and Time picker dialog 
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
  public class DateAndTimePickerDialog extends Dialog
  {
    private var _date_picker: DatePicker = null;
    private var _time_picker: TimePicker = null;

    /**
     * a combined Date and Time picker dialog 
     * @author Tomer Shalev
     */
    public function DateAndTimePickerDialog()
    {
      super();    
      
      textOK                        = "ok";
      textCANCEL                    = "cancel";
      textHEADLINE                  = "Date and Time";
      
      tf_buttons                    = new TextFormat("arial", null, SColors.BLUE_LIGHT);
      tf_headline                   = new TextFormat("arial", null, SColors.BLUE_LIGHT);
    }
    
    /**
     * get the time picker 
     */
    public function get time_picker():TimePicker
    {
      return _time_picker;
    }
    /**
     * get the date picker 
     */
    public function get date_picker(): DatePicker
    {
      return _date_picker;
    }
    
    override public function dispose():void
    {
      super.dispose();
      
      _date_picker = null;
      _time_picker = null;
    }
    
    override protected function initialize():void
    {
      _date_picker                  = new DatePicker();
      
      _date_picker.percentHeight    = 45;
      _date_picker.percentWidth     = 100;
            
      _time_picker                  = new TimePicker();
      
      _time_picker.percentHeight    = 45;
      _time_picker.percentWidth     = 100;
            
      var vGrp: VGroup              = new VGroup();
      
      vGrp.horizontalAlign          = "center";
      vGrp.verticalAlign            = "middle";
      vGrp.percentHeight            = 85;
      vGrp.percentWidth             = 100;
      //vGrp.backgroundSkin           = new Quad(1, 1, 0x00);
      vGrp.verticalCenter           = 0;
      vGrp.gapPercentHeight         = 2;
      
      var fq_strip: FlexQuad        = new FlexQuad(0x00);
      
      fq_strip.height               = 1;
      fq_strip.percentWidth         = 100;
      
      vGrp.addChild(_date_picker);
      vGrp.addChild(fq_strip);
      vGrp.addChild(_time_picker);
      
      dialogContent                 = vGrp;
      
      super.initialize();
    }
    
  }
  
}