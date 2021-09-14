import System.Exit
import System.IO (hPutStrLn)

import XMonad
import XMonad.Config.Gnome (gnomeConfig)
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doRectFloat)
import XMonad.Hooks.ManageDocks (avoidStruts, manageDocks, docksEventHook)
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, xmobarPP, ppOutput, ppTitle, xmobarColor, shorten)
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Grid (Grid(..))
import XMonad.Layout.Spacing (spacing, smartSpacing)
import XMonad.Layout.Gaps (gaps, Direction2D(..))
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig (additionalKeys, removeKeys)
import XMonad.StackSet (RationalRect(..), sink)

import Graphics.X11.ExtraTypes.XF86


-- spacing 10 .
layout = avoidStruts . smartBorders $ tiled ||| Grid ||| Full ||| Mirror tiled
    where
        tiled  = Tall 1 (2/100) (1/2)  -- numInMasterPane RatioChangeDelta InitialMasterRatio

manageRules = composeAll (
    [ isFullscreen                         --> doFullFloat
    --, resource =? "tint2"                  --> doIgnore
    , resource =? "sun-awt-X11-XFramePeer" --> doFloat
    , resource  =? "zenity"                --> doFloat

    , resource =? "google-chrome"          --> doShift "1"
    , resource =? "chromium-browser"       --> doShift "1"
    , resource =? "chromium"               --> doShift "1"

    ])
    where windowRectFloat = doRectFloat $ RationalRect (1/10) (1/10) (4/5) (4/5)
          doSink = ask >>= \w -> liftX (reveal w) >> doF (sink w)

{-
156 XF86Launch1
232 XF86MonBrightnessDown
233 XF86MonBrightnessUp
235 XF86Display
201 XF86TouchpadOff
121 XF86AudioMute
122 XF86AudioLowerVolume
123 XF86AudioRaiseVolume
237 XF86KbdBrightnessDown
238 XF86KbdBrightnessUp
210 XF86Launch3
246 XF86WLAN
107 Print
37 Control_L
200 XF86TouchpadOn
-}
plusKeys =
    [ ((noModMask, xF86XK_MonBrightnessUp),   spawn "light -A 5")
    , ((noModMask, xF86XK_MonBrightnessDown), spawn "light -U 5")
    , ((noModMask, xF86XK_AudioMute),         spawn "pactl set-sink-mute 0 toggle")
    , ((noModMask, xF86XK_AudioLowerVolume),  spawn "pactl set-sink-volume 0 -5% && paplay ~/.xmonad/files/volume.wav")
    , ((noModMask, xF86XK_AudioRaiseVolume),  spawn "pactl set-sink-volume 0 +5% && paplay ~/.xmonad/files/volume.wav")
    , ((noModMask,              xK_Print),    spawn "scrot -e 'mv $f ~/Pictures'")

    , ((mod1Mask,               xK_q ), kill)
    , ((mod4Mask,               xK_q ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad))
    , ((mod1Mask .|. shiftMask, xK_q ), io (exitWith ExitSuccess)) -- %! Quit xmonad

    , ((mod1Mask .|. shiftMask, xK_t ), spawn "gnome-terminal") -- %! Launch terminal
    , ((mod1Mask .|. shiftMask, xK_c ), spawn "google-chrome-stable") -- %! Launch browser
    , ((mod1Mask .|. shiftMask, xK_f ), spawn "firefox") -- %! Launch browser
    , ((mod1Mask,               xK_p ), spawn "kupfer || gnome-do")
    , ((mod4Mask,               xK_c ), spawn "xprop WM_CLASS | cut -d\\\" -f2 | xargs notify-send 'Window Class'") -- %! Show window class in notification

    , ((mod1Mask .|. shiftMask , xK_h ), sendMessage Shrink) -- %! Shrink the master area
    , ((mod1Mask .|. shiftMask , xK_l ), sendMessage Expand) -- %! Expand the master area
    ]

minusKeys =
    [ (mod1Mask, xK_r)
    , (mod1Mask .|. shiftMask, xK_r)
    , (mod1Mask, xK_l)
    , (mod1Mask, xK_h)
    ]

myNormalBorderColor  = "#000"
myFocusedBorderColor = "#0092e6" -- nice blue

-- This makes some java programs magically start working
-- (added due to Android Studio white&unresponsive screen)
startup = setWMName "LG3D"

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobarrc"
    xmonad $ gnomeConfig
        { manageHook = manageRules <+> manageDocks
        , layoutHook = layout
        , startupHook = startup
        , handleEventHook = handleEventHook gnomeConfig <+> docksEventHook
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        } `additionalKeys` plusKeys
          `removeKeys` minusKeys
