module Sprite exposing
    ( Sprite
    , asciiChars
    , asciiSize
    , asciiSpace
    , asciiTexturePosition
    , asciis
    , borderBottom
    , borderBottomLeft
    , borderBottomRight
    , borderLeft
    , borderRight
    , borderTop
    , borderTopLeft
    , borderTopRight
    , bullet
    , bulletTexturePosition
    , charsPerRow
    , fromChar
    , luxara
    , luxaraTexturePosition
    , player
    , playerTexturePosition
    , textureHeight
    , texturePosition
    , textureWidth
    )

import Coord exposing (Coord)
import Dict exposing (Dict)
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Math.Vector2 exposing (Vec2)
import Quantity exposing (Quantity(..))
import Units exposing (WorldPixel)


asciiChars : List Char
asciiChars =
    (List.range 32 126 ++ List.range 161 172 ++ List.range 174 255)
        |> List.map Char.fromCode
        |> (++) [ '░', '▒', '▓', '█' ]
        |> (++) [ '│', '┤', '╡', '╢', '╖', '╕', '╣', '║', '╗', '╝', '╜', '╛', '┐', '└', '┴', '┬', '├', '─', '┼', '╞', '╟', '╚', '╔', '╩', '╦', '╠', '═', '╬', '╧', '╨', '╤', '╥', '╙', '╘', '╒', '╓', '╫', '╪', '┘', '┌' ]


asciis : Nonempty Sprite
asciis =
    List.filterMap fromChar asciiChars
        |> List.Nonempty.fromList
        |> Maybe.withDefault (List.Nonempty.fromElement asciiSpace)


charToAscii : Dict Char Sprite
charToAscii =
    asciiChars |> List.indexedMap (\index char -> ( char, Ascii index )) |> Dict.fromList


fromChar : Char -> Maybe Sprite
fromChar char =
    Dict.get char charToAscii


asciiSize : ( Quantity number unit, Quantity number unit )
asciiSize =
    ( Quantity 10, Quantity 18 )


asciiSpace : Sprite
asciiSpace =
    asciiChars |> List.findIndex ((==) ' ') |> Maybe.withDefault 0 |> Ascii


charsPerRow : number
charsPerRow =
    25


textureWidth : number
textureWidth =
    256


textureHeight : number
textureHeight =
    512


type Sprite
    = Ascii Int
    | Luxara
    | Player
    | Bullet
    | BorderTop
    | BorderLeft
    | BorderRight
    | BorderBottom
    | BorderTopLeft
    | BorderTopRight
    | BorderBottomLeft
    | BorderBottomRight


luxara : Sprite
luxara =
    Luxara


player : Sprite
player =
    Player


bullet : Sprite
bullet =
    Bullet


borderLeft =
    BorderLeft


borderRight =
    BorderRight


borderTop =
    BorderTop


borderBottom =
    BorderBottom


borderTopLeft =
    BorderTopLeft


borderTopRight =
    BorderTopRight


borderBottomLeft =
    BorderBottomLeft


borderBottomRight =
    BorderBottomRight


asciiTexturePosition : Int -> { topLeft : Vec2, bottomRight : Vec2, size : Coord WorldPixel }
asciiTexturePosition ascii_ =
    let
        ( Quantity.Quantity w, Quantity.Quantity h ) =
            asciiSize
    in
    { topLeft =
        Math.Vector2.vec2
            (modBy charsPerRow ascii_ |> (*) w |> toFloat |> (\a -> a / textureWidth))
            (ascii_ // charsPerRow |> (*) h |> toFloat |> (\a -> a / textureHeight))
    , bottomRight =
        Math.Vector2.vec2
            (modBy charsPerRow ascii_ |> (+) 1 |> (*) w |> toFloat |> (\a -> a / textureWidth))
            (ascii_ // charsPerRow |> (+) 1 |> (*) h |> toFloat |> (\a -> a / textureHeight))
    , size = Coord.pixels 10 18
    }


texturePosition : Sprite -> { topLeft : Vec2, bottomRight : Vec2, size : Coord WorldPixel }
texturePosition sprite =
    case sprite of
        Ascii ascii ->
            asciiTexturePosition ascii

        Luxara ->
            luxaraTexturePosition

        Player ->
            playerTexturePosition

        Bullet ->
            bulletTexturePosition

        BorderTop ->
            borderTopTexturePosition

        BorderLeft ->
            borderLeftTexturePosition

        BorderRight ->
            borderRightTexturePosition

        BorderBottom ->
            borderBottomTexturePosition

        BorderTopLeft ->
            borderBottomTexturePosition

        BorderTopRight ->
            borderBottomTexturePosition

        BorderBottomLeft ->
            borderBottomTexturePosition

        BorderBottomRight ->
            borderBottomTexturePosition


luxaraTexturePosition : { topLeft : Vec2, bottomRight : Vec2, size : Coord WorldPixel }
luxaraTexturePosition =
    { topLeft = Math.Vector2.vec2 0 (181 / textureHeight)
    , bottomRight = Math.Vector2.vec2 (108 / textureWidth) (279 / textureHeight)
    , size = Coord.pixels 108 98
    }


playerTexturePosition =
    { topLeft = Math.Vector2.vec2 (109 / textureWidth) (181 / textureHeight)
    , bottomRight = Math.Vector2.vec2 ((109 + 57) / textureWidth) ((181 + 62) / textureHeight)
    , size = Coord.pixels 57 62
    }


bulletTexturePosition =
    { topLeft = Math.Vector2.vec2 (166 / textureWidth) (164 / textureHeight)
    , bottomRight = Math.Vector2.vec2 ((166 + 20) / textureWidth) ((164 + 20) / textureHeight)
    , size = Coord.pixels 20 20
    }


borderLeftTexturePosition =
    { topLeft = Math.Vector2.vec2 (187 / textureWidth) (164 / textureHeight)
    , bottomRight = Math.Vector2.vec2 ((187 + 12) / textureWidth) (165 / textureHeight)
    , size = Coord.pixels 12 1
    }


borderRightTexturePosition =
    { topLeft = Math.Vector2.vec2 ((187 + 12) / textureWidth) (164 / textureHeight)
    , bottomRight = Math.Vector2.vec2 (187 / textureWidth) (165 / textureHeight)
    , size = Coord.pixels 12 1
    }


borderBottomTexturePosition =
    { topLeft = Math.Vector2.vec2 (199 / textureWidth) (165 / textureHeight)
    , bottomRight = Math.Vector2.vec2 (200 / textureWidth) ((165 + 12) / textureHeight)
    , size = Coord.pixels 1 12
    }


borderTopTexturePosition =
    { topLeft = Math.Vector2.vec2 (199 / textureWidth) ((165 + 12) / textureHeight)
    , bottomRight = Math.Vector2.vec2 (200 / textureWidth) (165 / textureHeight)
    , size = Coord.pixels 1 12
    }
