package com.hendrix.feathers.controls.flex
{
	import com.hendrix.feathers.controls.flex.datePicker.DatePicker;

	/**
	 * date picker dialog 
	 * @author user
	 * 
	 */
	public class DatePickerDialog extends Dialog
	{
		private var _date_picker: DatePicker = null;
		
		public function DatePickerDialog()
		{
			super();		
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
			_date_picker 									= new DatePicker();
			
			_date_picker.verticalCenter 	= 0;
			_date_picker.percentHeight		=	50;
			_date_picker.percentWidth			= 100;
			
			dialogContent 								= _date_picker;
			
			super.initialize();
		}

	}

}