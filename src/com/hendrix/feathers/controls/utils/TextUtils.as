package com.hendrix.feathers.controls.utils
{
  public class TextUtils
  {
    static public const TRIM_POLICY_LEFT: String = "TRIM_POLICY_LEFT";
    static public const TRIM_POLICY_RIGHT:String = "TRIM_POLICY_RIGHT";
    static public const TRIM_POLICY_BIDI: String = "TRIM_POLICY_BIDI";
    
    static public var currentDate:Date = new Date();
    static private var _stringAux:String = new String("aux");
    
    public function TextUtils()
    {
    }
    
    /**
     * trim a string with repeated character from any direction  
     * 
     * @param str     the string to trim
     * @param char    the character to trim
     * @param policy  the trimming policy {}
     * 
     * @return the trimmed string
     * 
     */
    public static function trim(str:String, char:String = " ", policy: String = TRIM_POLICY_BIDI): String {
      var index_start:  uint = 0;
      var index_end:    uint = str.length;          
      
      if(policy==TRIM_POLICY_BIDI || policy==TRIM_POLICY_LEFT) {
        for(index_start = 0;; index_start++) {
          if(str.charAt(index_start) != char)
            break;
        }
      }
      
      if(policy==TRIM_POLICY_BIDI || policy==TRIM_POLICY_RIGHT) {
        
        for(index_end = str.length;; index_end--) {
          var st: String    = str.charAt(index_end);
          
          if(st == '') continue;
          
          if(st!=char) {
            index_end += 1;
            break;
          }
          
        }
        
      }
      
      return str.substring(index_start, index_end);
    }

    
    /**
     * detects hebrew and if so reverses the text. use it only for one line. 
     */
    public static function detectHebrew($str:String, reverseOtherlanguage:Boolean = false):String
    {
      if($str == null)
        return "";
      
      //return $str;
      
      var firstCharCode:Number = $str.charCodeAt(0);
      var lastCharCode:Number = $str.charCodeAt($str.length - 1);
      
      if (// Hebrew.
        ((firstCharCode >= 0x0590) && (firstCharCode <= 0x05FF)) ||
        // Hebrew presentation forms.
        ((firstCharCode >= 0xFB1D) && (firstCharCode <= 0xFB4F)) ||
        // Arabic.
        ((firstCharCode >= 0x0600) && (firstCharCode <= 0x06FF)) ||
        // Arabic supplement.
        ((firstCharCode >= 0x0750) && (firstCharCode <= 0x077F)) ||
        // Arabic extended A.
        ((firstCharCode >= 0x08A0) && (firstCharCode <= 0x08FF)) ||
        // Arabic presentation forms A.
        ((firstCharCode >= 0xFB50) && (firstCharCode <= 0xFDFF)) ||
        // Arabic presentation forms B.
        ((firstCharCode >= 0xFD70) && (firstCharCode <= 0xFEFF)) ||
        
        ((lastCharCode >= 0x0590) && (lastCharCode <= 0x05FF)) ||
        // Hebrew presentation forms.
        ((lastCharCode >= 0xFB1D) && (lastCharCode <= 0xFB4F)) ||
        // Arabic.
        ((lastCharCode >= 0x0600) && (lastCharCode <= 0x06FF)) ||
        // Arabic supplement.
        ((lastCharCode >= 0x0750) && (lastCharCode <= 0x077F)) ||
        // Arabic extended A.
        ((lastCharCode >= 0x08A0) && (lastCharCode <= 0x08FF)) ||
        // Arabic presentation forms A.
        ((lastCharCode >= 0xFB50) && (lastCharCode <= 0xFDFF)) ||
        // Arabic presentation forms B.
        ((lastCharCode >= 0xFD70) && (lastCharCode <= 0xFEFF))
      )
      {
        return reverseOtherlanguage ? $str : reverse($str, _stringAux);
      }
      else
        return reverseOtherlanguage ? reverse($str) : $str;
    }
    
    /**
     * 
     * @param $str
     * @param $auxString specify another string for doing the manipulation on it to avoid instantiation of auxilary strings
     * @return 
     * 
     */
    public static function reverse($str:String, $auxString:String = null):String
    {
      if($str == null)
        return null;
      
      //return $str;
      var resReverse: String  = $auxString ? $auxString : new String();
      resReverse              = "";
      
      for(var ux:uint = 0; ux < $str.length; ux++)  {
        resReverse += $str.charAt($str.length - ux - 1);
      }
      
      if($auxString) {
        $str  = "";
        for(ux  = 0; ux < resReverse.length; ux++)
        {
          $str += resReverse.charAt(ux);
        }
        
        return $str;
      }
      
      return resReverse;
    }
    
    public static function reverse2($str:String, $auxString:String = null):String
    {
      var resReverse: String  = $auxString ? $auxString : new String();
      resReverse              = "";
      
      for(var ux:uint = 0; ux < $str.length; ux++)  {
        resReverse += $str.charAt($str.length - ux - 1);
      }
      
      if($auxString) {
        $str  = "";
        for(ux  = 0; ux < resReverse.length; ux++)
        {
          $str += resReverse.charAt(ux);
        }
        
        return $str;
      }
      
      return resReverse;
    }
    
    /**
     * convert timestamp into a short description 
     * @param timestamp the timestamp
     * @return 
     * 
     */
    public static function timestampToRelative(timestamp:String):String 
    {
      //--Parse the timestamp as a Date object--\\
      var pastDate:     Date    = new Date(uint(timestamp));
      //--Get the current data in the same format--\\
      var currentDate:  Date    = new Date();
      //--seconds inbetween the current date and the past date--\\
      var secondDiff:   Number  = (currentDate.getTime() - pastDate.getTime())/1000;
      
      //--Return the relative equavalent time--\\
      switch (true) {
        case secondDiff < 60 :
          return int(secondDiff) + ' seconds ago';
          break;
        case secondDiff < 120 :
          return 'About a minute ago';
          break;
        case secondDiff < 3600 :
          return int(secondDiff / 60) + ' minutes ago';
          break;
        case secondDiff < 7200 :
          return 'About an hour ago';
          break;
        case secondDiff < 86400 :
          return 'About ' + int(secondDiff / 3600) + ' hours ago';
          break;
        case secondDiff < 172800 :
          return 'Yesterday';
          break;
        default :
          return int(secondDiff / 86400) + ' days ago';
          break;
      }
      
      return "";
    }
    
    public static function unixTimestampToRelativeHeb(timestamp:String):String 
    {
      var secondDiff: Number = (currentDate.getTime() - uint(timestamp)*1000)/1000;
      var result:     String;
      //--Return the relative equavalent time--\\
      switch (true) {
        case secondDiff < 60 :
          result = 'לפני שניות אחדות';
          break;
        case secondDiff < 120 :
          result = 'לפני דקה';
          break;
        case secondDiff < 3600 :
          result = " לפני " + reverse(String(int(secondDiff / 60)), _stringAux) + ' דקות ';
          break;
        case secondDiff < 7200 :
          result = 'לפני שעה';
          break;
        case secondDiff < 86400 :
          result = " לפני " + reverse(String(int(secondDiff / 3600)), _stringAux) + ' שעות ';
          break;
        case secondDiff < 172800 :
          result = 'אתמול';
          break;
        default :
          result = " לפני " + reverse(String(int(secondDiff / 86400)), _stringAux) + ' ימים ';
          break;
      }
      
      return reverse(result, _stringAux);
    }
    
  }
  
}