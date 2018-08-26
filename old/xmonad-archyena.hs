import System.Exit

import XMonad
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Config.Gnome (gnomeConfig)
import XMonad.Util.EZConfig (additionalKeys, removeKeys)

import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doRectFloat)

import XMonad.StackSet (RationalRect(..), sink)
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Grid (Grid(..))
import XMonad.Layout.Spacing (spacing, smartSpacing)
import XMonad.Hooks.ManageDocks (avoidStruts)

-- spacing 10 .
layout = smartBorders . avoidStruts $ tiled ||| Grid ||| Full ||| Mirror tiled
    where
        tiled  = Tall 1 (2/100) (1/2)  -- numInMasterPane RatioChangeDelta InitialMasterRatio

manageRules = composeAll (
    [ isFullscreen                         --> doFullFloat
    , resource =? "sun-awt-X11-XFramePeer" --> doFloat
    , resource  =? "zenity"                --> doFloat

    , resource =? "chromium"               --> doShift "1"

    ])
    where windowRectFloat = doRectFloat $ RationalRect (1/10) (1/10) (4/5) (4/5)
          doSink = ask >>= \w -> liftX (reveal w) >> doF (sink w)

plusKeys =
    [ ((mod1Mask,               xK_q ), kill)
    , ((mod4Mask,               xK_q ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad))
    , ((mod1Mask .|. shiftMask, xK_q ), io (exitWith ExitSuccess)) -- %! Quit xmonad

    , ((mod1Mask .|. shiftMask, xK_t ), spawn "gnome-terminal") -- %! Launch terminal
    , ((mod1Mask .|. shiftMask, xK_c ), spawn "chromium") -- %! Launch browser
    , ((mod1Mask .|. shiftMask, xK_f ), spawn "firefox") -- %! Launch browser
    , ((mod1Mask,               xK_p ), spawn "kupfer || gnome-do")
    , ((mod4Mask,               xK_c ), spawn "xprop WM_CLASS | cut -d\\\" -f2 | xargs notify-send 'Window Class'") -- %! Show window class in notification
    ]
minusKeys =
    [ (mod1Mask, xK_r)
    , (mod1Mask .|. shiftMask, xK_r)
    ]

myNormalBorderColor  = "#000"
myFocusedBorderColor = "#0092e6" -- nice blue

-- This makes some java programs magically start working
-- (added due to Android Studio white&unresponsive screen)
startup = setWMName "LG3D"

main = xmonad $ gnomeConfig
        { manageHook = manageRules
        , startupHook = startupHook gnomeConfig >> startup
        , layoutHook = layout
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        } `additionalKeys` plusKeys
        `removeKeys` minusKeys
