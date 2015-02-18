package com.hendrix.feathers.controls.flex.audioNote
{
  import com.mreshet.air.audio.AudioFile;
  import com.mreshet.as3.audio.AudioData;
  import com.mreshet.as3.audio.IAudioEncoder;
  import com.mreshet.as3.audio.WaveEncoder;
  import com.mreshet.as3.geom.Dim;
  
  import flash.events.ActivityEvent;
  import flash.events.ErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SampleDataEvent;
  import flash.events.StatusEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.media.Microphone;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.media.SoundMixer;
  import flash.text.TextFormat;
  import flash.utils.ByteArray;
  import flash.utils.Timer;
  
  import feathers.controls.Button;
  import feathers.controls.Slider;
  import feathers.controls.text.TextFieldTextRenderer;
  import feathers.core.ITextRenderer;
  import feathers.events.FeathersEventType;
  
  import fr.kikko.lab.ShineMP3Encoder;
  
  import net.atoran.as3.utils.Stdio;
  
  import starling.display.DisplayObject;
  import starling.events.Event;
  import com.hendrix.feathers.controls.flex.FlexComp;
  import com.hendrix.feathers.controls.flex.FlexLabel;
  
  /**
   * Audio recording control
   * @author Alan Givati
   * 
   */
  public class AudioNote extends FlexComp
  {
    protected var _doBackground:  DisplayObject;
    protected var _doBtnRecord:   DisplayObject;
    protected var _doBtnPlay:     DisplayObject;
    protected var _doBtnStop:     DisplayObject;
    protected var _doBtnClear:    DisplayObject;
    protected var _doSliderTrack: DisplayObject;
    protected var _doSliderThumb: DisplayObject;
    
    protected var _btnRecord: Button;   
    protected var _btnClear:  Button;
    protected var _slider:    Slider;
    protected var _lblTime:   FlexLabel;
    
    protected var _sliderTrackOrigDim: Dim;
    protected var _sliderThumbOrigDim: Dim;
    
    protected var _mic:     Microphone;
    protected var _sound:   Sound; 
    protected var _channel: SoundChannel; 
    
    protected var _rawRecording:  AudioData;
    protected var _wavRecording:  ByteArray;
    protected var _wavEncoder:    IAudioEncoder;
    protected var _mp3Encoder:    ShineMP3Encoder;
    
    protected var _tmrMain: Timer;
    
    protected var _state: String;
    protected var _updateSlider:Boolean;
    protected var _reachedEnd:Boolean;
    
    protected var _maxRecordTime: uint = 20;
    protected var _pauseTime:     Number; 
    
    protected var _flagOnlyPlayMode:Boolean = false;
    
    public static const IF_STATE_CHANGED: String    = "audioNote_state_changed";
    
    // DisplayObject Updated (dou) Invalidation Flags
    public static const IF_DOU_BACKGROUND:    String = "audioNote_dou_background";
    public static const IF_DOU_BTN_RECORD:    String = "audioNote_dou_btnRecord";
    public static const IF_DOU_BTN_PLAY:      String = "audioNote_dou_btnPlay";
    public static const IF_DOU_BTN_STOP:      String = "audioNote_dou_btnStop";
    public static const IF_DOU_BTN_CLEAR:     String = "audioNote_dou_btnClear";
    public static const IF_DOU_SLIDER_THUMB:  String = "audioNote_dou_sliderThumb";
    public static const IF_DOU_SLIDER_TRACK:  String = "audioNote_dou_sliderEmpty";
    
    public var sliderHeightFac:       Number  = 0.11;
    public var sliderTrackHeightFac:  Number  = 0.33;
    public var timeFontSize:          uint    = 24;;
    public var timeFontColor:         uint    = 0xffffff;
    public var sliderYOffsetFac:      Number  = 0.5;
    
    /**
     * Mp3 Encoding is on main thread, therefore we added two callbacks: <code>onEncodingStart, onEncodingComplete</code>, so you can notify user.
     */
    public var onEncodingStart:       Function  = null;
    /**
     * Mp3 Encoding is on main thread, therefore we added two callbacks: <code>onEncodingStart, onEncodingComplete</code>, so you can notify user.
     */
    public var onEncodingComplete:    Function  = null;
    
    public const RECORD_RATE:         uint = 44; // kHz
    
    /**
     * @param rate uint  Possible values:
     * 44 = 44,100 Hz
     * 22 = 22,050 Hz
     * 11 = 11,025 Hz
     * 8  = 8,000 Hz
     * 5  = 5,512 Hz
     */
    protected function startRecording(micIndex: int = -1, rate: uint = 44): Boolean
    {
      if (Microphone.isSupported == false)
        return false;
      
      if (_rawRecording)
        _rawRecording.clear();
      else
        _rawRecording = new AudioData();
      
      if (_maxRecordTime < 1)
        return false; // Nothing to do
      
      _mic = Microphone.getMicrophone(micIndex);
      if (_mic != null)
      {
        _state = AudioNoteState.recording;
        //_mic.setSilenceLevel(100);
        switch (rate)
        {
          case 44:  _rawRecording.sampleRate = 44100; break;
          case 22:  _rawRecording.sampleRate = 22050; break;
          case 11:  _rawRecording.sampleRate = 11025; break;
          case 8:   _rawRecording.sampleRate = 8000;    break;
          case 5:   _rawRecording.sampleRate = 5512;    break;
        }
        _mic.rate = rate;
        _mic.gain = 100;
        _mic.setUseEchoSuppression(true);
        //_mic.enhancedOptions.autoGain = false;
        _mic.setLoopBack(false);
        //_mic.addEventListener(ActivityEvent.ACTIVITY, mic_onActivity);
        //_mic.addEventListener(StatusEvent.STATUS, mic_onStatus);
        _mic.setSilenceLevel(0);
        _mic.addEventListener(SampleDataEvent.SAMPLE_DATA, mic_onSampleData);
      }
      
      return true;
    }
    
    protected function mic_onStatus(event: StatusEvent): void
    {
      trace("statusHandler: " + event.code);
    }
    
    protected function mic_onActivity(event: ActivityEvent): void
    {
      trace("activityHandler: " + event.activating);
    }
    
    protected function mic_onSampleData(event: SampleDataEvent): void
    { 
      
      if (_rawRecording.lengthSeconds > _maxRecordTime) {
        stopRecording(true, false);
        updateRecordButtonSkin()
        return;
      }
      
      //var sample: Number;
      //var ba:ByteArray = event.data;
      //var ba2:ByteArray = _rawRecording.samples;
      
      while (event.data.bytesAvailable) {
        var sample: Number = event.data.readFloat();
        _rawRecording.samples.writeFloat(sample);
      }
      
    }
    
    protected function createMp3Encoder(): void
    {
      if (_mp3Encoder) {
        _mp3Encoder.wavData = _wavRecording;
        return;
      }
      
      _mp3Encoder = new ShineMP3Encoder(_wavRecording);
      _mp3Encoder.addEventListener(flash.events.Event.COMPLETE, mp3EncodeComplete);
      _mp3Encoder.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
      _mp3Encoder.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
    }
    
    protected function stopRecording(updateUi: Boolean, clear: Boolean): void
    {
      if (_rawRecording == null)
        return;
      
      _state = _rawRecording && _rawRecording.samples.length > 0 ? AudioNoteState.recorded : AudioNoteState.none;
      
      if (_mic) {
        _mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, mic_onSampleData);
        _mic = null;
      }
      
      if (clear)
      {
        if (_rawRecording)
          _rawRecording.clear();
        
        if (_mp3Encoder && _mp3Encoder.mp3Data)
          _mp3Encoder.mp3Data.clear();
      }
      else {
        _rawRecording.samples.position = 0;
      }
      
      if (updateUi && _state == AudioNoteState.recorded) {
        updateSliderRange();
      }
    }
    
    protected function encodeMp3(): void
    {
      if (_rawRecording.samples.length > 1)
      {
        _btnRecord.isEnabled = false;
        _btnRecord.alpha = 0.6;
        
        _btnClear.isEnabled = false;
        _btnClear.alpha = 0.6;
        
        // Convert the recording to 16-bit WAV PCM
        _wavRecording = _wavEncoder.encode(_rawRecording);
        
        // Encode the WAV to MP3
        createMp3Encoder();
        
        if(onEncodingStart is Function)
          onEncodingStart();
        
        _mp3Encoder.start();
        
      }
    }
    
    protected function mp3EncodeProgress(event : ProgressEvent) : void {
      //
    }
    
    protected function mp3EncodeError(event : ErrorEvent) : void {  
      trace("[ERROR] : ", event.text);
    }
    
    protected function mp3EncodeComplete(event : flash.events.Event) : void
    {
      trace("encoding done!");
      _btnRecord.alpha = 1.0;
      _btnRecord.isEnabled = true;
      
      _btnClear.alpha = 1.0;
      _btnClear.isEnabled = true;
      
      if(onEncodingComplete is Function)
        onEncodingComplete();
      
    }
    
    protected function createSoundFromMp3Data(): void
    {
      if (_mp3Encoder.mp3Data && _mp3Encoder.mp3Data.length > 0)
      {
        _mp3Encoder.mp3Data.position = 0;
        
        _sound = new Sound();
        _sound.loadCompressedDataFromByteArray(_mp3Encoder.mp3Data, _mp3Encoder.mp3Data.length);
      }
      else {
        _sound = null;
      }
    }
    
    protected function playRecording(createSound: Boolean): void
    {
      _state = AudioNoteState.playing;
      
      SoundMixer.stopAll();
      
      if (createSound)
        createSoundFromMp3Data();
      
      if (_sound) {
        _channel = _sound.play();
        _channel.addEventListener(flash.events.Event.SOUND_COMPLETE, sound_onPlaybackComplete)
      }
    }
    
    protected function sound_onPlaybackComplete(event: flash.events.Event): void
    {
      _reachedEnd = true;
      pausePlayback();
      updateRecordButtonSkin();
    }
    
    protected function stopPlayback(updateUi: Boolean): void
    {
      if (_channel) {
        _channel.stop();
        _channel.removeEventListener(flash.events.Event.SOUND_COMPLETE, sound_onPlaybackComplete);
        _state = AudioNoteState.recorded;
      }
      
      _channel = null;
      _sound = null;
      
      if (_mp3Encoder && _mp3Encoder.mp3Data)
        _mp3Encoder.mp3Data.position = 0;
      
      if (updateUi)
        updateRecordButtonSkin();
    }
    
    protected function pausePlayback(): void
    {
      if (_channel)
      {
        _pauseTime = _channel.position;
        trace("_pauseTime:" + _pauseTime);
        _channel.stop();
        _channel.removeEventListener(flash.events.Event.SOUND_COMPLETE, sound_onPlaybackComplete);
        _channel = null;
        
        _state = AudioNoteState.paused;
      }
    }
    
    protected function continuePlayback(): void
    {
      if (_sound)
      {
        _state = AudioNoteState.playing;
        
        if (_reachedEnd) {
          _pauseTime = 0; // restart when resuming from end.
          _reachedEnd = false;
        }
        
        _channel = _sound.play(_pauseTime);
        _channel.addEventListener(flash.events.Event.SOUND_COMPLETE, sound_onPlaybackComplete);
      }
    }
    
    protected function clearRecording(): void
    {
      stopPlayback(false);
      stopRecording(false, true);
      
      _state = AudioNoteState.none;
      
      _btnClear.isEnabled = false;
      _btnClear.alpha = 0.6;
      
      updateSliderRange();
      updateRecordButtonSkin();
      updateRecordedTimeLabel();
    }
    
    protected function seekToMillisecond(ms: Number): void
    {
      //      var newPos: Number = ms * (_rawRecording.sampleRate / 1000) * _rawRecording.bytesPerSample * _rawRecording.numChannels;
      //      if (newPos > 0 && newPos < _rawRecording.samples.length) 
      //        _rawRecording.samples.position = newPos;
      
      if (_sound) {
        pausePlayback();
        _pauseTime = ms;
        continuePlayback();
        updateRecordButtonSkin();
      }
    }
    
    /*
    protected function seekToSecond(second: Number): void
    {
    var newPos: Number = second * _rawRecording.sampleRate * _rawRecording.bytesPerSample * _rawRecording.numChannels;
    if (newPos > 0 && newPos < _rawRecording.samples.length) 
    _rawRecording.samples.position = newPos;
    }*/
    
    protected function msToMinSec(ms: uint): String
    {
      var ts: Number = (ms / 1000);
      var sec: uint = ts % 60;
      var min: uint = (ts - sec) / 60;
      
      var smin: String;
      var ssec: String;
      
      if (min < 10)
        smin = '0' + min;
      else
        smin = min.toString();
      
      if (sec < 10)
        ssec = '0' + sec;
      else
        ssec = sec.toString();
      
      return smin + ":" + ssec;
      //return Stdio.sprintf('%02d:%02d', min, sec);
    }
    
    protected function updateRecordedTimeLabel(): void
    {
      if (_rawRecording == null)
        return;
      
      if (_sound) {
        _lblTime.text = msToMinSec(_sound.length);
      }
      else { 
        if (_rawRecording && _rawRecording.lengthMilliseconds > 0)      
          _lblTime.text = msToMinSec(_rawRecording.lengthMilliseconds);
        else
          _lblTime.text = '';
      }
    }
    
    protected function updatePlaybackPosition(): void
    {
      if (_channel) {
        _lblTime.text = msToMinSec(_channel.position);
        if (_updateSlider) {
          _slider.value = _channel.position*1.03;//*1.012;
          trace("current: " + _slider.value + ", _slider.maximum: " + _slider.maximum);
        }
      }
      else {
        _lblTime.text = '';
        _slider.value = 0;
      }
    }
    
    protected function updateSliderRange(): void
    {
      _slider.minimum = 0;
      if (_sound) {
        _slider.maximum = _sound.length;
      }
      else { 
        if (_rawRecording && _rawRecording.lengthMilliseconds > 0)
          _slider.maximum = _rawRecording.lengthMilliseconds;
        else
          _slider.maximum = 0;
      }
      _slider.value = 0;
    }
    
    protected function btnRecord_onTrigger(event: starling.events.Event):void
    {
      switch(_state)
      {
        case AudioNoteState.none:
          startRecording(-1, RECORD_RATE);
          break;
        case AudioNoteState.recording:
          stopRecording(false, false);
          encodeMp3();
          break;
        case AudioNoteState.recorded:
          playRecording(true);
          updateSliderRange();
          break;
        case AudioNoteState.playing:
          pausePlayback();
          break;
        case AudioNoteState.paused:
          continuePlayback();
          break;
      }
      updateRecordButtonSkin();
    }
    
    protected function slider_onBeginInteraction():void
    {
      _updateSlider = false;
    }   
    
    protected function slider_onEndInteraction(event: Event): void
    {
      // Seek playback to new position
      //      if (_rawRecording && (_state == AudioNoteState.recorded || _state == AudioNoteState.playing) == false)
      //        return;
      
      seekToMillisecond(_slider.value);
      _updateSlider = true;
    }
    
    protected function btnClear_onTrigger(event: Event): void
    {
      // Clear the current recording if any
      if(doBtnClear == null || doBtnClear.visible==false)
        return;
      
      clearRecording();
    }
    
    protected function updateRecordButtonSkin(): void
    {
      switch(_state)
      {
        case AudioNoteState.none:
          _btnRecord.defaultSkin = _doBtnRecord;
          break;
        case AudioNoteState.recording:
          _btnRecord.defaultSkin = _doBtnStop;
          break;
        case AudioNoteState.recorded:
          _btnRecord.defaultSkin = _doBtnPlay;
          break;
        case AudioNoteState.playing:
          _btnRecord.defaultSkin = _doBtnStop;
          break;
        case AudioNoteState.paused:
          _btnRecord.defaultSkin = _doBtnPlay;
          break;
      }
      _btnRecord.upSkin = _btnRecord.defaultSkin;
      _btnRecord.downSkin = _btnRecord.defaultSkin;
    }
    
    protected function onEnterFrame(): void
    {
      switch(_state)
      {
        case AudioNoteState.recording:
          updateRecordedTimeLabel();
          break;
        case AudioNoteState.playing:
          updatePlaybackPosition();
          break;
      }
    }
    
    override protected function draw(): void
    {
      super.draw();
      
      // Update either recording time or playback position
      switch(_state)
      {
        case AudioNoteState.none:
          break;
        case AudioNoteState.playing:
          updatePlaybackPosition();
          break;
        case AudioNoteState.recording:
          updateRecordedTimeLabel();
          break;
      }
      
      var sizeInvalid:    Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
      var layoutInvalid:  Boolean = isInvalid(INVALIDATION_FLAG_LAYOUT);
      
      if (isInvalid(IF_DOU_BACKGROUND)) {
        if (_doBackground) {
          addChildAt(_doBackground, 0);
          sizeInvalid = true;
          layoutInvalid = true;
        }
      }
      
      if (isInvalid(IF_DOU_BTN_CLEAR)) {
        _btnClear.defaultSkin = _doBtnClear;
      }
      
      if (isInvalid(IF_DOU_BTN_RECORD) && _state == AudioNoteState.none) {
        updateRecordButtonSkin();
      }
      
      if (isInvalid(IF_DOU_BTN_PLAY) && _state == AudioNoteState.recorded) {
        updateRecordButtonSkin();
      }
      
      if (isInvalid(IF_DOU_BTN_STOP) && (_state == AudioNoteState.recording || _state == AudioNoteState.playing)) {
        updateRecordButtonSkin();
      }
      
      if (isInvalid(IF_DOU_SLIDER_TRACK))
      {
        if (_slider.minimumTrackFactory == null)
        {
          _slider.minimumTrackFactory = function(): Button
          {
            var button: Button = new Button();
            button.defaultSkin  = _doSliderTrack;
            button.downSkin     = _doSliderTrack;
            return button;
          }
        }
        else {
          _slider.minimumTrackProperties.defaultSkin  = _doSliderTrack;
          _slider.minimumTrackProperties.downSkin     = _doSliderTrack;
        }
      }
      
      if (isInvalid(IF_DOU_SLIDER_THUMB))
      {
        if (_slider.thumbFactory == null)
        {
          _slider.thumbFactory = function(): Button
          {
            var button: Button = new Button();
            button.defaultSkin  = _doSliderThumb;
            button.downSkin     = _doSliderThumb;
            return button;
          }
        }
        else {
          _slider.thumbProperties.defaultSkin = _doSliderThumb;
          _slider.thumbProperties.downSkin    = _doSliderThumb;
        }
      }
      
      if (isInvalid(IF_STATE_CHANGED)) {
      }
      
      var pw: Number = width * 0.01;
      var ph: Number = height * 0.01;
      
      if (sizeInvalid)
      {
        _lblTime.bottomPercentHeight = 10;
        _lblTime.percentHeight = 33;
        _lblTime.invalidate();
        _lblTime.validate();
        
        _doBackground.width = width;
        _doBackground.height = height;
        
        var ar:Number = _btnRecord.defaultSkin.height / _btnRecord.defaultSkin.width; 
        
        _btnRecord.height = ph * 50;
        _btnRecord.width = _btnRecord.height/ar;
        
        _btnClear.width   = _btnRecord.width;
        _btnClear.height  = _btnRecord.height;
        
        if (_btnRecord.defaultSkin) {
          _btnRecord.defaultSkin.width = _btnRecord.width;
          _btnRecord.defaultSkin.height = _btnRecord.height;
        }
        if (_btnRecord.downSkin) {
          _btnRecord.downSkin.width = _btnRecord.width;
          _btnRecord.downSkin.height = _btnRecord.height;
        }
        
        if (_doSliderTrack)
        {
          _slider.visible = true;
          layoutInvalid = true;
        }
      }
      
      if (layoutInvalid)
      {
        _lblTime.left = (width - _lblTime.width) / 2;
        _lblTime.bottomPercentHeight = 6.5;
        
        _btnRecord.y = (height - _btnRecord.height) / 2;
        _btnRecord.x = _btnRecord.y;
        
        _btnClear.y = (height - _btnClear.height) / 2;
        _btnClear.x = width - _btnClear.width - _btnClear.y;
        
        if (_doSliderTrack)
        {
          _slider.width   = _btnClear.x - (btnRecord.x + btnRecord.width) - (pw * 7);
          _slider.height  = height * sliderHeightFac;
          
          _doSliderTrack.width  = _slider.width;
          _doSliderTrack.height = _slider.height * sliderTrackHeightFac;
          
          _slider.x = (width - _slider.width) * 0.5;
          _slider.y = (height - _slider.height) * sliderYOffsetFac;
          
          //_slider.invalidate()
          if (_doSliderThumb)
          {
            // Scale the thumb to match the scaling of the track
            var sf: Number = _slider.height / _sliderThumbOrigDim.height;
            _doSliderThumb.width = _sliderThumbOrigDim.width * sf;
            _doSliderThumb.height = _sliderThumbOrigDim.height * sf;
          }         
        }
        else {
          _slider.visible = false;
        }
      }
    }
    
    override protected function initialize(): void
    {
      super.initialize();
      
      _btnRecord = new Button();
      
      // Create clear button
      _btnClear = new Button();
      _btnClear.alpha = 0.6;
      _btnClear.isEnabled = false;
      
      // Create total time/current time label
      _lblTime = new FlexLabel();
      _lblTime.autoSizeFont = true;
      _lblTime.text = msToMinSec(0);
      _lblTime.relativeCalcWidthParent = _lblTime.relativeCalcHeightParent = this;
      _lblTime.textRendererFactory = function(): ITextRenderer {
        return new TextFieldTextRenderer();
      }
      _lblTime.textRendererProperties.textFormat = new TextFormat('Arial', timeFontSize, timeFontColor, null, null, null, null, null, null, null, null, null, null);
      
      // Create slider to show playback position and allow seeking
      _slider = new Slider();
      updateSliderRange();
      
      _updateSlider = true;
      _reachedEnd = false;
      
      addChild(_btnRecord);
      if(_flagOnlyPlayMode == false)
        addChild(_btnClear);
      addChild(_lblTime);
      addChild(_slider);
      
      // Add event listeners
      _btnRecord.addEventListener(Event.TRIGGERED, btnRecord_onTrigger);
      _btnClear.addEventListener(Event.TRIGGERED, btnClear_onTrigger);
      
      _slider.addEventListener(FeathersEventType.BEGIN_INTERACTION, slider_onBeginInteraction);
      _slider.addEventListener(FeathersEventType.END_INTERACTION, slider_onEndInteraction);
    }
    
    public function AudioNote()
    {
      super();
      
      _rawRecording = null;
      _channel = null;
      _mic = null;
      _state = AudioNoteState.none;
      
      _wavEncoder = new WaveEncoder(1);
      
      _sliderTrackOrigDim = new Dim();
      _sliderThumbOrigDim = new Dim();
      
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    override public function dispose(): void
    {
      super.dispose();
      
      clearRecording();
      if (_mic) {
        _mic.removeEventListener(ActivityEvent.ACTIVITY, mic_onActivity);
        _mic.removeEventListener(StatusEvent.STATUS, mic_onStatus);
        _mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, mic_onSampleData); 
      }
    }
    
    public function reset(): void
    {
      clearRecording();
      updateRecordButtonSkin();
      
      if(_mp3Encoder && _mp3Encoder.mp3Data) {
        _mp3Encoder.mp3Data.clear();
        _mp3Encoder.mp3Data = null;
      }
      
    }
    
    public function saveRecording(file: File): Boolean
    {
      if (_mp3Encoder == null || _mp3Encoder.mp3Data == null || _mp3Encoder.mp3Data.length==0)
        return false;
      //throw new Error('No recording available to save!');
      
      AudioFile.saveBytes(_mp3Encoder.mp3Data, file);
      
      return true;
    }
    
    public function loadRecording(file: File): void
    {
      stopPlayback(false);
      stopRecording(false, true);
      
      if (_mp3Encoder == null)
        createMp3Encoder();
      
      if (_mp3Encoder.mp3Data)
        _mp3Encoder.mp3Data.clear();
      else
        _mp3Encoder.mp3Data = new ByteArray();
      
      //_rawRecording = AudioFile.loadFile(file, _wavEncoder);
      var fs: FileStream = new FileStream();
      try {
        fs.open(file, FileMode.READ);
        fs.readBytes(_mp3Encoder.mp3Data, 0, file.size);
        
        _state = AudioNoteState.recorded;
        _btnClear.alpha = 1.0;
        _btnClear.isEnabled = true;
        
        createSoundFromMp3Data();
      }
      catch (ex: Error) {
        _mp3Encoder.mp3Data.clear();
        _state = AudioNoteState.none;
      }
      finally {
        fs.close();
      }
      updateSliderRange();
      updateRecordButtonSkin();
    }
    
    public function get doBackground(): DisplayObject {
      return _doBackground;
    }
    public function set doBackground(value: DisplayObject): void {
      if (_doBackground && getChildIndex(_doBackground) > -1)
        removeChild(_doBackground);
      
      _doBackground = value;
      invalidate(IF_DOU_BACKGROUND);
    }
    
    public function get doBtnRecord(): DisplayObject {
      return _doBtnRecord;
    }
    public function set doBtnRecord(value: DisplayObject): void {
      _doBtnRecord = value;
      invalidate(IF_DOU_BTN_RECORD);
    }
    
    public function get doBtnPlay(): DisplayObject {
      return _doBtnPlay;
    }
    public function set doBtnPlay(value: DisplayObject): void {
      _doBtnPlay = value;
      invalidate(IF_DOU_BTN_PLAY);
    }
    
    public function get doBtnStop(): DisplayObject {
      return _doBtnStop;
    }
    public function set doBtnStop(value: DisplayObject): void {
      _doBtnStop = value;
      invalidate(IF_DOU_BTN_STOP);
    }
    
    public function get doBtnClear(): DisplayObject {
      return _doBtnClear;
    }
    public function set doBtnClear(value: DisplayObject): void {
      _doBtnClear = value;
      invalidate(IF_DOU_BTN_CLEAR);
    }
    
    public function get doSliderTrack(): DisplayObject {
      return _doSliderTrack;
    }
    public function set doSliderTrack(value: DisplayObject): void {
      _doSliderTrack = value;     
      _sliderTrackOrigDim.width   = value.width;
      _sliderTrackOrigDim.height  = value.height;
      _sliderTrackOrigDim.calcAr();
      
      invalidate(IF_DOU_SLIDER_TRACK);
    }
    
    public function get doSliderThumb(): DisplayObject {
      return _doSliderThumb;
    }
    public function set doSliderThumb(value: DisplayObject): void {
      _doSliderThumb = value;
      _sliderThumbOrigDim.width   = value.width;
      _sliderThumbOrigDim.height  = value.height;
      _sliderThumbOrigDim.calcAr();
      
      invalidate(IF_DOU_SLIDER_THUMB);
    }
    
    public function get btnRecord(): Button {
      return _btnRecord;
    }
    
    public function get recording(): AudioData {
      return _rawRecording;
    }
    
    /**
     * The maximum record time in seconds, with -1 signifying unlimited recording time.
     * Reaching this limit will result in an auto-stop.
     */
    public function get maxRecordTime(): int {
      return _maxRecordTime;
    }
    public function set maxRecordTime(value: int): void {
      _maxRecordTime = value;
    }
    
    public function get lblTime(): FlexLabel {
      return _lblTime;
    }
    
    public function get flagOnlyPlayMode():Boolean
    {
      return _flagOnlyPlayMode;
    }
    
    public function set flagOnlyPlayMode(value:Boolean):void
    {
      _flagOnlyPlayMode = value;
    }
    
  }
}