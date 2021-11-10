module Coord exposing
    ( Coord
    , RawCellCoord
    , abs
    , area
    , distance
    , divide
    , maximum
    , minimum
    , minus
    , negate
    , pixels
    , plus
    , pointToVec
    , round
    , scale
    , scaleFloat
    , toPoint
    , toVec
    , toVector2d
    , unsafe
    , unwrap
    , x
    , xOnly
    , y
    , yOnly
    )

import Math.Vector2 exposing (Vec2)
import Point2d exposing (Point2d)
import Quantity exposing (Quantity(..))
import Units exposing (WorldPixel)
import Vector2d exposing (Vector2d)


type alias RawCellCoord =
    ( Int, Int )


area : Coord unit -> Int
area coord =
    let
        ( x_, y_ ) =
            unwrap coord
    in
    x_ * y_


plus : Coord unit -> Coord unit -> Coord unit
plus ( x0, y0 ) ( x1, y1 ) =
    ( Quantity.plus x0 x1, Quantity.plus y0 y1 )


minus : Coord unit -> Coord unit -> Coord unit
minus ( x0, y0 ) ( x1, y1 ) =
    ( Quantity.minus x0 x1, Quantity.minus y0 y1 )


scale : ( Int, Int ) -> Coord unit -> Coord unit
scale ( x0, y0 ) ( x1, y1 ) =
    ( Quantity.multiplyBy x0 x1, Quantity.multiplyBy y0 y1 )


scaleFloat : ( Float, Float ) -> Coord unit -> Coord unit
scaleFloat ( x0, y0 ) ( x1, y1 ) =
    ( Quantity.multiplyBy x0 (Quantity.toFloatQuantity x1) |> Quantity.round
    , Quantity.multiplyBy y0 (Quantity.toFloatQuantity y1) |> Quantity.round
    )


divide : Coord unit -> Coord unit -> Coord unit
divide ( Quantity x0, Quantity y0 ) ( Quantity x1, Quantity y1 ) =
    ( x1 // x0 |> Quantity, y1 // y0 |> Quantity )


minimum : Coord unit -> Coord unit -> Coord unit
minimum ( x0, y0 ) ( x1, y1 ) =
    ( Quantity.min x0 x1, Quantity.min y0 y1 )


maximum : Coord unit -> Coord unit -> Coord unit
maximum ( x0, y0 ) ( x1, y1 ) =
    ( Quantity.max x0 x1, Quantity.max y0 y1 )


abs : Coord unit -> Coord unit
abs ( x0, y0 ) =
    ( Quantity.abs x0, Quantity.abs y0 )


toVec : Coord units -> Vec2
toVec ( Quantity x_, Quantity y_ ) =
    Math.Vector2.vec2 (toFloat x_) (toFloat y_)


toPoint : Coord units -> Point2d units coordinate
toPoint ( x_, y_ ) =
    Point2d.xy (Quantity.toFloatQuantity x_) (Quantity.toFloatQuantity y_)


pointToVec : Point2d units coordinate -> Vec2
pointToVec point2d =
    Math.Vector2.vec2 (Point2d.xCoordinate point2d |> Quantity.unwrap) (Point2d.yCoordinate point2d |> Quantity.unwrap)


pixels : Int -> Int -> Coord WorldPixel
pixels x_ y_ =
    ( Quantity x_, Quantity y_ )


negate : Coord unit -> Coord unit
negate ( x_, y_ ) =
    ( Quantity.negate x_, Quantity.negate y_ )


round : Point2d units coordinate -> Coord units
round point2d =
    let
        a =
            Point2d.unwrap point2d
    in
    unsafe ( Basics.round a.x, Basics.round a.y )


toVector2d : Coord units -> Vector2d units coordinate
toVector2d ( x_, y_ ) =
    Vector2d.xy (Quantity.toFloatQuantity x_) (Quantity.toFloatQuantity y_)


unwrap : Coord units -> ( Int, Int )
unwrap ( Quantity x_, Quantity y_ ) =
    ( x_, y_ )


unsafe : ( Int, Int ) -> Coord units
unsafe ( x_, y_ ) =
    ( Quantity x_, Quantity y_ )


xOnly : Coord units -> Coord units
xOnly ( x_, _ ) =
    ( x_, Quantity.zero )


yOnly : Coord units -> Coord units
yOnly ( _, y_ ) =
    ( Quantity.zero, y_ )


x : Coord units -> Quantity Int units
x ( x_, _ ) =
    x_


y : Coord units -> Quantity Int units
y ( _, y_ ) =
    y_


type alias Coord units =
    ( Quantity Int units, Quantity Int units )


distance : Coord unit -> Coord unit -> Quantity Float unit
distance ( Quantity x0, Quantity y0 ) ( Quantity x1, Quantity y1 ) =
    (x1 - x0) ^ 2 + (y1 - y0) ^ 2 |> toFloat |> sqrt |> Quantity
