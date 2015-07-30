# Falcon 
 a Feather/Starling extension of responsive/flexible ui controls and general mobile
 framework.
 
## How to use
simply fork or download the project, you can also download the binary itself and link it
to your project, or import to your IDE of choice such as `Flash Builder 4.7`. We support
`Starling 1.6` and `Feathers 2` and at least version 15 of `Adobe AIR SDK` is recommended.

## Features
- flexible ui components will save you tons of code for layout purposes.
- packed with `Hendrix GfxManager` and a content manager for managing assets packages. seamless texture
reliazation through factory classes.
- packed with `Hendrix Collection` for standard data structures.
- support for `Bidirectional Bitmap fonts`.
- packed with a vast amount of tested code in realife projects.
- completely free for use

### Introduction

Every component is a `FlexComp` object, every flexible component has the following
properties:
* `percentWidth` - the width percentage of the control based on it's parent( or `relativeCalcWidthParent`) 
* `percentHeight` - the height percentage of the control based on it's parent( or `relativeCalcHeightParent`) 
* `top, bottom, left, right` - the margin in exact pixels
* `topPercentHeight, bottomPercentHeight` - the margin based on percentages of parent height 
* `leftPercentWidth, rightPercentWidth` - the margin based on percentages of parent width
* `horizontalCenter` - how far is the control from being centered horizontally
* `verticalCenter` - how far is the control from being centered vertically
* `relativeCalcWidthParent` - you can change the parent on which percentage based layout
* `relativeCalcHeightParent` - you can change the parent on which percentage based layout
* `horizontalAlign`, `verticalAlign` - layout property for children layout alignment
* `isSensitiveToParent` - should the control be sensitive to his parent changes
* `id` - identifier
* `backgroundSkin` - a skin for background

##### Examples
1. a drawer with two number pickers. the layout is done automatically. saves ton of
layout code that usually goes into `draw()` method
```
override protected function initialize():void
{
  var hgTimer:    HGroup                            = new HGroup();
  var nPicker1:   NumberPicker                      = new NumberPicker();
  var nPicker2:   NumberPicker                      = new NumberPicker();
  var img:        FlexImage                         = new FlexImage();
  var drawerTime: PullDrawer                        = new PullDrawer();

  hgTimer.gapPercentWidth                           = 0;
  hgTimer.percentWidth                              = 99;
  hgTimer.percentHeight                             = 20;
  hgTimer.horizontalCenter                          = 0;
  hgTimer.horizontalAlign                           = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
  hgTimer.verticalAlign                             = VerticalLayout.VERTICAL_ALIGN_MIDDLE;

  nPicker1.buttonMinus                              = CompsFactory.newButton(SColors.PURPLE, SColors.PURPLE, null, null, null,false,"main::ssMain.icon_minus",true,"center",true) as FlexButton;
  nPicker1.buttonPlus                               = CompsFactory.newButton(SColors.PURPLE, SColors.PURPLE, null, null, null,false,"main::ssMain.icon_Add",true,"center",true) as FlexButton;
  nPicker1.buttonPercentHeight                      = 0.25;
  nPicker1.maxRange                                 = 24;
  nPicker1.onChange                                 = numberPicker_onChange;

  nPicker2.buttonMinus                              = CompsFactory.newButton(SColors.PURPLE, SColors.PURPLE, null, null, null,false,"main::ssMain.icon_minus",true,"center",true) as FlexButton;
  nPicker2.buttonPlus                               = CompsFactory.newButton(SColors.PURPLE, SColors.PURPLE, null, null, null,false,"main::ssMain.icon_Add",true,"center",true) as FlexButton;
  nPicker2.buttonPercentHeight                      = 0.25;
  nPicker2.maxRange                                 = 60;
  nPicker2.onChange                                 = numberPicker_onChange;

  img.source                                        = "main::ssMain.icon_:";
  img.percentHeight                                 = 50;
  img.scaleMode                                     = FlexImage.SCALEMODE_LETTERBOX;

  hgTimer.addChild(nPicker1);
  hgTimer.addChild(img);
  hgTimer.addChild(nPicker2);

  // Drawer Timer

  drawerTime.mainContent                            = new Quad(1,1,SColors.TILE_GREY,false);
  drawerTime.drawerContent                          = hgTimer;
  drawerTime.horizontalAlign                        = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
  drawerTime.drawerContentPercentWidth              = 100;

  drawerTime.toggleDrawer()

  addChild(drawerTime)
}
```

2. loading packages.
for complete usage learning of the `GfxManager`, consult it's own repository, or the source

```
private function loadGfxPacks():void
{
  gfxManager                                     = GfxManager.instance;

  var mrpMain:  GfxPackage                        = gfxManager.addOrGetContentPackage("main") as GfxPackage;
  
  mrpMain.loadTexturesAutomatically               = true;
  mrpMain.enqueue("assets/packages/general/spinner.png",  "spinner",    LocalResource.TYPE_BITMAP);
  // texture atlas
  mrpMain.enqueue("assets/packages/main/ssMain.png",      "ssMain",     LocalResource.TYPE_BITMAP);
  mrpMain.enqueue("assets/packages/main/ssMain.xml",      "ssMainXML",  LocalResource.TYPE_XML);
  // texture atlas
  mrpMain.enqueue("assets/packages/main/quickIcons.png",  "quickIcons");
  mrpMain.enqueue("assets/packages/main/quickIcons.xml",  "quickIconsXML");
  
  var mrpAvatarSelect:GfxPackage                  = gfxManager.addOrGetContentPackage("avatar") as GfxPackage;
  
  mrpAvatarSelect.loadTexturesAutomatically       = true;
  mrpAvatarSelect.enqueue("assets/packages/avatarSelection/sprite.png", "sprite");
  mrpAvatarSelect.enqueue("assets/packages/avatarSelection/sprite.xml", "spriteXML");

  gfxManager.loadPackages("*", onGfxLoaded);
}

private function onGfxLoaded($obj:Object = null):void
{
  ready();
  
  var img:FlexImage  = new FlexImage();
  img.source         = "main::ssMain.icon_love";
  
  var btn:FlexButton = CompsFactory.newButton("avatar::sprite.btn_down", "avatar::sprite.btn_up", btnDate_onTriggered, null, null, false, null, true) as FlexButton;      
}

```

3. Splash Screen. based on flash Sprite and not on Stage3D, since it is inited before stage3d

```
public function startSplash(flashSpriteParent:flash.display.DisplayObjectContainer):void
{
  _appSplash              = new BitmapLayersComposer(flashSpriteParent);

  _appSplash.dataProvider = Vector.<Object>([
    {id:"1",  src: SEmbeddedAssets.bm_splash_BG_,     percentWidth: 100,  percentHeight: 100, scaleMode: BitmapLayersComposer.SCALEMODE_STRECTH,    bottom: NaN, top:NaN, left:NaN ,right:NaN, horizontalCenter:0, verticalCenter:0},
    {id:"2",  src: "app/logos/bm_splash_logo1.png",   percentWidth: 75,   percentHeight: 100, scaleMode: BitmapLayersComposer.SCALEMODE_LETTERBOX,  bottom: NaN, top:NaN, left:NaN ,right:NaN, horizontalCenter:0, verticalCenter:-40},
    {id:"3",  src: "app/logos/bm_splash_logo2.png",   percentWidth: 60,   percentHeight: NaN, scaleMode: BitmapLayersComposer.SCALEMODE_LETTERBOX,  bottom: 44, top:NaN,  left:NaN ,right:NaN, horizontalCenter:0, verticalCenter:NaN}
  ]);

  _appSplash.start();
}

```

### UI Breakdown

- a full set of core flexible components
  * `FlexLabel` resizes font size according to width/height.
  * `FlexImage` supports three scale modes *STRECTH, LETTERBOX, ZOOM*
  * `FlexButton` resizes both default icon and font's size.
  * `FlexQuad` - flex version of Quad
  * `FlexList` - flex version of List
  * `FlexTextInput` - flex version of TextInput
  * `DynamicTextInput` - a realtime dynamic font sizing textinput to fit text in a frame

- a set of layout flexible components
  * `ActionBar` a very lite Action Bar component packed with flex features
  * `HGroup` robust horizontal layout
  * `VGroup` robust vertical layout
  * `FlexTabBar` a tab bar
  * `FlexTabBarC` another version of tab bar

- a set of dialog flexible components
  * `DatePickerDialog` date picker dialog
  * `TimePickerDialog` time picker dialog
  * `DateAndTimePickerDialog` date and time picker dialog
  * `Dialog` general dialog with provided content
  * `WarningDialog` a warning dialog
  * `PopupLoader` a dialog with loader animation

- a set of extended flexible components
  * `PullDrawer` - a drawer component
  * `DatePicker` a date picker component
  * `TimePicker` a time picker component
  * `ZoomContainer` a zoomable sprite
  * `NumberPicker` a number picker component
  * `AnimatedControl` a copntainer that can perform vertical toggle aniamtion
  * `FlexPageIndicator` flex page indication
  * `SnapList` a list that snaps its closest item to the center
  * `LabelList` a vertical snap list of numbers
  * `MagnifyList` a horizontal snap list that magnifies it's content
  * `LazyList` lazy image list
  * `MainWindow` a main window with navigator
  * `HamMainWindow` a main window with hamburger drawer
  * `AudioNote` an audio recording component
  * `BitmapLayersComposer` flash based image composer, works with a data provider with
layout options. great for dynamic splash screens
  * `BidiTextField` Bidirectional Text field with *bitmap fonts*. based on another repository i have published
  * `TLFLabel` Bidirectional Image text label based on `Adobe TLF`.
  * `HitButton` a flex button with a definable Polygon hit area.
  * `DragHitButton` a draggable button with ability to register objects for drop on and events.
  * `MovieClipButton` a flex button with `MovieClip` skin and sound and events.

- a set of widgets
  * `ListUpdateWidget` - a widget that hooks to a list to augment it with pull to refresh feature. 
  * `SimpleLoader` - a simple rotating image

### Data
* data tech

  * `ImageStreamer` - use HTTP to ask for images, cache them, and get notified when they arrive
  * `SQLSerialData` - a humble SQL lite ORM wrapper over serialized data structure

* utilities
  * Serialization, Bitmap, Calendar and more utilities

### Demo

<a href="http://www.youtube.com/watch?feature=player_embedded&v=MCp_mLN_W94
" target="_blank"><img src="http://img.youtube.com/vi/MCp_mLN_W94/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>

### Dependencies
* [`Starling-Framework`](https://github.com/Gamua/Starling-Framework)
* [`Feathers`](https://github.com/joshtynjala/feathers)

### Terms
* completely free source code. [Apache License, Version 2.0.](http://www.apache.org/licenses/LICENSE-2.0)
* if you like it -> star or share it with others

### Contact Author
* [tomer.shalev@gmail.com](tomer.shalev@gmail.com)
* [Google+ TomershalevMan](https://plus.google.com/+TomershalevMan/about)
* [Facebook - HendrixString](https://www.facebook.com/HendrixString)
