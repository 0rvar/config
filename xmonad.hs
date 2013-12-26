import System.Exit

import XMonad
import XMonad.Hooks.ManageHelpers
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

    --, resource  =? "keepass2"           --> doCenterFloat

    , isFullscreen                      --> doFullFloat
    , resource =? "FEZ.bin.x86"         --> doFloat
    , resource =? "gnuplot"             --> doCenterFloat
    , resource =? "sun-awt-X11-XFramePeer" --> doFloat

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
    , ((mod1Mask,               xK_p ), spawn "kupfer || gnome-do")
    , ((mod4Mask,               xK_c ), spawn "xprop WM_CLASS | cut -d\\\" -f2 | xargs notify-send 'Window Class'") -- %! Show window class in notification
    ]

myNormalBorderColor  = "#888888"
--myFocusedBorderColor = "#f9f9f9"
myFocusedBorderColor = "#000"

main = xmonad $ gnomeConfig 
        { manageHook = myManageHook 
        , layoutHook = smartBorders $ layoutHook gnomeConfig
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        } `additionalKeys` myAdditionalKeys


