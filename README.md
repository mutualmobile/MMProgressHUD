MMProgressHUD
==============

An easy-to-use HUD interface with personality.

##Installation
Use cocoapods for installation: `pod 'MMProgressHUD'`

##Usage
Use the shared instance of `MMProgressHUD` through either the `+sharedHUD` class method or through the other suite of class convenience methods available.

###Anatomy
MMProgressHUD consists of a window, an overlay view, and the HUD view itself. Since MMProgressHUD is window-based, the overlay will display full-screen over the status bar. The only two pieces of information related to MMProgressHUD's visual anatomy are the text labels:

<!--````
-- MMProgressHUDWindow (UIWindow)
---- MMProgressHUDOverlayView (UIView)
---- MMHud (UIView)
------ titleLabel (UILabel)
------ contentContainer (UIView)
------ statusLabel (UILabel)
```` -->

![](Demo/Images/title-status.png "MMHud")

`titleLabel` - The is the label at the top of the HUD above the content area.  
`statusLabel` - The message label that is displayed at the bottom of the HUD below the center content area. In the absence of title text, this label's font will be the bold variant.

You will never access these label properties directly, but it's useful to know which text will be displayed in which label when using the class convenience methods.


###Setup
When setting up your instance of MMProgressHUD, you'll need to configure the settings according to the style and behavior you're trying to achieve. You can find the available properties in `MMProgressHUD.h`. These settings will persist across calls of `show` and `dismiss`, so you only have to set them once per instance:

1. `overlayMode` - The type of overlay that displays behind the hud
2. `successImage` - The success image you would like to use for success dismissal. The default image is a white check mark.
3. `errorImage` - The error image you would like to use for error situations. The default image is a white 'X'.
4. `confirmationMessage` - A message to be displayed to the user when a cancelable HUD action is displayed.
6. `presentationStyle` - The behavior animation the HUD performs when presenting and dismissing itself.
7. `glowColor` - The glow color the HUD emits during cancellation confirmation.
8. `progressStyle` - The style that the HUD inherits when the HUD is in determinate progress state.

####Completion Blocks
Some HUD actions can have an associated block of work attached to them to be fired when the action occurs:

1. `dismissAnimationCompletion` - A block of work that is executed when the HUD dismissal animation is completed.
2. `cancelBlock` - A block of work that is executed when the user cancels a long-running action.
3. `progressCompletion` - A block of work that is executed when the HUD's progress property is fed a value >= 1.f.

##License
Standard MIT License