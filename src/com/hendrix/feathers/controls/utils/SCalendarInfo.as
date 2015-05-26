package com.hendrix.feathers.controls.utils
{
  import flash.utils.Dictionary;
  
  /**
   * a helper class for calendar calculations 
   * @author Tomer Shalev
   * 
   */
  public class SCalendarInfo
  {
    static public var SECOND:       Number  = 1000; 
    static public var MINUTE:       Number  = 60*SECOND;  
    static public var HOUR:         Number  = 60*MINUTE;  
    static public var DAY:          Number  = 24*HOUR;  
    static public var WEEK:         Number  = 7*DAY;  
    static public var MONTH:        Number  = 4*WEEK; 
    static public var YEAR:         Number  = 365*DAY;  
    static public var HALF_A_YEAR:  Number  = Math.floor(YEAR/2); 
    
    static private var _mapIntToDay:  Dictionary = initDays();
    
    public function SCalendarInfo()
    {
    }
    
    /**
     * convert milliseconds to seconds 
     */
    static public function millisToSeconds(millis: Number):Number
    {
      return Math.floor(millis / 1000);
    }
    
    /**
     * convert seconds to milliseconds 
     */
    static public function secondsToMillis(seconds: Number):Number
    {
      return Math.floor(seconds * 1000);
    }
    
    static public function timeTrace(time:Number):void
    {
      var d:  Date  = new Date();
      
      d.time        = time;
      
      trace(formatDate(d));
    }
    
    /**
     * the delta in seconds between now and a given date 
     * @param date - a future Date object
     */
    static public function dateDeltaSeconds(date:Date):uint
    {
      var sec:  uint = (date.time - (new Date()).time) / SECOND;
      return sec;
    }
    
    /**
     * the delta in seconds between now and a given date 
     * @param date - a future Date object
     */
    static public function dateDeltaYears(date:Date):Number
    {
      var sec:  Number = Math.abs(date.time - (new Date()).time) / YEAR;
      
      return sec;
    }
    
    /**
     * format a date into a string 
     * @param $date the Date object, null = current date
     * @param seperator seperator symbol
     * @param reverse reverse date ?
     * @param twoDigitsYear make year double digit
     * @return the format, for example 10/10/15
     */
    static public function formatDate($date:Date = null, seperator:String = "/", reverse:Boolean = false, twoDigitsYear:Boolean = false):String
    {
      var date:Date                     = $date ? $date : new Date();
      
      var year:       String            = twoDigitsYear       ? date.fullYear.toString().substr(2) : date.fullYear.toString();
      var day:        String            = date.date < 10      ? "0" + (date.date).toString()          : (date.date).toString(); 
      var month:      String            = date.month + 1 < 10 ? "0" + (date.month + 1).toString()   : (date.month + 1).toString(); 
      
      var dateString: String;
      
      if(reverse)
        dateString                      = year + seperator + month + seperator + day;
      else
        dateString                      = day + seperator + month + seperator + year;
      
      return dateString;
    }
    
    /**
     * format a time into a string 
     * @param $date the Date object, null = current date
     * @param seperator seperator symbol
     * @return the formatted time, for example 10:32
     * 
     */
    static public function formatTime($date:Date = null, seperator:String = ":"):String
    {
      var date:Date                     = $date ? $date : new Date();
      
      var hours:    String              = date.hours < 10     ? "0" + date.hours.toString()         : date.hours.toString(); 
      var minutes:  String              = date.minutes < 10   ? "0" + date.minutes.toString()       : date.minutes.toString(); 
      var seconds:  String              = date.seconds < 10   ? "0" + date.seconds.toString()       : date.seconds.toString(); 
      
      var timeString:String             = hours + seperator + minutes + seperator + seconds;
      
      return timeString;
    }
    
    /**
     * learnt about this feature way after i coded my own algorithm :( 
     * @param _dateAnchor the base Date
     * @param days the days to add/subtract
     */
    static public function dateArithmaticAS3(_dateAnchor:Date, days:int):Date
    {
      return new Date(_dateAnchor.getTime() + days*DAY);
    }
    
    /**
     * my own implementation for date arithmatic
     * @param _dateAnchor the base Date
     * @param days the days to add/subtract
     * 
     */
    static public function dateArithmatic(_dateAnchor:Date, days:int):Date
    {
      var daysHavePassedInCurrentMonth: uint      = _dateAnchor.date;
      var currentYear:                  uint      = _dateAnchor.fullYear;
      var currentMonth:                 int       = _dateAnchor.month;
      
      var up:                           Boolean;
      var valid:                        Boolean   = false;
      
      var daysinMonth:                  uint
      
      var sDays:                        int;
      
      sDays                                       = daysHavePassedInCurrentMonth + days;
      
      sDays                                       = sDays; 
      
      while(!valid) 
      {
        
        daysinMonth                               = daysInMonth(currentMonth, currentYear);
        
        if(sDays >  daysinMonth) 
        {
          currentMonth                           += 1;
          if(currentMonth == 12)
            currentYear                          += 1;
          currentMonth                            = currentMonth%12;
          
          sDays                                   =  sDays - (daysinMonth - 0)
          daysHavePassedInCurrentMonth            = 0;
          
        }
        else if(sDays <= 0)
        {
          currentMonth                           -= 1;
          if(currentMonth == -1) {
            currentYear                          -= 1;
            currentMonth                          = 11;
          }
          currentMonth                            = currentMonth%12;
          
          sDays                                   =  sDays + (daysinMonth - 0)
          daysHavePassedInCurrentMonth            = 0;
        }
        else  {
          valid                                   = true;
        }
        
      }
      
      var date:Date                               = new Date(currentYear,currentMonth,sDays);
      
      date.date                                   = sDays;
      date.fullYear                               = currentYear;
      date.month                                  = currentMonth;
      
      return date;
    }
    
    static public function hebrewDay($date:Object = null):String
    {
      if($date is uint)
        return _mapIntToDay[uint($date)];
      else if($date is Date)
        return _mapIntToDay[($date as Date).day];
      
      return null;
    }
    
    /**
     * the number of days in month, takes into account leap years 
     * @param month the month [0..11]
     * @param year the year
     */
    static public function daysInMonth(month:uint, year:uint):uint
    {
      var isleapYear: Boolean = isLeapYear(year);
      
      switch(month)
      {
        case 0:
        {
          return 31;
          break;
        }
        case 1:
        {
          if(isleapYear)
            return 29
          return 28;
          break;
        }
        case 2:
        {
          return 31;
          break;
        }
        case 3:
        {
          return 30;
          break;
        }
        case 4:
        {
          return 31;
          break;
        }
        case 5:
        {
          return 30;
          break;
        }
        case 6:
        {
          return 31;
          break;
        }
        case 7:
        {
          return 31;
          break;
        }
        case 8:
        {
          return 30;
          break;
        }
        case 9:
        {
          return 31;
          break;
        }
        case 10:
        {
          return 30;
          break;
        }
        case 11:
        {
          return 31;
          break;
        }
          
        default:
        {
          throw new Error("month is an integer 1 - 12");
          break;
        }
      }
      
      return 0;
    }
    
    /*
    1 January 31 days
    2 February  28 days, 29 in leap years
    3 March 31 days
    4 April 30 days
    5 May 31 days
    6 June  30 days
    7 July  31 days
    8 August  31 days
    9 September 30 days
    10  October 31 days
    11  November  30 days
    12  December  31 days
    */
    
    /**
     * the number of days in a year, takes into account leap years
     */
    static public function daysInYear(year:uint):uint
    {
      return isLeapYear(year) ? 366 : 365;
    }
    
    /**
     * is a leap year? 
     * @param year the year
     */
    static public function isLeapYear(year:uint):Boolean
    {
      if(year%400 == 0)
        return true;
      else if(year%100 == 0)
        return false;
      else if(year%4 == 0)
        return true;
      
      return false;
    }
    
    private static function initDays(): Dictionary
    {
      var dic: Dictionary = new Dictionary();
      
      dic[0]              = "ראשון";
      dic[1]              = "שני";
      dic[2]              = "שלישי";
      dic[3]              = "רביעי";
      dic[4]              = "חמישי";
      dic[5]              = "שישי";
      dic[6]              = "שבת";
      
      return dic;
    }
    
    /**
     * english months array
     */
    public static function compileDaysArray_English():Array
    {
      var arr:Array = new Array();
      
      arr.push("Jan");
      arr.push("Feb");
      arr.push("Mar");
      arr.push("Apr");
      arr.push("May");
      arr.push("Jun");
      arr.push("Jul");
      arr.push("Aug");
      arr.push("Sep");
      arr.push("Oct");
      arr.push("Nov");
      arr.push("Dec");
      
      return arr;     
    }
    
  }
  
}