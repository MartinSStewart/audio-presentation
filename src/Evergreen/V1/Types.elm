module Evergreen.V1.Types exposing (..)

import Audio
import Browser
import Browser.Navigation
import Evergreen.V1.Coord
import Evergreen.V1.Units
import Keyboard
import Pixels
import Quantity
import Time
import Url
import WebGL.Texture


type FrontendMsg_
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | TextureLoaded (Result WebGL.Texture.Error WebGL.Texture.Texture)
    | KeyMsg Keyboard.Msg
    | WindowResized (Evergreen.V1.Coord.Coord Pixels.Pixels)
    | GotDevicePixelRatio (Quantity.Quantity Float (Quantity.Rate Evergreen.V1.Units.WorldPixel Pixels.Pixels))
    | AnimationFrame Time.Posix
    | PopSoundLoaded (Result Audio.LoadError Audio.Source)
    | MusicLoaded (Result Audio.LoadError Audio.Source)
    | DeathSoundLoaded (Result Audio.LoadError Audio.Source)
    | DraggedMasterVolumeSlider Float


type alias FrontendLoading =
    { key : Browser.Navigation.Key
    , windowSize : Maybe (Evergreen.V1.Coord.Coord Pixels.Pixels)
    , devicePixelRatio : Maybe (Quantity.Quantity Float (Quantity.Rate Evergreen.V1.Units.WorldPixel Pixels.Pixels))
    , time : Maybe Time.Posix
    , popSound : Maybe (Result Audio.LoadError Audio.Source)
    , music : Maybe (Result Audio.LoadError Audio.Source)
    , gameOverSound : Maybe (Result Audio.LoadError Audio.Source)
    , texture : Maybe (Result WebGL.Texture.Error WebGL.Texture.Texture)
    }


type alias FrontendLoaded =
    { key : Browser.Navigation.Key
    , texture : WebGL.Texture.Texture
    , pressedKeys : List Keyboard.Key
    , previousKeys : List Keyboard.Key
    , windowSize : Evergreen.V1.Coord.Coord Pixels.Pixels
    , devicePixelRatio : Quantity.Quantity Float (Quantity.Rate Evergreen.V1.Units.WorldPixel Pixels.Pixels)
    , time : Time.Posix
    , popSound : Audio.Source
    , music : Audio.Source
    , gameOverSound : Audio.Source
    , playerPosition : Evergreen.V1.Coord.Coord Evergreen.V1.Units.WorldPixel
    , startTime : Maybe Time.Posix
    , isDead : Maybe Time.Posix
    , previousTime : Time.Posix
    , masterVolume : Float
    , slide : Int
    , previousSlide : Maybe Time.Posix
    }


type FrontendModel_
    = Loading FrontendLoading
    | Loaded FrontendLoaded
    | LoadingFailed


type alias FrontendModel =
    Audio.Model FrontendMsg_ FrontendModel_


type alias BackendModel =
    {}


type alias FrontendMsg =
    Audio.Msg FrontendMsg_


type ToBackend
    = ToBackendNoOp


type BackendMsg
    = BackendMsgNoOp


type ToFrontend
    = ToFrontendNoOp
