module Main exposing (main)

import Browser
import Browser.Dom
import Html exposing (Html)
import Html.Attributes as Attr
import Layers
import Layers.Modal



-- MAIN - the entrypoint to the Elm application


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- 1️⃣  First we define a custom type for all the overlays we might need to show


type Item
    = HelloModal



-- INIT - the initial state of the app


type alias Model =
    { -- 2️⃣  This will keep track of open overlays for us
      layers : Layers.Model Item
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { -- 3️⃣  We use `Layer.init` to initialize our app (with no open overlays)
        layers = Layers.init
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = -- 4️⃣  This will handle internal messages from our overlay layer (open/close/etc)
      GotLayersMsg (Layers.Msg Item)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotLayersMsg layersMsg ->
            -- 5️⃣  When we get a message, the `Layers.update` function will
            --     convert it into a ( Model, Cmd Msg ) for us!
            Layers.update
                { msg = layersMsg
                , model = model.layers
                , toAppMsg = GotLayersMsg
                , toAppModel = \newLayers -> { model | layers = newLayers }
                }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    -- 6️⃣  Use `Layers.view` to wrap your normal `view` function.
    Layers.view
        { model = model.layers
        , toAppMsg = GotLayersMsg
        , viewAppLayer = viewAppLayer model
        , viewLayerItem = viewLayerItem model
        }


viewAppLayer : Model -> Html Msg
viewAppLayer model =
    -- 7️⃣  Use `Layers.viewButton` to create a button that opens your modal.
    Layers.viewButton
        { item = HelloModal
        , model = model.layers
        , toAppMsg = GotLayersMsg
        }
        [ Attr.style "margin" "1rem" ]
        [ Html.text "Open hello modal" ]



-- 8️⃣  Define a way to view items


viewLayerItem : Model -> Item -> Browser.Dom.Element -> Html Msg
viewLayerItem model item parent =
    case item of
        HelloModal ->
            Layers.Modal.viewCentered
                (Html.div
                    [ Attr.style "background" "pink"
                    , Attr.style "padding" "1rem"
                    ]
                    [ Html.text "Hello, world!" ]
                )
