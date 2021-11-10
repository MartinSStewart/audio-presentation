module Types exposing
    ( BackendModel
    , BackendMsg(..)
    , FrontendLoaded
    , FrontendLoading
    , FrontendModel
    , FrontendModel_(..)
    , FrontendMsg
    , FrontendMsg_(..)
    , ToBackend(..)
    , ToFrontend(..)
    )

import Audio exposing (Audio, LoadError)
import Browser exposing (UrlRequest)
import Browser.Navigation
import Coord exposing (Coord, RawCellCoord)
import Keyboard
import Pixels exposing (Pixels)
import Quantity exposing (Quantity, Rate)
import Time
import Units exposing (ScreenCoordinate, WorldCoordinate, WorldPixel)
import Url exposing (Url)
import WebGL.Texture exposing (Texture)


type alias FrontendModel =
    Audio.Model FrontendMsg_ FrontendModel_


type FrontendModel_
    = Loading FrontendLoading
    | Loaded FrontendLoaded
    | LoadingFailed


type alias FrontendLoading =
    { key : Browser.Navigation.Key
    , windowSize : Maybe (Coord Pixels)
    , devicePixelRatio : Maybe (Quantity Float (Rate WorldPixel Pixels))
    , time : Maybe Time.Posix
    , popSound : Maybe (Result Audio.LoadError Audio.Source)
    , music : Maybe (Result Audio.LoadError Audio.Source)
    , gameOverSound : Maybe (Result Audio.LoadError Audio.Source)
    , texture : Maybe (Result WebGL.Texture.Error Texture)
    }


type alias FrontendLoaded =
    { key : Browser.Navigation.Key
    , texture : Texture
    , pressedKeys : List Keyboard.Key
    , previousKeys : List Keyboard.Key
    , windowSize : Coord Pixels
    , devicePixelRatio : Quantity Float (Rate WorldPixel Pixels)
    , time : Time.Posix
    , popSound : Audio.Source
    , music : Audio.Source
    , gameOverSound : Audio.Source
    , playerPosition : Coord WorldPixel
    , startTime : Maybe Time.Posix
    , isDead : Maybe Time.Posix
    , previousTime : Time.Posix
    , masterVolume : Float
    , slide : Int
    , previousSlide : Maybe Time.Posix
    }


type alias BackendModel =
    {}


type alias FrontendMsg =
    Audio.Msg FrontendMsg_


type FrontendMsg_
    = UrlClicked UrlRequest
    | UrlChanged Url
    | TextureLoaded (Result WebGL.Texture.Error Texture)
    | KeyMsg Keyboard.Msg
    | WindowResized (Coord Pixels)
    | GotDevicePixelRatio (Quantity Float (Rate WorldPixel Pixels))
    | AnimationFrame Time.Posix
    | PopSoundLoaded (Result LoadError Audio.Source)
    | MusicLoaded (Result LoadError Audio.Source)
    | DeathSoundLoaded (Result LoadError Audio.Source)
    | DraggedMasterVolumeSlider Float


type ToBackend
    = ToBackendNoOp


type BackendMsg
    = BackendMsgNoOp


type ToFrontend
    = ToFrontendNoOp
