import System.Exit

{-
Needed packages:
haskell-platform libghc-xmonad-dev libghc-xmonad-contrib-dev
-}

import XMonad
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Layout.NoBorders
import qualified XMonad.StackSet as W

import XMonad.Config.Gnome
import XMonad.Util.EZConfig

myManageHook = composeAll (
    [ manageHook gnomeConfig
    , className =? "Unity-2d-panel"     --> doIgnore
    , className =? "Unity-2d-launcher"  --> doFloat
    , className =? "Unity-2d-shell"     --> doFloat
    , resource  =? "Do"                 --> doFloat
    , resource  =? "xmessage"           --> doFloat
    , resource  =? "zenity"             --> doFloat

    , isFullscreen                      --> doFullFloat
    , resource =? "sun-awt-X11-XFramePeer" --> doFloat
    , resource =? "zeal"                --> doFloat

    , resource =? "google-chrome"       --> doShift "1"
    , resource =? "chromium-browser"    --> doShift "1"
    
    ])
    where windowRectFloat = doRectFloat $ W.RationalRect (1/10) (1/10) (4/5) (4/5)
          doSink = ask >>= \w -> liftX (reveal w) >> doF (W.sink w)

myAdditionalKeys = 
    [ ((mod1Mask,               xK_q ), kill)
    , ((mod4Mask,               xK_q ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad))
    , ((mod1Mask .|. shiftMask, xK_q ), io (exitWith ExitSuccess)) -- %! Quit xmonad

    , ((mod1Mask .|. shiftMask, xK_t ), spawn "gnome-terminal") -- %! Launch terminal
    , ((mod1Mask .|. shiftMask, xK_c ), spawn "chromium-browser || google-chrome") -- %! Launch browser
    , ((mod1Mask .|. shiftMask, xK_f ), spawn "firefox") -- %! Launch browser
    , ((mod1Mask,               xK_p ), spawn "kupfer || gnome-do")
    , ((mod4Mask,               xK_c ), spawn "xprop WM_CLASS | cut -d\\\" -f2 | xargs notify-send 'Window Class'") -- %! Show window class in notification
    ]
myRemovedKeys = 
    [ (mod1Mask, xK_r) 
    , (mod1Mask .|. shiftMask, xK_r)
    ]

myNormalBorderColor  = "#000"
myFocusedBorderColor = "#0092e6" -- nice blue

-- This makes some java programs magically start working
-- (added due to Android Studio white&unresponsive screen)
myStartupHook = setWMName "LG3D"

main = xmonad $ gnomeConfig 
        { manageHook = myManageHook 
        , startupHook = startupHook gnomeConfig >> myStartupHook
        , layoutHook = smartBorders $ layoutHook gnomeConfig
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        } `additionalKeys` myAdditionalKeys
        `removeKeys` myRemovedKeys


