package com.hendrix.feathers.controls.utils
{
  import flash.display.BitmapData;
  import flash.display.JPEGEncoderOptions;
  import flash.display.PNGEncoderOptions;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.utils.ByteArray;
  
  public class SFile
  {
    /**
     * write a file into the disk
     * @param $source <code>String</code> path, <code>File</code>
     * @param $data <code>ByteArray, String</code>
     * @return 
     * 
     */
    public static function writeToFile($source:Object, $data:Object):Boolean
    {
      var fs:   FileStream  = new FileStream();
      var file: File        = null;
      
      if($source is File)
        file                = $source as File;
      else if($source is String)
        file                = new File($source as String);
      
      try {
        fs.open(file, FileMode.WRITE);
        
        if($data is ByteArray)
          fs.writeBytes($data as ByteArray);
        else if($data is String)
          fs.writeUTFBytes($data as String);
      }
      catch(err: Error) {
        trace("SFile.writeToFile() Error: " + err);
        return false;
      }
      finally {
        fs.close();
      }
      
      return true;
    }
    
    /**
     * write bitmap data into disk 
     * @param $dest <code>String</code> path, <code>File</code>
     * @param bd the bitmap
     * @param type compression type: <code>png, jpg</code>
     * 
     */
    public static function bitmapDataToFile($dest:Object, bd:BitmapData, type:String = "png"):void
    {
      var ba:ByteArray = null;
      
      writeToFile($dest, ba = compressBitmap(bd, type));
      
      ba.clear();
    }
    
    /**
     * compress bitmap to jpg or png bytearray 
     * @param $bd the bitmap
     * @param $type png, jpg
     * @param disposeBitmap dispose the source bitmap
     * 
     */
    static public function compressBitmap($bd:BitmapData, $type:String = "png", disposeBitmap:Boolean = false):ByteArray
    {
      var ba:         ByteArray     = null;
      var bd:         BitmapData    = $bd;
      var compressor: Object        = null;
      
      switch($type)
      {
        case "png":
        {
          compressor                = new PNGEncoderOptions();
          break;
        }
        case "jpg":
        {
          compressor                = new JPEGEncoderOptions(100);
          break;
        }
        default:
        {
          compressor                = new PNGEncoderOptions();
          $type                     = "png";
          break;
        }
      }
      
      ba                            = bd.encode(bd.rect,  compressor);
      
      if(disposeBitmap)
        bd.dispose();
      
      bd                            = null;
      
      return ba;
    }
    
    public static function deleteDirContents(dir: File, includeSubDirs: Boolean): void
    {
      if (dir == null)
        return;
      if (((dir.exists) && (dir.isDirectory)) == false)
        return;
      
      var contents: Array = dir.getDirectoryListing();
      for (var ix: int = 0; ix < contents.length; ix++)
      {
        var file: File = contents[ix];
        if (file.isDirectory)
          file.deleteDirectory(includeSubDirs);
        else
          file.deleteFile();
      }
    }
    
    public static function readTextfile(path: Object): String
    {
      var file: File;
      if (path is File)
        file = path as File;
      else if (path is String)
        file = new File(String(path));
      else throw new Error("SFile.readTextFile() - path is not a File object or String.");
      
      var text: String = "";
      if (file.exists == false)
        throw new Error("SFile.readTextFile() - file does not exist" +  file);
      
      if (file.exists && (file.size > 0))
      {
        var fs: FileStream = new FileStream();
        try {
          fs.open(file, FileMode.READ);
          text = fs.readUTFBytes(file.size);
          fs.close();
        }
        catch (err: Error) {
          // what to do...
          new Error("SFile.readTextFile() - file could not be opened/read.");
        }
      }
      
      return text;
    }
    
    public static function readXmlFile(path: Object): XML
    {
      var txt: String = readTextfile(path);
      return new XML(txt);
    }
    
    public static function readJsonFile(path: Object): Object
    {
      return JSON.parse(readTextfile(path));        
    }   
    
    public static function copyInto(directoryToCopy: File, locationCopyingTo: File):void
    {
      var directory: Array = directoryToCopy.getDirectoryListing();
      
      for each (var file: File in directory)
      {
        if (file.isDirectory)
          copyInto(file, locationCopyingTo.resolvePath(file.name));
        else
          file.copyTo(locationCopyingTo.resolvePath(file.name), true);
      }
    }
    
    public static function moveInto(directoryToMove: File, locationMovingTo: File):void
    {
      var directory: Array = directoryToMove.getDirectoryListing();
      
      for each (var file: File in directory)
      {
        if (file.isDirectory)
          moveInto(file, locationMovingTo.resolvePath(file.name));
        else
          file.moveTo(locationMovingTo.resolvePath(file.name), true);
      }
    }
    
    public static function log(msg: String, filepath: String): void
    {
      var file: File = new File(filepath);
      var fs: FileStream = new FileStream();
      fs.open(file, FileMode.APPEND);
      fs.writeUTFBytes(msg + "\n");
      fs.close();
    }
    
  }
}