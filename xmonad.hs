import XMonad
import XMonad.Config.Gnome
import XMonad.Util.EZConfig

myManageHook = composeAll (
    [ manageHook gnomeConfig
    , className =? "Unity-2d-panel" --> doIgnore
    , className =? "Unity-2d-launcher" --> doFloat
    , className =? "Unity-2d-shell" --> doFloat
    , resource  =? "Do"   --> doIgnore
    ])

myAdditionalKeys = 
    [ ((mod1Mask .|. shiftMask, xK_t), spawn "gnome-terminal") -- %! Launch terminal
    , ((mod1Mask .|. shiftMask, xK_c), spawn "chromium-browser") -- %! Launch browser
    , ((mod1Mask, xK_q  ), kill)
    , ((mod4Mask, xK_q  ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad))
    , ((mod1Mask, xK_space), spawn "kupfer")
    ]

myNormalBorderColor  = "#888888"
myFocusedBorderColor = "#f9f9f9"

main = xmonad $ gnomeConfig 
        { manageHook = myManageHook 
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        } `additionalKeys` myAdditionalKeys


