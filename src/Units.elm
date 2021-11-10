module Units exposing
    ( ScreenCoordinate
    , WorldCoordinate
    , WorldPixel
    , screenFrame
    , worldUnit
    )

import Frame2d exposing (Frame2d)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity, Rate)


type WorldPixel
    = WorldPixel Never


worldUnit : number -> Quantity number WorldPixel
worldUnit =
    Quantity.Quantity


screenFrame : Point2d WorldPixel WorldCoordinate -> Frame2d WorldPixel WorldCoordinate { defines : ScreenCoordinate }
screenFrame viewPoint =
    Frame2d.atPoint viewPoint


type ScreenCoordinate
    = ScreenCoordinate Never


type WorldCoordinate
    = WorldCoordinate Never
